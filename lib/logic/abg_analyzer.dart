import 'dart:math' as math;

import '../data/reference_ranges.dart';
import '../models/abg_input.dart';
import '../models/abg_result.dart';

/// 一次性（原発性）障害の分類。
enum PrimaryDisorder {
  normal,
  metabolicAcidosis,
  metabolicAlkalosis,
  respiratoryAcidosis,
  respiratoryAlkalosis,
}

/// ABG 解釈エンジン。Step 1〜6 を順に評価する。
///
/// 代償式・基準値は成人の標準的な値（PaCO2 基準 40 mmHg、HCO3- 基準 24 mEq/L、
/// AG 基準 12 mEq/L）を用いる。
class AbgAnalyzer {
  static const double _paco2Ref = 40;
  static const double _hco3Ref = 24;
  static const double _agRef = 12;

  /// 範囲を ±2 の許容で丸めた文字列。
  static String _fmt(double v, {int digits = 1}) =>
      v.toStringAsFixed(digits);

  static AbgResult analyze(AbgInput input,
      {ReferenceRanges ranges = ReferenceRanges.adult}) {
    final sections = <ResultSection>[];
    final suggestions = <String>[];

    // ---- Step 1: 一次性異常の判定 ----
    final acidemia = input.ph < ranges.phLow;
    final alkalemia = input.ph > ranges.phHigh;

    final phSeverity = acidemia
        ? Severity.acidosis
        : (alkalemia ? Severity.alkalosis : Severity.normal);
    final phLabel = acidemia
        ? 'アシデミア (pH ${_fmt(input.ph, digits: 2)} < ${ranges.phLow})'
        : alkalemia
            ? 'アルカレミア (pH ${_fmt(input.ph, digits: 2)} > ${ranges.phHigh})'
            : '正常 pH (${_fmt(input.ph, digits: 2)})';

    final paco2Abn = _abnLabel(input.paco2, ranges.paco2Low, ranges.paco2High,
        ranges.co2Label, 'mmHg');
    final hco3Abn =
        _abnLabel(input.hco3, ranges.hco3Low, ranges.hco3High, 'HCO3-', 'mEq/L');

    sections.add(ResultSection(
      title: 'Step 1: 一次性異常の判定',
      severity: phSeverity,
      lines: [
        ResultLine(phLabel, phSeverity),
        ResultLine(paco2Abn.text, paco2Abn.severity),
        ResultLine(hco3Abn.text, hco3Abn.severity),
      ],
    ));

    // ---- Step 2: 原発性障害の分類 ----
    final respAcidosis = input.paco2 > ranges.paco2High;
    final respAlkalosis = input.paco2 < ranges.paco2Low;
    final metAcidosis = input.hco3 < ranges.hco3Low;
    final metAlkalosis = input.hco3 > ranges.hco3High;

    final primary = _determinePrimary(
      input: input,
      ranges: ranges,
      acidemia: acidemia,
      alkalemia: alkalemia,
      respAcidosis: respAcidosis,
      respAlkalosis: respAlkalosis,
      metAcidosis: metAcidosis,
      metAlkalosis: metAlkalosis,
    );

    final primaryLabel = _primaryLabel(primary);
    final primarySeverity = _primarySeverity(primary);

    // 同時に逆方向の一次性障害（混合性）が存在するか
    final mixedPrimaryNotes = <ResultLine>[];
    if (acidemia && respAcidosis && metAcidosis) {
      mixedPrimaryNotes.add(const ResultLine(
          '呼吸性アシドーシス＋代謝性アシドーシスの混合性障害が疑われます。',
          Severity.warning));
    }
    if (alkalemia && respAlkalosis && metAlkalosis) {
      mixedPrimaryNotes.add(const ResultLine(
          '呼吸性アルカローシス＋代謝性アルカローシスの混合性障害が疑われます。',
          Severity.warning));
    }

    sections.add(ResultSection(
      title: 'Step 2: 原発性障害の分類',
      severity: primarySeverity,
      lines: [
        ResultLine('原発性障害: $primaryLabel', primarySeverity),
        ...mixedPrimaryNotes,
      ],
    ));

    // ---- Step 3: 代償の評価 ----
    final compSection = _evaluateCompensation(input, primary, ranges);
    sections.add(compSection.section);
    suggestions.addAll(compSection.suggestions);

    // ---- Step 4: アニオンギャップ ----
    double? correctedAg;
    if (input.hasAnionGapInputs) {
      final agSection = _evaluateAnionGap(input, ranges);
      sections.add(agSection.section);
      correctedAg = agSection.correctedAg;
      suggestions.addAll(agSection.suggestions);
    } else {
      sections.add(const ResultSection(
        title: 'Step 4: アニオンギャップ (AG)',
        severity: Severity.info,
        lines: [
          ResultLine('Na・Cl が未入力のため AG は計算できません。', Severity.info),
        ],
      ));
    }

    // ---- Step 5: デルタ比 ----
    if (correctedAg != null) {
      final deltaSection = _evaluateDeltaRatio(input, correctedAg);
      sections.add(deltaSection.section);
      suggestions.addAll(deltaSection.suggestions);
    } else {
      sections.add(const ResultSection(
        title: 'Step 5: デルタ比 (Δ/Δ)',
        severity: Severity.info,
        lines: [
          ResultLine('AG が計算できないためデルタ比は評価できません。', Severity.info),
        ],
      ));
    }

    // ---- Step 6: 酸素化評価 ----
    final oxySection = _evaluateOxygenation(input, ranges);
    sections.add(oxySection.section);
    suggestions.addAll(oxySection.suggestions);

    // ---- 温度補正（任意・参考） ----
    final tempSection = _temperatureCorrection(input);
    if (tempSection != null) sections.add(tempSection);

    // ---- 臨床的示唆（原発性障害に基づく鑑別） ----
    suggestions.addAll(_differentials(primary, correctedAg, ranges));

    // ---- 静脈血モードの注記 ----
    String? modeNote;
    if (ranges.venous) {
      modeNote = '静脈血（VBG）モード';
      // 解析モードのセクションを先頭に挿入
      sections.insert(
        0,
        const ResultSection(
          title: '解析モード: 静脈血（VBG）',
          severity: Severity.warning,
          lines: [
            ResultLine(
                '静脈血の正常値（pH 7.31–7.41 / PvCO2 41–51 / HCO3- 22–26）で判定しています。',
                Severity.info),
            ResultLine('代償の評価は動脈血と同じ計算ロジックを流用しています。',
                Severity.info),
            ResultLine(
                '酸素化評価（P/F 比・A-aDO2）は動脈血の指標のため、静脈血モードでは適用されません。',
                Severity.warning),
            ResultLine(
                '※ VBG と ABG では特に PCO2 に乖離があり得ます。確定的判断には動脈血での確認を考慮してください。',
                Severity.info),
          ],
        ),
      );
      suggestions.add(
          '静脈血での解釈です。pH・HCO3- は動脈血とよく相関しますが、PvCO2 は PaCO2 より高めに出ます。');
    }

    return AbgResult(
      primaryDiagnosis: primaryLabel,
      primarySeverity: primarySeverity,
      sections: sections,
      clinicalSuggestions: suggestions,
      modeNote: modeNote,
    );
  }

