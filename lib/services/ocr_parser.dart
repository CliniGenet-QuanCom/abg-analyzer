/// OCR 撮影の入力ソース。
enum CaptureSource { camera, gallery }

/// OCR で認識した 1 要素（ML Kit の TextLine 相当）。座標つき。
class OcrElement {
  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  const OcrElement({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;
  double get height => (bottom - top).abs();
}

/// OCR 抽出結果（プラットフォーム非依存）。
class OcrExtraction {
  /// フィールドキー -> 抽出値（見つからなければ null）。
  /// キー: ph, paco2, pao2, hco3, be, fio2, na, cl, lac, hb
  final Map<String, double?> values;

  /// 認識した生テキスト（確認用）。
  final String rawText;

  const OcrExtraction({required this.values, required this.rawText});

  int get foundCount => values.values.where((v) => v != null).length;
}

/// フィールド定義（キー・ラベル候補・妥当値レンジ・符号有無）。
class _FieldDef {
  final String key;
  final List<String> keywords; // 正規表現フラグメント
  final double lo;
  final double hi;
  final bool signed;
  const _FieldDef(this.key, this.keywords, this.lo, this.hi, this.signed);
}

/// ABG/VBG 結果用紙の OCR から各検査値を抽出する純粋ロジック。
///
/// 座標（boundingBox）ベースで「同一行」を判定し、行内のラベルに対応する
/// 数値（ラベルより X が右側）を取り出す。モニターの 2 列レイアウトのように
/// 項目名と数値が別要素として認識される場合でも対応付けできる。
class AbgOcrParser {
  /// 入力フォームに反映する 8 項目（表示順）。
  static const List<({String key, String label, String unit})> fields = [
    (key: 'ph', label: 'pH', unit: ''),
    (key: 'paco2', label: 'PaCO2', unit: 'mmHg'),
    (key: 'pao2', label: 'PaO2', unit: 'mmHg'),
    (key: 'hco3', label: 'HCO3-', unit: 'mEq/L'),
    (key: 'be', label: 'BE', unit: 'mEq/L'),
    (key: 'fio2', label: 'FiO2', unit: '%'),
    (key: 'na', label: 'Na', unit: 'mEq/L'),
    (key: 'cl', label: 'Cl', unit: 'mEq/L'),
  ];

  /// 参考表示のみ（本アプリの計算には未使用）。
  static const List<({String key, String label, String unit})> referenceFields =
      [
    (key: 'lac', label: 'Lac', unit: 'mmol/L'),
    (key: 'hb', label: 'Hb', unit: 'g/dL'),
  ];

  /// マッチング定義。'O' と '0'（オー/ゼロ）の誤認識に備え [O0] を許容。
  static const List<_FieldDef> _defs = [
    _FieldDef('ph', [r'pH'], 6.5, 8.0, false),
    _FieldDef('paco2', [r'PaC[O0]2', r'PC[O0]2', r'pC[O0]2'], 5, 200, false),
    _FieldDef('pao2', [r'Pa[O0]2', r'p[O0]2', r'P[O0]2'], 10, 700, false),
    _FieldDef('hco3', [r'cHC[O0]3', r'HC[O0]3'], 1, 60, false),
    _FieldDef('be', [r'Base', r'\bA?BE'], -40, 40, true),
    _FieldDef('fio2', [r'Fi[O0]2', r'F[O0]2\(', r'F[O0]2'], 0.15, 100, false),
    _FieldDef('na', [r'cNa', r'Na'], 100, 180, false),
    _FieldDef('cl', [r'cCl', r'Cl'], 70, 140, false),
    _FieldDef('lac', [r'cLac', r'Lac'], 0, 50, false),
    _FieldDef('hb', [r'ctHb', r'tHb', r'Hb'], 1, 30, false),
  ];

  /// 全角→半角などの正規化。
  static String normalize(String s) {
    final b = StringBuffer();
    for (final r in s.runes) {
      if (r >= 0xFF10 && r <= 0xFF19) {
        b.writeCharCode(r - 0xFF10 + 0x30); // 全角数字
      } else if (r >= 0xFF21 && r <= 0xFF3A) {
        b.writeCharCode(r - 0xFF21 + 0x41); // 全角 A-Z
      } else if (r >= 0xFF41 && r <= 0xFF5A) {
        b.writeCharCode(r - 0xFF41 + 0x61); // 全角 a-z
      } else if (r == 0xFF0E) {
        b.writeCharCode(0x2E); // 全角ピリオド
      } else if (r == 0xFF0D || r == 0x2212 || r == 0x2010 || r == 0x30FC) {
        b.writeCharCode(0x2D); // 各種マイナス/長音→半角ハイフン
      } else if (r == 0xFF1A) {
        b.writeCharCode(0x3A); // 全角コロン
      } else if (r == 0x3000) {
        b.writeCharCode(0x20); // 全角スペース
      } else {
        b.writeCharCode(r);
      }
    }
    return b.toString();
  }

  /// 文字列から最初の数値を取り出す（正規表現 r'[\d]+\.?[\d]*'、符号は signed 時のみ）。
  static double? _firstNumber(String s, bool signed) {
    final re = signed ? RegExp(r'[-+]?\d+\.?\d*') : RegExp(r'\d+\.?\d*');
    final m = re.firstMatch(s);
    if (m == null) return null;
    var str = m.group(0)!;
    if (str.endsWith('.')) str = str.substring(0, str.length - 1);
    if (str == '-' || str == '+' || str.isEmpty) return null;
    return double.tryParse(str);
  }

  /// 要素群を Y 座標で「行」にグルーピングする。
  static List<List<OcrElement>> _rows(List<OcrElement> els, double yTol) {
    final sorted = [...els]..sort((a, b) => a.centerY.compareTo(b.centerY));
    final rows = <List<OcrElement>>[];
    final means = <double>[];
    for (final e in sorted) {
      if (rows.isNotEmpty && (e.centerY - means.last).abs() <= yTol) {
        rows.last.add(e);
        means[means.length - 1] =
            rows.last.map((x) => x.centerY).reduce((a, b) => a + b) /
                rows.last.length;
      } else {
        rows.add([e]);
        means.add(e.centerY);
      }
    }
    return rows;
  }

  /// 1 行（要素群）から、定義 d のラベルに対応する数値を取り出す。
  static double? _valueInRow(List<OcrElement> row, _FieldDef d) {
    final byX = [...row]..sort((a, b) => a.left.compareTo(b.left));
    for (final kw in d.keywords) {
      final re = RegExp(kw, caseSensitive: false);
      for (var i = 0; i < byX.length; i++) {
        final m = re.firstMatch(byX[i].text);
        if (m == null) continue;
        // ラベル一致要素の「キーワード以降」＋右側の要素を連結して数値を探す。
        final sb = StringBuffer(byX[i].text.substring(m.end));
        for (var j = i + 1; j < byX.length; j++) {
          sb.write(' ');
          sb.write(byX[j].text);
        }
        final v = _firstNumber(sb.toString(), d.signed);
        if (v != null && v >= d.lo && v <= d.hi) return v;
      }
    }
    return null;
  }

  /// 座標つき要素から各項目を抽出する（メイン経路）。
  ///
  /// [yTolerance] は同一行と見なす Y 中心の許容差（px）。実画像の解像度に応じて
  /// 行高の 0.6 倍とのうち大きい方を採用する。
  static Map<String, double?> extractFromElements(List<OcrElement> elements,
      {double yTolerance = 20}) {
    final els = <OcrElement>[];
    for (final e in elements) {
      final t = normalize(e.text).trim();
      if (t.isEmpty) continue;
      els.add(OcrElement(
          text: t, left: e.left, top: e.top, right: e.right, bottom: e.bottom));
    }
    final result = <String, double?>{for (final d in _defs) d.key: null};
    if (els.isEmpty) return result;

    final heights = els.map((e) => e.height).where((h) => h > 0).toList()
      ..sort();
    final median = heights.isEmpty ? 20.0 : heights[heights.length ~/ 2];
    final tol = (0.6 * median) > yTolerance ? 0.6 * median : yTolerance;

    final rows = _rows(els, tol); // centerY 昇順（上→下）
    for (final d in _defs) {
      for (final row in rows) {
        final v = _valueInRow(row, d);
        if (v != null) {
          result[d.key] = v;
          break; // 上から最初に見つかった行を採用
        }
      }
    }

    // FiO2 が割合(0–1)なら % に換算。
    final f = result['fio2'];
    if (f != null && f <= 1.0) result['fio2'] = f * 100;
    return result;
  }

  /// プレーンテキストからの抽出（座標が無い場合のフォールバック）。
  /// 各行を 1 要素として扱う（ラベルと数値が同一行にある書式に有効）。
  static Map<String, double?> extract(String rawText) {
    final lines = normalize(rawText).split(RegExp(r'[\r\n]+'));
    final els = <OcrElement>[];
    for (var i = 0; i < lines.length; i++) {
      final t = lines[i].trim();
      if (t.isEmpty) continue;
      els.add(OcrElement(
        text: t,
        left: 0,
        top: i * 100.0,
        right: t.length * 10.0,
        bottom: i * 100.0 + 30,
      ));
    }
    return extractFromElements(els, yTolerance: 10);
  }
}
