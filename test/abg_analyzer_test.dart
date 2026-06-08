import 'package:blood_gas_analyzer/data/reference_ranges.dart';
import 'package:blood_gas_analyzer/logic/abg_analyzer.dart';
import 'package:blood_gas_analyzer/models/abg_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Step 1-3 一次性障害と代償', () {
    test('純粋な代謝性アシドーシス + 適切な呼吸性代償 (Winters)', () {
      // HCO3 12 → Winters 期待 PaCO2 = 1.5*12+8 = 26 ±2、実測 26 で適切
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.30,
        paco2: 26,
        hco3: 12,
      ));
      expect(r.primaryDiagnosis, '代謝性アシドーシス');
      final comp = r.sections.firstWhere((s) => s.title.contains('Step 3'));
      expect(comp.lines.any((l) => l.text.contains('適切な呼吸性代償')), isTrue);
    });

    test('代謝性アシドーシスで PaCO2 高すぎ → 呼吸性アシドーシス合併', () {
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.20,
        paco2: 40, // 期待 26 より高い
        hco3: 12,
      ));
      expect(r.primaryDiagnosis, '代謝性アシドーシス');
      expect(
          r.clinicalSuggestions
              .any((s) => s.contains('呼吸性アシドーシスを合併')),
          isTrue);
    });

    test('急性呼吸性アシドーシス', () {
      // PaCO2 60 → 急性期待 HCO3 = 24 + (60-40)/10 = 26
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.28,
        paco2: 60,
        hco3: 26,
      ));
      expect(r.primaryDiagnosis, '呼吸性アシドーシス');
      final comp = r.sections.firstWhere((s) => s.title.contains('Step 3'));
      expect(comp.lines.any((l) => l.text.contains('急性')), isTrue);
    });

    test('慢性呼吸性アシドーシス', () {
      // PaCO2 60 → 慢性期待 HCO3 = 24 + 3.5*2 = 31
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.36,
        paco2: 60,
        hco3: 31,
      ));
      expect(r.primaryDiagnosis, '呼吸性アシドーシス');
      final comp = r.sections.firstWhere((s) => s.title.contains('Step 3'));
      expect(comp.lines.any((l) => l.text.contains('慢性')), isTrue);
    });

    test('代謝性アルカローシス', () {
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.52,
        paco2: 46,
        hco3: 36,
      ));
      expect(r.primaryDiagnosis, '代謝性アルカローシス');
    });

    test('正常 ABG', () {
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.40,
        paco2: 40,
        hco3: 24,
      ));
      expect(r.primaryDiagnosis, contains('正常'));
    });
  });

  group('Step 4-5 AG とデルタ比', () {
    test('AG 開大の計算とアルブミン補正', () {
      // Na140 Cl100 HCO3 10 → AG = 30
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.20,
        paco2: 25,
        hco3: 10,
        na: 140,
        cl: 100,
      ));
      final ag = r.sections.firstWhere((s) => s.title.contains('Step 4'));
      expect(ag.lines.any((l) => l.text.contains('30')), isTrue);
      expect(ag.lines.any((l) => l.text.contains('AG 開大')), isTrue);
    });

    test('アルブミン補正で AG が開大に転じる', () {
      // 測定 AG = 10 (正常域) だが Alb 2.0 → 補正 +5 = 15 開大
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.30,
        paco2: 30,
        hco3: 16,
        na: 140,
        cl: 114,
        albumin: 2.0,
      ));
      final ag = r.sections.firstWhere((s) => s.title.contains('Step 4'));
      expect(ag.lines.any((l) => l.text.contains('補正 AG')), isTrue);
      expect(ag.lines.any((l) => l.text.contains('開大')), isTrue);
    });

    test('デルタ比 約1 → 純粋 AG 開大性', () {
      // AG = 140-(100+14)=26 → ΔAG=14、ΔHCO3=24-14=10 → 比 1.4
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.30,
        paco2: 30,
        hco3: 14,
        na: 140,
        cl: 100,
      ));
      final d = r.sections.firstWhere((s) => s.title.contains('Step 5'));
      expect(d.lines.any((l) => l.text.contains('Δ比')), isTrue);
    });
  });

  group('Step 6 酸素化', () {
    test('P/F 比と ARDS 分類', () {
      // PaO2 80, FiO2 50% → P/F = 160 中等症
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.40,
        paco2: 40,
        hco3: 24,
        pao2: 80,
        fio2: 50,
      ));
      final ox = r.sections.firstWhere((s) => s.title.contains('Step 6'));
      expect(ox.lines.any((l) => l.text.contains('P/F 比')), isTrue);
      expect(ox.lines.any((l) => l.text.contains('中等症')), isTrue);
      expect(ox.lines.any((l) => l.text.contains('A-aDO2')), isTrue);
    });

    test('室内気 P/F 比は正常域', () {
      // PaO2 95, FiO2 21 → P/F ≈ 452
      final r = AbgAnalyzer.analyze(const AbgInput(
        ph: 7.40,
        paco2: 40,
        hco3: 24,
        pao2: 95,
        fio2: 21,
      ));
      final ox = r.sections.firstWhere((s) => s.title.contains('Step 6'));
      expect(ox.lines.any((l) => l.text.contains('正常')), isTrue);
    });
  });

  group('静脈血 (VBG) モード', () {
    test('VBG 正常値（pH 7.36 / PvCO2 46 / HCO3 24）は正常判定', () {
      final r = AbgAnalyzer.analyze(
        const AbgInput(ph: 7.36, paco2: 46, hco3: 24),
        ranges: ReferenceRanges.adultVenous,
      );
      expect(r.primaryDiagnosis, contains('正常'));
      expect(r.modeNote, '静脈血（VBG）モード');
    });

    test('同じ値でも動脈血基準ではアシドーシス/高CO2に振れる', () {
      const input = AbgInput(ph: 7.33, paco2: 48, hco3: 24);
      final venous = AbgAnalyzer.analyze(input,
          ranges: ReferenceRanges.adultVenous);
      final arterial =
          AbgAnalyzer.analyze(input, ranges: ReferenceRanges.adult);
      // 静脈基準では pH 7.33 は正常域(7.31-7.41)
      expect(venous.primaryDiagnosis, contains('正常'));
      // 動脈基準では pH 7.33 はアシデミア
      expect(arterial.primaryDiagnosis, isNot(contains('正常')));
    });

    test('VBG モードでは酸素化評価が非適用と表示される', () {
      final r = AbgAnalyzer.analyze(
        const AbgInput(ph: 7.36, paco2: 46, hco3: 24, pao2: 40, fio2: 21),
        ranges: ReferenceRanges.adultVenous,
      );
      final ox = r.sections.firstWhere((s) => s.title.contains('Step 6'));
      expect(ox.lines.any((l) => l.text.contains('適用しません')), isTrue);
      // ARDS 分類や P/F 比の算出値は出さない
      expect(ox.lines.any((l) => l.text.contains('ARDS')), isFalse);
      expect(ox.lines.any((l) => l.text.contains('P/F 比 =')), isFalse);
    });

    test('PvCO2 ラベルと代償ロジック流用（CO2高値の代謝性代償）', () {
      // 静脈: HCO3 36 高値 → 代謝性アルカローシス、CO2ラベルはPvCO2
      final r = AbgAnalyzer.analyze(
        const AbgInput(ph: 7.50, paco2: 52, hco3: 36),
        ranges: ReferenceRanges.adultVenous,
      );
      final s1 = r.sections.firstWhere((s) => s.title.contains('Step 1'));
      expect(s1.lines.any((l) => l.text.contains('PvCO2')), isTrue);
      expect(r.primaryDiagnosis, '代謝性アルカローシス');
    });

    test('共有テキストに静脈血モード注記が入る', () {
      final r = AbgAnalyzer.analyze(
        const AbgInput(ph: 7.30, paco2: 60, hco3: 24),
        ranges: ReferenceRanges.adultVenous,
      );
      expect(r.toShareText(), contains('静脈血（VBG）モード'));
    });
  });

  test('共有テキストに一次診断が含まれる', () {
    final r = AbgAnalyzer.analyze(const AbgInput(
      ph: 7.30,
      paco2: 26,
      hco3: 12,
    ));
    expect(r.toShareText(), contains('一次診断'));
    expect(r.toShareText(), contains('代謝性アシドーシス'));
  });
}