  // -------------------------------------------------------------------------

  static _Abn _abnLabel(
      double v, double low, double high, String name, String unit) {
    if (v < low) {
      return _Abn('$name $v $unit（低値, 正常 $low–$high）', Severity.warning);
    } else if (v > high) {
      return _Abn('$name $v $unit（高値, 正常 $low–$high）', Severity.warning);
    }
    return _Abn('$name $v $unit（正常 $low–$high）', Severity.normal);
  }

  static PrimaryDisorder _determinePrimary({
    required AbgInput input,
    required ReferenceRanges ranges,
    required bool acidemia,
    required bool alkalemia,
    required bool respAcidosis,
    required bool respAlkalosis,
    required bool metAcidosis,
    required bool metAlkalosis,
  }) {
    if (acidemia) {
      // pH に整合する障害を原発とみなす（両方あれば、より大きな偏位＝メインを優先）。
      if (respAcidosis && metAcidosis) {
        // 混合。原発はより寄与の大きい方を返す（偏位の標準化で比較）。
        return _largerContribution(input, isAcidosis: true);
      }
      if (metAcidosis) return PrimaryDisorder.metabolicAcidosis;
      if (respAcidosis) return PrimaryDisorder.respiratoryAcidosis;
      // 一次性異常が PaCO2/HCO3- に出ていないが酸血症 → 寄与の大きい方
      return _largerContribution(input, isAcidosis: true);
    }
    if (alkalemia) {
      if (respAlkalosis && metAlkalosis) {
        return _largerContribution(input, isAcidosis: false);
      }
      if (metAlkalosis) return PrimaryDisorder.metabolicAlkalosis;
      if (respAlkalosis) return PrimaryDisorder.respiratoryAlkalosis;
      return _largerContribution(input, isAcidosis: false);
    }
    // pH 正常域
    if (!respAcidosis &&
        !respAlkalosis &&
        !metAcidosis &&
        !metAlkalosis) {
      return PrimaryDisorder.normal;
    }
    // pH 正常だが PaCO2/HCO3- が異常 → 代償性 or 混合性。
    // pH 7.40 を境に、低め寄りはアシドーシス系、高め寄りはアルカローシス系を原発とみなす。
    final acidLeaning = input.ph <= 7.40;
    if (acidLeaning) {
      if (metAcidosis) return PrimaryDisorder.metabolicAcidosis;
      if (respAcidosis) return PrimaryDisorder.respiratoryAcidosis;
    } else {
      if (metAlkalosis) return PrimaryDisorder.metabolicAlkalosis;
      if (respAlkalosis) return PrimaryDisorder.respiratoryAlkalosis;
    }
    return _largerContribution(input, isAcidosis: acidLeaning);
  }

