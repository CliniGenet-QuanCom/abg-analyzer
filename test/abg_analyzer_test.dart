import 'package:blood_gas_analyzer/data/reference_ranges.dart';
import 'package:blood_gas_analyzer/l10n/app_l.dart';
import 'package:blood_gas_analyzer/l10n/app_l_en.dart';
import 'package:blood_gas_analyzer/l10n/app_l_ja.dart';
import 'package:blood_gas_analyzer/logic/abg_analyzer.dart';
import 'package:blood_gas_analyzer/models/abg_input.dart';
import 'package:flutter_test/flutter_test.dart';

/// テストでは日本語ロケールで検証する。
const AppL _l = AppLJa();

void main() {
  group('Step 1-3 一次性障害と代償', () {
    test('純粋な代謝性アシドーシス + 適切な呼吸性代償 (Winters)', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.30, paco2: 26, hco3: 12),
          l: _l);
      expect(r.primaryDiagnosis, _l.dxMetAcidosis);
      final comp = r.sections.firstWhere((s) => s.title.contains('Step 3'));
      expect(comp.lines.any((l) => l.text.contains('適切な呼吸性代償')), isTrue);
    });

    test('代謝性アシドーシスで PaCO2 高すぎ → 呼吸性アシドーシス合併', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.20, paco2: 40, hco3: 12),
          l: _l);
      expect(r.primaryDiagnosis, _l.dxMetAcidosis);
      expect(r.clinicalSuggestions.contains(_l.sugMixedRespAcidosis), isTrue);
    });

    test('急性呼吸性アシドーシス', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.28, paco2: 60, hco3: 26),
          l: _l);
      expect(r.primaryDiagnosis, _l.dxRespAcidosis);
      final comp = r.sections.firstWhere((s) => s.title.contains('Step 3'));
      expect(comp.lines.any((l) => l.text.contains('急性')), isTrue);
    });

    test('慢性呼吸性アシドーシス', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.36, paco2: 60, hco3: 31),
          l: _l);
      expect(r.primaryDiagnosis, _l.dxRespAcidosis);
      final comp = r.sections.firstWhere((s) => s.title.contains('Step 3'));
      expect(comp.lines.any((l) => l.text.contains('慢性')), isTrue);
    });

    test('代謝性アルカローシス', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.52, paco2: 46, hco3: 36),
          l: _l);
      expect(r.primaryDiagnosis, _l.dxMetAlkalosis);
    });

    test('正常 ABG', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.40, paco2: 40, hco3: 24),
          l: _l);
      expect(r.primaryDiagnosis, _l.dxNormal);
    });
  });

  group('Step 4-5 AG とデルタ比', () {
    test('AG 開大の計算とアルブミン補正', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.20, paco2: 25, hco3: 10, na: 140, cl: 100),
          l: _l);
      final ag = r.sections.firstWhere((s) => s.title.contains('Step 4'));
      expect(ag.lines.any((l) => l.text.contains('30')), isTrue);
      expect(ag.lines.any((l) => l.text.contains('AG 開大')), isTrue);
    });

    test('アルブミン補正で AG が開大に転じる', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(
              ph: 7.30, paco2: 30, hco3: 16, na: 140, cl: 114, albumin: 2.0),
          l: _l);
      final ag = r.sections.firstWhere((s) => s.title.contains('Step 4'));
      expect(ag.lines.any((l) => l.text.contains('補正 AG')), isTrue);
      expect(ag.lines.any((l) => l.text.contains('開大')), isTrue);
    });

    test('デルタ比 約1 → 純粋 AG 開大性', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.30, paco2: 30, hco3: 14, na: 140, cl: 100),
          l: _l);
      final d = r.sections.firstWhere((s) => s.title.contains('Step 5'));
      expect(d.lines.any((l) => l.text.contains('Δ比')), isTrue);
    });
  });

  group('Step 6 酸素化', () {
    test('P/F 比と ARDS 分類', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.40, paco2: 40, hco3: 24, pao2: 80, fio2: 50),
          l: _l);
      final ox = r.sections.firstWhere((s) => s.title.contains('Step 6'));
      expect(ox.lines.any((l) => l.text.contains('P/F 比')), isTrue);
      expect(ox.lines.any((l) => l.text.contains('中等症')), isTrue);
      expect(ox.lines.any((l) => l.text.contains('A-aDO2')), isTrue);
    });

    test('室内気 P/F 比は正常域', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.40, paco2: 40, hco3: 24, pao2: 95, fio2: 21),
          l: _l);
      final ox = r.sections.firstWhere((s) => s.title.contains('Step 6'));
      expect(ox.lines.any((l) => l.text.contains('正常')), isTrue);
    });
  });

  group('静脈血 (VBG) モード', () {
    test('VBG 正常値は正常判定', () {
      final r = AbgAnalyzer.analyze(
        const AbgInput(ph: 7.36, paco2: 46, hco3: 24),
        l: _l,
        ranges: ReferenceRanges.adultVenous,
      );
      expect(r.primaryDiagnosis, _l.dxNormal);
      expect(r.modeNote, _l.venousModeNote);
    });

    test('同じ値でも動脈血基準では正常でない', () {
      const input = AbgInput(ph: 7.33, paco2: 48, hco3: 24);
      final venous = AbgAnalyzer.analyze(input,
          l: _l, ranges: ReferenceRanges.adultVenous);
      final arterial =
          AbgAnalyzer.analyze(input, l: _l, ranges: ReferenceRanges.adult);
      expect(venous.primaryDiagnosis, _l.dxNormal);
      expect(arterial.primaryDiagnosis, isNot(_l.dxNormal));
    });

    test('VBG モードでは酸素化評価が非適用', () {
      final r = AbgAnalyzer.analyze(
        const AbgInput(ph: 7.36, paco2: 46, hco3: 24, pao2: 40, fio2: 21),
        l: _l,
        ranges: ReferenceRanges.adultVenous,
      );
      final ox = r.sections.firstWhere((s) => s.title.contains('Step 6'));
      expect(ox.lines.any((l) => l.text.contains('適用しません')), isTrue);
      expect(ox.lines.any((l) => l.text.contains('ARDS')), isFalse);
      expect(ox.lines.any((l) => l.text.contains('P/F 比 =')), isFalse);
    });

    test('PvCO2 ラベルと代償ロジック流用', () {
      final r = AbgAnalyzer.analyze(
        const AbgInput(ph: 7.50, paco2: 52, hco3: 36),
        l: _l,
        ranges: ReferenceRanges.adultVenous,
      );
      final s1 = r.sections.firstWhere((s) => s.title.contains('Step 1'));
      expect(s1.lines.any((l) => l.text.contains('PvCO2')), isTrue);
      expect(r.primaryDiagnosis, _l.dxMetAlkalosis);
    });
  });

  group('多言語', () {
    test('英語ロケールでは英語の診断名を返す', () {
      const en = AppLEn();
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.30, paco2: 26, hco3: 12),
          l: en);
      expect(r.primaryDiagnosis, en.dxMetAcidosis);
      expect(r.primaryDiagnosis, 'Metabolic acidosis');
    });

    test('共有テキストはロケールのヘッダ/診断を含む', () {
      final r = AbgAnalyzer.analyze(
          const AbgInput(ph: 7.30, paco2: 26, hco3: 12),
          l: _l);
      final txt = r.toShareText(_l);
      expect(txt, contains(_l.shareHeader));
      expect(txt, contains(_l.dxMetAcidosis));
    });
  });
}
