import 'package:blood_gas_analyzer/services/ocr_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2 列レイアウト用に、ラベル要素と数値要素を同一 Y 行で生成するヘルパ。
OcrElement _el(String text, double left, double y) => OcrElement(
      text: text,
      left: left,
      top: y,
      right: left + text.length * 18,
      bottom: y + 40,
    );

void main() {
  group('基本（プレーンテキスト経路）', () {
    test('PaCO2 と PaO2 を取り違えない', () {
      final v = AbgOcrParser.extract('pCO2 60\npO2 70');
      expect(v['paco2'], 60);
      expect(v['pao2'], 70);
    });

    test('FiO2 が割合(0.5)なら % に換算', () {
      expect(AbgOcrParser.extract('FiO2 0.5')['fio2'], 50);
    });

    test('範囲外の誤認識値は不採用', () {
      expect(AbgOcrParser.extract('pH 735')['ph'], isNull);
    });

    test('全角・コロン区切り', () {
      final v = AbgOcrParser.extract('ｐＨ：７．３５　ＰａＣＯ２：４０');
      expect(v['ph'], 7.35);
      expect(v['paco2'], 40);
    });
  });

  group('形式1: モニター撮影（2列・座標ベース）', () {
    test('項目名列と数値列を Y 座標で対応付ける', () {
      // 左列=項目名、右列(x=300)=数値。同一 Y で別要素。
      final els = <OcrElement>[
        _el('項目名', 20, 0), _el('結果', 300, 0),
        _el('PO2', 20, 100), _el('59.40', 300, 100),
        _el('PCO2', 20, 200), _el('40.10', 300, 200),
        _el('HCO3', 20, 300), _el('25.00', 300, 300),
        _el('PH', 20, 400), _el('7.40', 300, 400),
        _el('O2・Satura', 20, 500), _el('92.70', 300, 500),
        _el('Base Exces', 20, 600), _el('0.30', 300, 600),
        _el('Total CO2', 20, 700), _el('58.80', 300, 700),
        _el('tHb', 20, 800), _el('17.80', 300, 800),
        _el('O2-Hb', 20, 900), _el('92.00', 300, 900),
        _el('Lac', 20, 1000), _el('1.00', 300, 1000),
      ];
      final v = AbgOcrParser.extractFromElements(els);
      expect(v['pao2'], 59.40);
      expect(v['paco2'], 40.10);
      expect(v['hco3'], 25.00);
      expect(v['ph'], 7.40);
      expect(v['be'], 0.30);
      expect(v['lac'], 1.00);
      expect(v['hb'], 17.80); // tHb（O2-Hb ではない）
      expect(v['na'], isNull);
      expect(v['cl'], isNull);
      expect(v['fio2'], isNull);
    });
  });

  group('形式2: i-STAT 感熱紙（空白区切り）', () {
    const text = '''
i-STAT CG8+
Pt:---
Pt Name:______
37.0°C
pH        7.338
PCO2      38.3 mmHg
PO2       95 mmHg
BEecf     -5 mmol/L
HCO3      20.6 mmol/L
TCO2      22 mmol/L
sO2       75 %
Na        137 mmol/L
K         4.4 mmol/L
iCa       1.32 mmol/L
Glu       83 mg/dL
Hct       36 %PCV
Hb*       12.2 g/dL
CLEW: A52
''';
    test('項目と数値を抽出', () {
      final v = AbgOcrParser.extract(text);
      expect(v['ph'], 7.338);
      expect(v['paco2'], 38.3);
      expect(v['pao2'], 95);
      expect(v['be'], -5);
      expect(v['hco3'], 20.6);
      expect(v['na'], 137);
      expect(v['hb'], 12.2);
    });
    test('存在しない Cl は CLEW を誤検出しない', () {
      expect(AbgOcrParser.extract(text)['cl'], isNull);
    });
    test('Pt Name 行の "Na" を誤検出しない', () {
      expect(AbgOcrParser.extract(text)['na'], 137);
    });
  });

  group('形式3: ABL90 感熱紙（日本語項目名＋数値）', () {
    const text = '''
ラジオメーター ABL90シリーズ
患者測定
T          37.0 °C
FO2(I)     21.0 %
血液ガス値
pH         7.322
pCO2       42.1 mmHg
pO2        18.0 mmHg
ctHb       15.7 g/dL
Hct,c      48.2 %
sO2        34.1 %
FO2Hb      33.3 %
電解質値
cK+        4.3 mmol/L
cNa+       135 mmol/L
cCa2+      1.31 mmol/L
cCl-       104 mmol/L
Anion Gap,c 8.9 mmol/L
cGlu       84 mg/dL
cLac       5.3 mmol/L
ctBil      1.1 mg/dL
cHCO3-(P),c     21.8 mmol/L
cHCO3-(P,st),c  19.5 mmol/L
cBase(B),c      -4.2 mmol/L
cBase(Ecf),c    -4.3 mmol/L
''';
    test('全項目を抽出', () {
      final v = AbgOcrParser.extract(text);
      expect(v['ph'], 7.322);
      expect(v['paco2'], 42.1);
      expect(v['pao2'], 18.0);
      expect(v['fio2'], 21.0);
      expect(v['na'], 135);
      expect(v['cl'], 104);
      expect(v['lac'], 5.3);
      expect(v['hb'], 15.7);
    });
    test('HCO3 は actual(21.8)を採用（standardized 19.5 ではない）', () {
      expect(AbgOcrParser.extract(text)['hco3'], 21.8);
    });
    test('BE は cBase(B)(-4.2)を採用', () {
      expect(AbgOcrParser.extract(text)['be'], -4.2);
    });
    test('FO2(I) を FiO2 とし、FO2Hb を誤検出しない', () {
      expect(AbgOcrParser.extract(text)['fio2'], 21.0);
    });
  });
}