  /// PaCO2 と HCO3- のどちらの偏位が大きいかで原発を推定する。
  static PrimaryDisorder _largerContribution(AbgInput input,
      {required bool isAcidosis}) {
    final respDev = (input.paco2 - _paco2Ref).abs();
    final metDev = (input.hco3 - _hco3Ref).abs();
    if (isAcidosis) {
      return respDev >= metDev
          ? PrimaryDisorder.respiratoryAcidosis
          : PrimaryDisorder.metabolicAcidosis;
    } else {
      return respDev >= metDev
          ? PrimaryDisorder.respiratoryAlkalosis
          : PrimaryDisorder.metabolicAlkalosis;
    }
  }

  static String _primaryLabel(PrimaryDisorder d) {
    switch (d) {
      case PrimaryDisorder.normal:
        return '正常範囲（明らかな酸塩基異常なし）';
      case PrimaryDisorder.metabolicAcidosis:
        return '代謝性アシドーシス';
      case PrimaryDisorder.metabolicAlkalosis:
        return '代謝性アルカローシス';
      case PrimaryDisorder.respiratoryAcidosis:
        return '呼吸性アシドーシス';
      case PrimaryDisorder.respiratoryAlkalosis:
        return '呼吸性アルカローシス';
    }
  }

  static Severity _primarySeverity(PrimaryDisorder d) {
    switch (d) {
      case PrimaryDisorder.normal:
        return Severity.normal;
      case PrimaryDisorder.metabolicAcidosis:
      case PrimaryDisorder.respiratoryAcidosis:
        return Severity.acidosis;
      case PrimaryDisorder.metabolicAlkalosis:
      case PrimaryDisorder.respiratoryAlkalosis:
        return Severity.alkalosis;
    }
  }

