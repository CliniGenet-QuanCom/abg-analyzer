import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 表示言語。
enum NomogramLang { en, ja }

/// 酸塩基平衡ノモグラム（Cohen 図）。
///
/// X 軸: 動脈血 pH(7.0–7.8) と上軸の [H+](nmol/L)。Y 軸: HCO3-(0–60)。
/// 8 つの障害に対応する 95% 信頼帯を CustomPainter で塗りつぶし、PCO2 等圧線を
/// 破線で重ね、患者値を赤点でプロットする。InteractiveViewer でピンチズーム可能。
class CohenNomogram extends StatefulWidget {
  final double ph;
  final double hco3;

  /// 判定結果（タップ時のポップアップに表示）。
  final String classification;

  const CohenNomogram({
    super.key,
    required this.ph,
    required this.hco3,
    this.classification = '',
  });

  @override
  State<CohenNomogram> createState() => _CohenNomogramState();
}

class _CohenNomogramState extends State<CohenNomogram> {
  NomogramLang _lang = NomogramLang.en;

  void _toggleLang() => setState(
      () => _lang = _lang == NomogramLang.en ? NomogramLang.ja : NomogramLang.en);

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_lang == NomogramLang.en ? 'Plotted point' : 'プロット点'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('pH: ${widget.ph.toStringAsFixed(2)}'),
            Text('HCO3-: ${widget.hco3.toStringAsFixed(1)} mmol/L'),
            Text('PaCO2(calc): '
                '${_pco2From(widget.ph, widget.hco3).toStringAsFixed(1)} mmHg'),
            const SizedBox(height: 8),
            if (widget.classification.isNotEmpty)
              Text(
                (_lang == NomogramLang.en ? 'Assessment: ' : '判定: ') +
                    widget.classification,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  static double _pco2From(double ph, double hco3) =>
      hco3 / (0.03 * math.pow(10, ph - 6.1));

  Widget _chart(BuildContext context, {required bool fullScreen}) {
    return LayoutBuilder(builder: (context, constraints) {
      final side = math.min(constraints.maxWidth,
          fullScreen ? constraints.maxHeight : constraints.maxWidth);
      return Center(
        child: SizedBox(
          width: side,
          height: side,
          child: InteractiveViewer(
            maxScale: 6,
            minScale: 1,
            boundaryMargin: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => _showInfo(context),
              child: CustomPaint(
                size: Size(side, side),
                painter: _CohenPainter(
                  ph: widget.ph,
                  hco3: widget.hco3,
                  lang: _lang,
                  brightness: Theme.of(context).brightness,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _openFullScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(_lang == NomogramLang.en
              ? 'Acid–Base Nomogram'
              : '酸塩基平衡ノモグラム'),
          actions: [
            TextButton(
              onPressed: _toggleLang,
              child: Text(
                _lang == NomogramLang.en ? '日本語' : 'EN',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: _chart(context, fullScreen: true),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _toggleLang,
              icon: const Icon(Icons.translate, size: 18),
              label: Text(_lang == NomogramLang.en ? '日本語' : 'EN'),
            ),
            IconButton(
              tooltip: _lang == NomogramLang.en ? 'Full screen' : '全画面',
              icon: const Icon(Icons.fullscreen),
              onPressed: _openFullScreen,
            ),
          ],
        ),
        AspectRatio(
          aspectRatio: 1,
          child: _chart(context, fullScreen: false),
        ),
        Text(
          _lang == NomogramLang.en
              ? 'Tap the chart to show values / pinch to zoom.'
              : 'グラフをタップで数値表示 / ピンチでズーム。',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _RegionLabel {
  final String en;
  final String ja;
  final double ph;
  final double hco3;
  final Color color;
  final bool italic;
  final double rotationDeg;
  final double fontSize;

  /// maxWidth をプロット幅に対する割合で指定（帯域幅の約 80% を目安）。
  final double widthFactor;

  /// プロット枠内に座標をクランプするか（混合域ラベル用）。
  final bool clamp;

  const _RegionLabel(this.en, this.ja, this.ph, this.hco3, this.color,
      {this.italic = false,
      this.rotationDeg = 0,
      this.fontSize = 10,
      this.widthFactor = 0.24,
      this.clamp = false});
}

class _CohenPainter extends CustomPainter {
  final double ph;
  final double hco3;
  final NomogramLang lang;
  final Brightness brightness;

  _CohenPainter({
    required this.ph,
    required this.hco3,
    required this.lang,
    required this.brightness,
  });

  static const double minPh = 7.0;
  static const double maxPh = 7.8;
  static const double minHco3 = 0;
  static const double maxHco3 = 60;

  // 余白
  static const double mLeft = 44;
  static const double mRight = 44;
  static const double mTop = 52;
  static const double mBottom = 34;

  /// ラベルのフォント（バンドル日本語フォント）。CustomPainter 内の TextStyle は
  /// テーマの fontFamily を継承しないため明示する。
  static const String _font = 'NotoSansJP';

  late Rect _plot;

  double _x(double ph) =>
      _plot.left + (ph - minPh) / (maxPh - minPh) * _plot.width;
  double _y(double hco3) =>
      _plot.bottom - (hco3 - minHco3) / (maxHco3 - minHco3) * _plot.height;
  Offset _p(double ph, double h) => Offset(_x(ph), _y(h));

  static double _log10(double x) => math.log(x) / math.ln10;
  static double _phFrom(double hco3, double pco2) =>
      6.1 + _log10(hco3 / (0.03 * pco2));
  static double _hco3From(double ph, double pco2) =>
      0.03 * pco2 * math.pow(10, ph - 6.1);

  @override
  void paint(Canvas canvas, Size size) {
    _plot = Rect.fromLTRB(
        mLeft, mTop, size.width - mRight, size.height - mBottom);

    final isDark = brightness == Brightness.dark;
    final ink = isDark ? Colors.white70 : Colors.black87;

    // 背景
    canvas.drawRect(Offset.zero & size,
        Paint()..color = isDark ? const Color(0xFF1A1C1E) : Colors.white);

    canvas.save();
    canvas.clipRect(_plot);
    _drawBands(canvas);
    _drawIsobars(canvas, ink);
    _drawNormal(canvas);
    _drawPatient(canvas);
    canvas.restore();

    _drawAxes(canvas, size, ink);
    _drawLabels(canvas);
    _drawIsobarLabels(canvas, ink);
  }

  // ---- 信頼帯 ----
  void _fillPoly(Canvas canvas, List<Offset> dataPts, Color color) {
    if (dataPts.isEmpty) return;
    final path = Path()..moveTo(_x(dataPts.first.dx), _y(dataPts.first.dy));
    for (final o in dataPts.skip(1)) {
      path.lineTo(_x(o.dx), _y(o.dy));
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  /// 呼吸性: PCO2 をパラメータに中心線 ± 幅で帯を作る。
  List<Offset> _respBand(double pcoLo, double pcoHi,
      double Function(double) center, double Function(double) halfW) {
    final up = <Offset>[];
    final lo = <Offset>[];
    const n = 24;
    for (var i = 0; i <= n; i++) {
      final pco = pcoLo + (pcoHi - pcoLo) * i / n;
      final c = center(pco);
      final hw = halfW(pco);
      final hu = c + hw, hl = c - hw;
      up.add(Offset(_phFrom(hu, pco), hu));
      lo.add(Offset(_phFrom(hl, pco), hl));
    }
    return [...up, ...lo.reversed];
  }

  /// 代謝性: HCO3 をパラメータに、期待 PCO2 ± 幅で帯を作る。
  List<Offset> _metBand(double hLo, double hHi,
      double Function(double) centerPco, double halfWpco) {
    final left = <Offset>[];
    final right = <Offset>[];
    const n = 24;
    for (var i = 0; i <= n; i++) {
      final h = hLo + (hHi - hLo) * i / n;
      final pc = centerPco(h);
      left.add(Offset(_phFrom(h, pc - halfWpco), h));
      right.add(Offset(_phFrom(h, pc + halfWpco), h));
    }
    return [...left, ...right.reversed];
  }

  void _drawBands(Canvas canvas) {
    // 代謝性アシドーシス（赤）
    _fillPoly(canvas, _metBand(3, 21, (h) => 1.5 * h + 8, 2.5),
        const Color(0x4DE53935));
    // 代謝性アルカローシス（青）
    _fillPoly(canvas, _metBand(27, 53, (h) => 0.7 * h + 21, 3.5),
        const Color(0x4D1E88E5));
    // 急性呼吸性アシドーシス（オレンジ）
    _fillPoly(
        canvas,
        _respBand(41, 90, (p) => 24 + (p - 40) / 10,
            (p) => 1.4 + 0.04 * (p - 40)),
        const Color(0x4DFB8C00));
    // 慢性呼吸性アシドーシス（黄）
    _fillPoly(
        canvas,
        _respBand(41, 95, (p) => 24 + 3.5 * (p - 40) / 10,
            (p) => 1.6 + 0.06 * (p - 40)),
        const Color(0x4DFDD835));
    // 急性呼吸性アルカローシス（水色）
    _fillPoly(
        canvas,
        _respBand(15, 39, (p) => 24 - 2 * (40 - p) / 10,
            (p) => 1.2 + 0.045 * (40 - p)),
        const Color(0x4D4DD0E1));
    // 慢性呼吸性アルカローシス（緑）
    _fillPoly(
        canvas,
        _respBand(12, 39, (p) => 24 - 5 * (40 - p) / 10,
            (p) => 1.2 + 0.06 * (40 - p)),
        const Color(0x4D43A047));
  }

  void _drawNormal(Canvas canvas) {
    final c = _p(7.40, 24);
    final rx = (0.035 / (maxPh - minPh)) * _plot.width;
    final ry = (4.0 / (maxHco3 - minHco3)) * _plot.height;
    final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
        rect,
        Paint()
          ..color = (brightness == Brightness.dark
              ? const Color(0xFF1A1C1E)
              : Colors.white));
    canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.black54);
  }

  void _drawPatient(Canvas canvas) {
    final c = _p(ph.clamp(minPh, maxPh), hco3.clamp(minHco3, maxHco3));
    // 視認性向上のため、白い輪郭を先に描いてから赤●を重ねる。
    canvas.drawCircle(
        c,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white);
    canvas.drawCircle(c, 8, Paint()..color = Colors.white);
    canvas.drawCircle(c, 6, Paint()..color = Colors.red);
  }

  // ---- PCO2 等圧線 ----
  void _drawIsobars(Canvas canvas, Color ink) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (final pco in const [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]) {
      final pts = <Offset>[];
      for (double p = minPh; p <= maxPh + 1e-9; p += 0.01) {
        final h = _hco3From(p, pco.toDouble());
        if (h >= minHco3 && h <= maxHco3) pts.add(_p(p, h));
      }
      _dashedPolyline(canvas, pts, paint);
    }
  }

  void _dashedPolyline(Canvas canvas, List<Offset> pts, Paint paint,
      {double dash = 6, double gap = 4}) {
    if (pts.length < 2) return;
    var draw = true;
    var remaining = dash;
    for (var i = 0; i < pts.length - 1; i++) {
      var a = pts[i];
      final b = pts[i + 1];
      var segLen = (b - a).distance;
      final dir = segLen == 0 ? Offset.zero : (b - a) / segLen;
      while (segLen > 0) {
        final step = math.min(remaining, segLen);
        final next = a + dir * step;
        if (draw) canvas.drawLine(a, next, paint);
        a = next;
        segLen -= step;
        remaining -= step;
        if (remaining <= 0) {
          draw = !draw;
          remaining = draw ? dash : gap;
        }
      }
    }
  }

  void _drawIsobarLabels(Canvas canvas, Color ink) {
    for (final pco in const [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]) {
      // 上端(HCO3=60)との交点 or 右端(pH=7.8)で交わる方にラベル。
      final hAtRight = _hco3From(maxPh, pco.toDouble());
      double lx, ly;
      if (hAtRight <= maxHco3) {
        lx = _x(maxPh) + 2;
        ly = _y(hAtRight) - 5;
      } else {
        final phAtTop = _phFrom(maxHco3, pco.toDouble());
        lx = _x(phAtTop) - 6;
        ly = _y(maxHco3) - 12;
      }
      _text(canvas, '$pco', Offset(lx, ly),
          color: ink, size: 8, anchorLeft: true);
    }
  }

  // ---- 軸 ----
  void _drawAxes(Canvas canvas, Size size, Color ink) {
    final axis = Paint()
      ..color = ink
      ..strokeWidth = 1;
    final grid = Paint()
      ..color = ink.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    canvas.drawRect(_plot,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = ink
          ..strokeWidth = 1);

    // 下軸: pH
    for (var i = 0; i <= 8; i++) {
      final ph = 7.0 + i * 0.1;
      final x = _x(ph);
      canvas.drawLine(Offset(x, _plot.top), Offset(x, _plot.bottom), grid);
      canvas.drawLine(
          Offset(x, _plot.bottom), Offset(x, _plot.bottom + 4), axis);
      _text(canvas, ph.toStringAsFixed(1), Offset(x, _plot.bottom + 6),
          color: ink, size: 9, center: true);
    }
    _text(
        canvas,
        lang == NomogramLang.en ? 'Arterial blood pH' : '動脈血 pH',
        Offset(_plot.center.dx, size.height - 11),
        color: ink,
        size: 9,
        center: true);

    // 左軸: HCO3
    for (var h = 0; h <= 60; h += 4) {
      final y = _y(h.toDouble());
      canvas.drawLine(Offset(_plot.left, y), Offset(_plot.right, y), grid);
      canvas.drawLine(Offset(_plot.left - 4, y), Offset(_plot.left, y), axis);
      _text(canvas, '$h', Offset(_plot.left - 6, y),
          color: ink, size: 9, anchorRight: true, middle: true);
    }
    _textRotated(
        canvas,
        lang == NomogramLang.en
            ? 'Arterial plasma [HCO3-] (mmol/L)'
            : '動脈血漿 [HCO3-] (mmol/L)',
        Offset(10, _plot.center.dy),
        color: ink,
        size: 9,
        angle: -math.pi / 2);

    // 上軸: [H+] nmol/L（20–100 のみ）。
    // [H+] = 10^(9-pH) nmol/L → 逆算 pH = 9 - log10([H+]) で座標変換。
    // ラベルが重ならないよう最小間隔 20px を確保し、収まらない分は間引く。
    final hEntries = <MapEntry<int, double>>[];
    for (final h in const [20, 30, 40, 50, 60, 70, 80, 90, 100]) {
      final ph = 9 - _log10(h.toDouble());
      if (ph < minPh || ph > maxPh) continue;
      hEntries.add(MapEntry(h, _x(ph)));
    }
    hEntries.sort((a, b) => a.value.compareTo(b.value));
    double? lastX;
    for (final e in hEntries) {
      if (lastX != null && (e.value - lastX).abs() < 20) continue;
      lastX = e.value;
      canvas.drawLine(
          Offset(e.value, _plot.top), Offset(e.value, _plot.top - 4), axis);
      _text(canvas, '${e.key}', Offset(e.value, _plot.top - 13),
          color: ink, size: 9, center: true);
    }
    _text(
        canvas,
        lang == NomogramLang.en
            ? 'Arterial blood [H+] (nmol/L)'
            : '動脈血 [H+] (nmol/L)',
        Offset(_plot.center.dx, 4),
        color: ink,
        size: 9,
        center: true);

    // 右軸タイトル: pCO2
    _textRotated(canvas, 'pCO2 (mmHg)', Offset(size.width - 8, _plot.center.dy),
        color: ink, size: 9, angle: math.pi / 2);
  }

  // ---- 帯域・混合のラベル ----
  // 主要障害名（10pt・指定の回転角）。
  static const List<_RegionLabel> _mainLabels = [
    _RegionLabel('Metabolic\nacidosis', '代謝性\nアシドーシス', 7.18, 10,
        Colors.black87, rotationDeg: 0, widthFactor: 0.24),
    _RegionLabel('Metabolic\nalkalosis', '代謝性\nアルカローシス', 7.56, 42,
        Colors.black87, rotationDeg: 0, widthFactor: 0.26),
    _RegionLabel('Acute\nrespiratory\nacidosis', '急性\n呼吸性\nアシドーシス', 7.275,
        29, Colors.black87, rotationDeg: -30, widthFactor: 0.28),
    _RegionLabel('Chronic\nrespiratory\nacidosis', '慢性\n呼吸性\nアシドーシス', 7.32,
        38, Colors.black87, rotationDeg: -20, widthFactor: 0.30),
    _RegionLabel('Acute\nrespiratory\nalkalosis', '急性\n呼吸性\nアルカローシス', 7.52,
        21, Colors.black87, rotationDeg: 0, widthFactor: 0.24),
    _RegionLabel('Chronic\nrespiratory\nalkalosis', '慢性\n呼吸性\nアルカローシス',
        7.56, 15, Colors.black87, rotationDeg: 20, widthFactor: 0.26),
  ];

  // 混合・代償不全（8pt・赤・斜体、枠内クランプ）。
  static const List<_RegionLabel> _mixedLabels = [
    _RegionLabel('Mixed\nResp.Acid.\n& Met. Alk.', '混合\n呼吸性アシ\n＋代謝性アルカ',
        7.305, 51, Colors.red,
        italic: true, fontSize: 8, widthFactor: 0.22, clamp: true),
    _RegionLabel('Met.Alk.\nw/o expected\nResp. comp.', '代謝性アルカ\n代償不全なし',
        7.64, 50, Colors.red,
        italic: true, fontSize: 8, widthFactor: 0.22, clamp: true),
    _RegionLabel('Mixed\nResp. & Met.\nAlkalosis', '混合\n呼吸性＋代謝性\nアルカローシス',
        7.63, 31, Colors.red,
        italic: true, fontSize: 8, rotationDeg: -30, widthFactor: 0.22,
        clamp: true),
    _RegionLabel('Acute on\nChronic\nResp. Alk.', '急性 on 慢性\n呼吸性アルカ', 7.66,
        12, Colors.red,
        italic: true, fontSize: 8, rotationDeg: -58, widthFactor: 0.20,
        clamp: true),
    _RegionLabel('Mixed\nMet.Acid.\n& Resp.Alk.', '混合\n代謝性アシ\n＋呼吸性アルカ',
        7.45, 6, Colors.red,
        italic: true, fontSize: 8, widthFactor: 0.22, clamp: true),
    _RegionLabel('Mixed\nResp. & Met.\nAcidosis', '混合\n呼吸性＋代謝性\nアシドーシス',
        7.135, 20, Colors.red,
        italic: true, fontSize: 8, rotationDeg: -52, widthFactor: 0.22,
        clamp: true),
    _RegionLabel('Met.Acid.\nw/o expected\nresp. comp.', '代謝性アシ\n代償不全なし',
        7.10, 8, Colors.red,
        italic: true, fontSize: 8, widthFactor: 0.20, clamp: true),
    _RegionLabel('Acute on\nChronic\nResp. Acid.', '急性 on 慢性\n呼吸性アシ', 7.215,
        34, Colors.red,
        italic: true, fontSize: 8, rotationDeg: -32, widthFactor: 0.20,
        clamp: true),
  ];

  Offset _labelPos(_RegionLabel l) {
    var pos = _p(l.ph, l.hco3);
    if (l.clamp) {
      pos = Offset(
        pos.dx.clamp(_plot.left + 4, _plot.right - 4),
        pos.dy.clamp(_plot.top + 4, _plot.bottom - 4),
      );
    }
    return pos;
  }

  void _drawLabel(Canvas canvas, _RegionLabel l) {
    final pos = _labelPos(l);
    final text = lang == NomogramLang.en ? l.en : l.ja;
    _text(canvas, text, pos,
        color: l.color,
        size: l.fontSize,
        center: true,
        middle: true,
        italic: l.italic,
        angle: l.rotationDeg * math.pi / 180,
        maxWidth: l.widthFactor * _plot.width);
  }

  void _drawLabels(Canvas canvas) {
    for (final l in _mixedLabels) {
      _drawLabel(canvas, l);
    }
    for (final l in _mainLabels) {
      _drawLabel(canvas, l);
    }
    _drawNormalLabel(canvas);
  }

  /// 「Normal」は正常楕円の右横（+8px）に配置し、プロット点と分離する。
  void _drawNormalLabel(Canvas canvas) {
    final center = _p(7.40, 24);
    final rx = (0.035 / (maxPh - minPh)) * _plot.width;
    final pos = Offset(center.dx + rx + 8, center.dy);
    _text(canvas, lang == NomogramLang.en ? 'Normal' : '正常', pos,
        color: Colors.black87, size: 10, anchorLeft: true, middle: true);
  }

  // ---- テキスト描画ヘルパ ----
  void _text(Canvas canvas, String s, Offset at,
      {required Color color,
      double size = 9,
      bool center = false,
      bool middle = false,
      bool anchorRight = false,
      bool anchorLeft = false,
      bool italic = false,
      double angle = 0,
      double? maxWidth}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: color,
              fontSize: size,
              height: 1.05,
              fontFamily: _font,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? double.infinity);
    var dx = at.dx;
    var dy = at.dy;
    if (center) dx -= tp.width / 2;
    if (middle) dy -= tp.height / 2;
    if (anchorRight) dx -= tp.width;
    if (anchorRight && !middle) dy -= tp.height / 2;
    if (anchorLeft && !middle) dy -= tp.height / 2;
    if (angle != 0) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(angle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    } else {
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  void _textRotated(Canvas canvas, String s, Offset at,
      {required Color color, double size = 9, required double angle}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(color: color, fontSize: size, fontFamily: _font)),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CohenPainter old) =>
      old.ph != ph ||
      old.hco3 != hco3 ||
      old.lang != lang ||
      old.brightness != brightness;
}