  // ---- Step 3 本体 ----
  static _SectionResult _evaluateCompensation(
      AbgInput input, PrimaryDisorder primary, ReferenceRanges ranges) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    switch (primary) {
      case PrimaryDisorder.metabolicAcidosis:
        {
          // Winters 式: 期待 PaCO2 = 1.5×HCO3- + 8 ± 2
          final exp = 1.5 * input.hco3 + 8;
          lines.add(ResultLine(
              'Winters 式 期待 PaCO2 = ${_fmt(exp)} ± 2 mmHg '
              '(実測 ${_fmt(input.paco2)})',
              Severity.info));
          _judgeRespCompensation(
              input.paco2, exp, lines, suggestions);
          break;
        }
      case PrimaryDisorder.metabolicAlkalosis:
        {
          // 期待 PaCO2 = 0.7×HCO3- + 21 ± 2
          final exp = 0.7 * input.hco3 + 21;
          lines.add(ResultLine(
              '期待 PaCO2 = 0.7×HCO3- + 21 = ${_fmt(exp)} ± 2 mmHg '
              '(実測 ${_fmt(input.paco2)})',
              Severity.info));
          _judgeRespCompensation(
              input.paco2, exp, lines, suggestions);
          break;
        }
      case PrimaryDisorder.respiratoryAcidosis:
        {
          final acute = _hco3Ref + (input.paco2 - 40) / 10;
          final chronic = _hco3Ref + 3.5 * (input.paco2 - 40) / 10;
          lines.add(ResultLine(
              '急性 期待 HCO3- = ${_fmt(acute)} / 慢性 期待 HCO3- = ${_fmt(chronic)} mEq/L '
              '(実測 ${_fmt(input.hco3)})',
              Severity.info));
          _judgeMetCompensationForResp(
              input.hco3, acute, chronic, lines, suggestions,
              acidosis: true);
          break;
        }
      case PrimaryDisorder.respiratoryAlkalosis:
        {
          final acute = _hco3Ref - 2 * (40 - input.paco2) / 10;
          final chronic = _hco3Ref - 5 * (40 - input.paco2) / 10;
          lines.add(ResultLine(
              '急性 期待 HCO3- = ${_fmt(acute)} / 慢性 期待 HCO3- = ${_fmt(chronic)} mEq/L '
              '(実測 ${_fmt(input.hco3)})',
              Severity.info));
          _judgeMetCompensationForResp(
              input.hco3, acute, chronic, lines, suggestions,
              acidosis: false);
          break;
        }
      case PrimaryDisorder.normal:
        lines.add(const ResultLine('原発性障害がないため代償評価は不要です。', Severity.normal));
        break;
    }

    return _SectionResult(
      section: ResultSection(
        title: 'Step 3: 代償の評価',
        severity: lines.any((l) => l.severity == Severity.warning)
            ? Severity.warning
            : Severity.info,
        lines: lines,
      ),
      suggestions: suggestions,
    );
  }

  static void _judgeRespCompensation(double actual, double expected,
      List<ResultLine> lines, List<String> suggestions) {
    if (actual > expected + 2) {
      lines.add(const ResultLine(
          '実測 PaCO2 が期待より高い → 呼吸性代償が不十分、または呼吸性アシドーシスの合併。',
          Severity.warning));
      suggestions.add('代謝性障害に呼吸性アシドーシスを合併した混合性障害の可能性。');
    } else if (actual < expected - 2) {
      lines.add(const ResultLine(
          '実測 PaCO2 が期待より低い → 過剰代償、または呼吸性アルカローシスの合併。',
          Severity.warning));
      suggestions.add('代謝性障害に呼吸性アルカローシスを合併した混合性障害の可能性。');
    } else {
      lines.add(const ResultLine('適切な呼吸性代償あり（期待範囲内）。', Severity.normal));
    }
  }

  static void _judgeMetCompensationForResp(double actual, double acute,
      double chronic, List<ResultLine> lines, List<String> suggestions,
      {required bool acidosis}) {
    final lo = math.min(acute, chronic) - 2;
    final hi = math.max(acute, chronic) + 2;
    if (actual >= lo && actual <= hi) {
      // 急性寄りか慢性寄りか
      final nearAcute = (actual - acute).abs() <= (actual - chronic).abs();
      lines.add(ResultLine(
          '実測 HCO3- は期待範囲内 → ${nearAcute ? '急性' : '慢性'}に近い適切な代謝性代償。',
          Severity.normal));
    } else if (actual > hi) {
      lines.add(const ResultLine(
          '実測 HCO3- が期待より高い → 代謝性アルカローシスの合併が疑われます。',
          Severity.warning));
      suggestions.add('呼吸性障害に代謝性アルカローシスを合併した混合性障害の可能性。');
    } else {
      lines.add(const ResultLine(
          '実測 HCO3- が期待より低い → 代謝性アシドーシスの合併が疑われます。',
          Severity.warning));
      suggestions.add('呼吸性障害に代謝性アシドーシスを合併した混合性障害の可能性。');
    }
  }

  // ---- Step 4 本体 ----
  static _AgResult _evaluateAnionGap(AbgInput input, ReferenceRanges ranges) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    final ag = input.na! - (input.cl! + input.hco3);
    final alb = input.albumin ?? 4.0;
    final correctedAg = ag + 2.5 * (4.0 - alb);

    lines.add(ResultLine(
        'AG = Na - (Cl + HCO3-) = ${_fmt(ag)} mEq/L（正常 ${ranges.agLow}–${ranges.agHigh}）',
        Severity.info));
    if (input.albumin != null && input.albumin != 4.0) {
      lines.add(ResultLine(
          'アルブミン補正 AG = ${_fmt(correctedAg)} mEq/L（Alb ${_fmt(alb)} g/dL）',
          Severity.info));
    }

    final effectiveAg = correctedAg;
    if (effectiveAg > ranges.agHigh) {
      lines.add(ResultLine(
          'AG 開大（${_fmt(effectiveAg)} > ${ranges.agHigh}）→ AG 開大性代謝性アシドーシスを示唆。',
          Severity.acidosis));
      suggestions.add(
          'AG 開大性代謝性アシドーシスの鑑別: 乳酸アシドーシス, ケトアシドーシス, 腎不全(尿毒症), 中毒(メタノール/エチレングリコール/サリチル酸) 等。');
    } else if (effectiveAg < ranges.agLow) {
      lines.add(ResultLine(
          'AG 低値（${_fmt(effectiveAg)} < ${ranges.agLow}）→ 低アルブミン血症・高Ca/Mg・パラプロテイン血症などを考慮。',
          Severity.warning));
    } else {
      lines.add(ResultLine('AG 正常（${_fmt(effectiveAg)}）。', Severity.normal));
    }

    return _AgResult(
      section: ResultSection(
        title: 'Step 4: アニオンギャップ (AG)',
        severity: effectiveAg > ranges.agHigh
            ? Severity.acidosis
            : Severity.info,
        lines: lines,
      ),
      correctedAg: correctedAg,
      suggestions: suggestions,
    );
  }

  // ---- Step 5 本体 ----
  static _SectionResult _evaluateDeltaRatio(
      AbgInput input, double correctedAg) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    final deltaAg = correctedAg - _agRef; // ΔAG = AG - 12
    final deltaHco3 = _hco3Ref - input.hco3; // ΔHCO3- = 24 - HCO3-

    lines.add(ResultLine(
        'ΔAG = ${_fmt(deltaAg)}、ΔHCO3- = ${_fmt(deltaHco3)}', Severity.info));

    if (deltaAg <= 0) {
      lines.add(const ResultLine(
          'AG 開大がないためデルタ比の解釈は限定的です。', Severity.info));
      return _SectionResult(
        section: ResultSection(
          title: 'Step 5: デルタ比 (Δ/Δ)',
          severity: Severity.info,
          lines: lines,
        ),
        suggestions: suggestions,
      );
    }

    if (deltaHco3.abs() < 0.0001) {
      lines.add(const ResultLine(
          'ΔHCO3- ≒ 0 のため比は計算できません。', Severity.info));
    } else {
      final ratio = deltaAg / deltaHco3;
      lines.add(ResultLine('Δ比 = ΔAG / ΔHCO3- = ${_fmt(ratio, digits: 2)}',
          Severity.info));

      if (ratio < 0.4) {
        lines.add(const ResultLine(
            '< 0.4 → 正常 AG 代謝性アシドーシスの合併を示唆。', Severity.warning));
        suggestions.add('AG 開大性に正常 AG（高Cl性）代謝性アシドーシスを合併。');
      } else if (ratio < 1.0) {
        lines.add(const ResultLine(
            '0.4–1.0 → AG 開大性と正常 AG 代謝性アシドーシスの混合型。', Severity.warning));
        suggestions.add('AG 開大性＋正常 AG 代謝性アシドーシスの混合。');
      } else if (ratio <= 2.0) {
        lines.add(const ResultLine(
            '1.0–2.0 → 純粋な AG 開大性代謝性アシドーシスとして矛盾しない。', Severity.normal));
      } else {
        lines.add(const ResultLine(
            '> 2.0 → 代謝性アルカローシス、または慢性呼吸性アシドーシスの合併を示唆。',
            Severity.warning));
        suggestions.add('AG 開大性代謝性アシドーシスに代謝性アルカローシス（または慢性呼吸性アシドーシス）を合併。');
      }
    }

    return _SectionResult(
      section: ResultSection(
        title: 'Step 5: デルタ比 (Δ/Δ)',
        severity: lines.any((l) => l.severity == Severity.warning)
            ? Severity.warning
            : Severity.info,
        lines: lines,
      ),
      suggestions: suggestions,
    );
  }

  // ---- Step 6 本体 ----
  static _SectionResult _evaluateOxygenation(
      AbgInput input, ReferenceRanges ranges) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    // 静脈血モードでは酸素化評価（P/F 比・A-aDO2）は適用しない。
    if (ranges.venous) {
      lines.add(const ResultLine(
          '静脈血モードのため酸素化評価（P/F 比・A-aDO2）は適用しません。',
          Severity.warning));
      if (input.pao2 != null) {
        lines.add(ResultLine(
            '参考: ${ranges.o2Label} = ${_fmt(input.pao2!)} mmHg（静脈血の値は酸素化指標として用いません）',
            Severity.info));
      }
      return _SectionResult(
        section: ResultSection(
          title: 'Step 6: 酸素化評価',
          severity: Severity.warning,
          lines: lines,
        ),
        suggestions: suggestions,
      );
    }

    if (input.pao2 == null) {
      lines.add(const ResultLine('PaO2 が未入力のため酸素化評価はできません。', Severity.info));
      return _SectionResult(
        section: const ResultSection(
          title: 'Step 6: 酸素化評価',
          severity: Severity.info,
          lines: [ResultLine('PaO2 が未入力のため酸素化評価はできません。', Severity.info)],
        ),
        suggestions: suggestions,
      );
    }

    final pao2 = input.pao2!;
    lines.add(ResultLine(
        'PaO2 = ${_fmt(pao2)} mmHg'
        '${pao2 < ranges.pao2Low ? '（低酸素血症: 正常下限 ${ranges.pao2Low}）' : ''}',
        pao2 < ranges.pao2Low ? Severity.warning : Severity.normal));

    if (input.hasOxygenationInputs) {
      final fio2Frac = input.fio2! / 100.0;
      final pf = pao2 / fio2Frac;
      String pfLabel;
      Severity pfSev;
      if (pf >= 300) {
        pfLabel = '正常〜軽度';
        pfSev = Severity.normal;
      } else if (pf >= 200) {
        pfLabel = '軽症 ARDS 域 (200–299)';
        pfSev = Severity.warning;
      } else if (pf >= 100) {
        pfLabel = '中等症 ARDS 域 (100–199)';
        pfSev = Severity.warning;
      } else {
        pfLabel = '重症 ARDS 域 (<100)';
        pfSev = Severity.acidosis;
      }
      lines.add(ResultLine(
          'P/F 比 = PaO2 / FiO2 = ${_fmt(pf, digits: 0)} → $pfLabel', pfSev));
      if (pf < 300) {
        suggestions.add(
            'P/F 比低下（$pfLabel）。ARDS の診断には PEEP≥5cmH2O・両側陰影・心原性除外など Berlin 基準の確認が必要。');
      }

      // A-aDO2（海面・R=0.8 を仮定）
      final pAO2 = fio2Frac * (760 - 47) - input.paco2 / 0.8;
      final aado2 = pAO2 - pao2;
      lines.add(ResultLine(
          'A-aDO2 ≒ ${_fmt(aado2, digits: 0)} mmHg（PAO2 ${_fmt(pAO2, digits: 0)} − PaO2、海面/R=0.8 仮定）',
          Severity.info));
    } else {
      lines.add(const ResultLine(
          'FiO2 未入力のため P/F 比・A-aDO2 は計算できません。', Severity.info));
    }

    return _SectionResult(
      section: ResultSection(
        title: 'Step 6: 酸素化評価',
        severity: lines.any((l) => l.severity == Severity.acidosis)
            ? Severity.acidosis
            : (lines.any((l) => l.severity == Severity.warning)
                ? Severity.warning
                : Severity.normal),
        lines: lines,
      ),
      suggestions: suggestions,
    );
  }

  // ---- 温度補正（参考表示） ----
  static ResultSection? _temperatureCorrection(AbgInput input) {
    final t = input.temperature;
    if (t == null || t == 37) return null;
    final dT = t - 37;
    final phCorr = input.ph - 0.0146 * dT;
    final paco2Corr = input.paco2 * math.pow(10, 0.019 * dT);
    final lines = <ResultLine>[
      ResultLine('体温 ${_fmt(t)}℃ での参考補正値（解釈本体は 37℃ 値で実施）:',
          Severity.info),
      ResultLine('  補正 pH ≒ ${_fmt(phCorr, digits: 2)}', Severity.info),
      ResultLine('  補正 PaCO2 ≒ ${_fmt(paco2Corr.toDouble())} mmHg',
          Severity.info),
      const ResultLine('  ※ 温度補正は alpha-stat/pH-stat の議論があり、施設方針に従ってください。',
          Severity.info),
    ];
    if (input.pao2 != null) {
      final pao2Corr = input.pao2! * math.pow(10, 0.024 * dT);
      lines.insert(
          3,
          ResultLine('  補正 PaO2 ≒ ${_fmt(pao2Corr.toDouble())} mmHg',
              Severity.info));
    }
    return ResultSection(
      title: '参考: 体温補正',
      severity: Severity.info,
      lines: lines,
    );
  }

  // ---- 鑑別診断 ----
  static List<String> _differentials(
      PrimaryDisorder primary, double? correctedAg, ReferenceRanges ranges) {
    switch (primary) {
      case PrimaryDisorder.respiratoryAcidosis:
        return [
          '呼吸性アシドーシスの鑑別: COPD増悪, 呼吸抑制(鎮静薬/オピオイド), 神経筋疾患, 胸郭/気道閉塞, 換気不全。',
        ];
      case PrimaryDisorder.respiratoryAlkalosis:
        return [
          '呼吸性アルカローシスの鑑別: 過換気(不安/疼痛), 低酸素, 肺塞栓, 敗血症, 肝不全, サリチル酸中毒, 妊娠。',
        ];
      case PrimaryDisorder.metabolicAlkalosis:
        return [
          '代謝性アルカローシスの鑑別: 嘔吐/胃液喪失, 利尿薬, 低K血症, ミネラルコルチコイド過剰, アルカリ過剰投与。',
        ];
      case PrimaryDisorder.metabolicAcidosis:
        if (correctedAg != null && correctedAg <= ranges.agHigh) {
          return [
            '正常 AG（高Cl性）代謝性アシドーシスの鑑別: 下痢, 尿細管性アシドーシス(RTA), 生理食塩水大量投与, 炭酸脱水酵素阻害薬。',
          ];
        }
        return [
          'AG 開大性代謝性アシドーシスの鑑別(GOLDMARK/MUDPILES): 乳酸, ケトン体, 腎不全, メタノール/エチレングリコール/サリチル酸 等。',
        ];
      case PrimaryDisorder.normal:
        return [];
    }
  }
}

// ---- 内部用ヘルパークラス ----
class _Abn {
  final String text;
  final Severity severity;
  _Abn(this.text, this.severity);
}

class _SectionResult {
  final ResultSection section;
  final List<String> suggestions;
  _SectionResult({required this.section, required this.suggestions});
}

class _AgResult {
  final ResultSection section;
  final double correctedAg;
  final List<String> suggestions;
  _AgResult(
      {required this.section,
      required this.correctedAg,
      required this.suggestions});
}
