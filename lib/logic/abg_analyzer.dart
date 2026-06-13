import 'dart:math' as math;

import '../data/reference_ranges.dart';
import '../l10n/app_l.dart';
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
/// 出力テキストは [AppL] により多言語化する。代償式・基準値は成人の標準的な値
/// （PaCO2 基準 40 mmHg、HCO3- 基準 24 mEq/L、AG 基準 12 mEq/L）を用いる。
class AbgAnalyzer {
  static const double _paco2Ref = 40;
  static const double _hco3Ref = 24;
  static const double _agRef = 12;

  static String _fmt(double v, {int digits = 1}) => v.toStringAsFixed(digits);

  static AbgResult analyze(
    AbgInput input, {
    required AppL l,
    ReferenceRanges ranges = ReferenceRanges.adult,
  }) {
    final sections = <ResultSection>[];
    final suggestions = <String>[];

    // ---- Step 1: 一次性異常の判定 ----
    final acidemia = input.ph < ranges.phLow;
    final alkalemia = input.ph > ranges.phHigh;

    final phSeverity = acidemia
        ? Severity.acidosis
        : (alkalemia ? Severity.alkalosis : Severity.normal);
    final phLabel = acidemia
        ? l.phAcidemia(_fmt(input.ph, digits: 2), '${ranges.phLow}')
        : alkalemia
            ? l.phAlkalemia(_fmt(input.ph, digits: 2), '${ranges.phHigh}')
            : l.phNormal(_fmt(input.ph, digits: 2));

    final paco2Abn = _abnLabel(l, input.paco2, ranges.paco2Low,
        ranges.paco2High, ranges.co2Label, 'mmHg');
    final hco3Abn = _abnLabel(
        l, input.hco3, ranges.hco3Low, ranges.hco3High, 'HCO3-', 'mEq/L');

    sections.add(ResultSection(
      title: l.step1Title,
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
      acidemia: acidemia,
      alkalemia: alkalemia,
      respAcidosis: respAcidosis,
      respAlkalosis: respAlkalosis,
      metAcidosis: metAcidosis,
      metAlkalosis: metAlkalosis,
    );

    final primaryLabel = _primaryLabel(l, primary);
    final primarySeverity = _primarySeverity(primary);

    final mixedPrimaryNotes = <ResultLine>[];
    if (acidemia && respAcidosis && metAcidosis) {
      mixedPrimaryNotes
          .add(ResultLine(l.mixedRespMetAcidosis, Severity.warning));
    }
    if (alkalemia && respAlkalosis && metAlkalosis) {
      mixedPrimaryNotes
          .add(ResultLine(l.mixedRespMetAlkalosis, Severity.warning));
    }

    sections.add(ResultSection(
      title: l.step2Title,
      severity: primarySeverity,
      lines: [
        ResultLine(l.primaryDisorderLine(primaryLabel), primarySeverity),
        ...mixedPrimaryNotes,
      ],
    ));

    // ---- Step 3: 代償の評価 ----
    final compSection = _evaluateCompensation(l, input, primary);
    sections.add(compSection.section);
    suggestions.addAll(compSection.suggestions);

    // ---- Step 4: アニオンギャップ ----
    double? correctedAg;
    if (input.hasAnionGapInputs) {
      final agSection = _evaluateAnionGap(l, input, ranges);
      sections.add(agSection.section);
      correctedAg = agSection.correctedAg;
      suggestions.addAll(agSection.suggestions);
    } else {
      sections.add(ResultSection(
        title: l.step4Title,
        severity: Severity.info,
        lines: [ResultLine(l.agNotAvailable, Severity.info)],
      ));
    }

    // ---- Step 5: デルタ比 ----
    if (correctedAg != null) {
      final deltaSection = _evaluateDeltaRatio(l, input, correctedAg);
      sections.add(deltaSection.section);
      suggestions.addAll(deltaSection.suggestions);
    } else {
      sections.add(ResultSection(
        title: l.step5Title,
        severity: Severity.info,
        lines: [ResultLine(l.deltaNotAvailable, Severity.info)],
      ));
    }

    // ---- Step 6: 酸素化評価 ----
    final oxySection = _evaluateOxygenation(l, input, ranges);
    sections.add(oxySection.section);
    suggestions.addAll(oxySection.suggestions);

    // ---- 温度補正（任意・参考） ----
    final tempSection = _temperatureCorrection(l, input);
    if (tempSection != null) sections.add(tempSection);

    // ---- 臨床的示唆（原発性障害に基づく鑑別） ----
    suggestions.addAll(_differentials(l, primary, correctedAg, ranges));

    // ---- 静脈血モードの注記 ----
    String? modeNote;
    if (ranges.venous) {
      modeNote = l.venousModeNote;
      sections.insert(
        0,
        ResultSection(
          title: l.analysisModeVenousTitle,
          severity: Severity.warning,
          lines: [
            ResultLine(l.venousModeLine1, Severity.info),
            ResultLine(l.venousModeLine2, Severity.info),
            ResultLine(l.venousModeLine3, Severity.warning),
            ResultLine(l.venousModeLine4, Severity.info),
          ],
        ),
      );
      suggestions.add(l.sugVenous);
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

  static _Abn _abnLabel(AppL l, double v, double low, double high, String name,
      String unit) {
    if (v < low) {
      return _Abn(l.abnLow(name, '$v', unit, '$low', '$high'), Severity.warning);
    } else if (v > high) {
      return _Abn(
          l.abnHigh(name, '$v', unit, '$low', '$high'), Severity.warning);
    }
    return _Abn(
        l.abnNormal(name, '$v', unit, '$low', '$high'), Severity.normal);
  }

  static PrimaryDisorder _determinePrimary({
    required AbgInput input,
    required bool acidemia,
    required bool alkalemia,
    required bool respAcidosis,
    required bool respAlkalosis,
    required bool metAcidosis,
    required bool metAlkalosis,
  }) {
    if (acidemia) {
      if (respAcidosis && metAcidosis) {
        return _largerContribution(input, isAcidosis: true);
      }
      if (metAcidosis) return PrimaryDisorder.metabolicAcidosis;
      if (respAcidosis) return PrimaryDisorder.respiratoryAcidosis;
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
    if (!respAcidosis && !respAlkalosis && !metAcidosis && !metAlkalosis) {
      return PrimaryDisorder.normal;
    }
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

  static String _primaryLabel(AppL l, PrimaryDisorder d) {
    switch (d) {
      case PrimaryDisorder.normal:
        return l.dxNormal;
      case PrimaryDisorder.metabolicAcidosis:
        return l.dxMetAcidosis;
      case PrimaryDisorder.metabolicAlkalosis:
        return l.dxMetAlkalosis;
      case PrimaryDisorder.respiratoryAcidosis:
        return l.dxRespAcidosis;
      case PrimaryDisorder.respiratoryAlkalosis:
        return l.dxRespAlkalosis;
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
      AppL l, AbgInput input, PrimaryDisorder primary) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    switch (primary) {
      case PrimaryDisorder.metabolicAcidosis:
        {
          final exp = 1.5 * input.hco3 + 8;
          lines.add(ResultLine(
              l.wintersExpected(_fmt(exp), _fmt(input.paco2)), Severity.info));
          _judgeRespCompensation(l, input.paco2, exp, lines, suggestions);
          break;
        }
      case PrimaryDisorder.metabolicAlkalosis:
        {
          final exp = 0.7 * input.hco3 + 21;
          lines.add(ResultLine(
              l.metAlkExpected(_fmt(exp), _fmt(input.paco2)), Severity.info));
          _judgeRespCompensation(l, input.paco2, exp, lines, suggestions);
          break;
        }
      case PrimaryDisorder.respiratoryAcidosis:
        {
          final acute = _hco3Ref + (input.paco2 - 40) / 10;
          final chronic = _hco3Ref + 3.5 * (input.paco2 - 40) / 10;
          lines.add(ResultLine(
              l.respExpectedAcuteChronic(
                  _fmt(acute), _fmt(chronic), _fmt(input.hco3)),
              Severity.info));
          _judgeMetCompensationForResp(
              l, input.hco3, acute, chronic, lines, suggestions);
          break;
        }
      case PrimaryDisorder.respiratoryAlkalosis:
        {
          final acute = _hco3Ref - 2 * (40 - input.paco2) / 10;
          final chronic = _hco3Ref - 5 * (40 - input.paco2) / 10;
          lines.add(ResultLine(
              l.respExpectedAcuteChronic(
                  _fmt(acute), _fmt(chronic), _fmt(input.hco3)),
              Severity.info));
          _judgeMetCompensationForResp(
              l, input.hco3, acute, chronic, lines, suggestions);
          break;
        }
      case PrimaryDisorder.normal:
        lines.add(ResultLine(l.noCompNeeded, Severity.normal));
        break;
    }

    return _SectionResult(
      section: ResultSection(
        title: l.step3Title,
        severity: lines.any((x) => x.severity == Severity.warning)
            ? Severity.warning
            : Severity.info,
        lines: lines,
      ),
      suggestions: suggestions,
    );
  }

  static void _judgeRespCompensation(AppL l, double actual, double expected,
      List<ResultLine> lines, List<String> suggestions) {
    if (actual > expected + 2) {
      lines.add(ResultLine(l.respCompHigh, Severity.warning));
      suggestions.add(l.sugMixedRespAcidosis);
    } else if (actual < expected - 2) {
      lines.add(ResultLine(l.respCompLow, Severity.warning));
      suggestions.add(l.sugMixedRespAlkalosis);
    } else {
      lines.add(ResultLine(l.respCompAppropriate, Severity.normal));
    }
  }

  static void _judgeMetCompensationForResp(AppL l, double actual, double acute,
      double chronic, List<ResultLine> lines, List<String> suggestions) {
    final lo = math.min(acute, chronic) - 2;
    final hi = math.max(acute, chronic) + 2;
    if (actual >= lo && actual <= hi) {
      final nearAcute = (actual - acute).abs() <= (actual - chronic).abs();
      lines.add(ResultLine(
          l.metCompAppropriate(nearAcute ? l.phaseAcute : l.phaseChronic),
          Severity.normal));
    } else if (actual > hi) {
      lines.add(ResultLine(l.metCompHigh, Severity.warning));
      suggestions.add(l.sugRespWithMetAlk);
    } else {
      lines.add(ResultLine(l.metCompLow, Severity.warning));
      suggestions.add(l.sugRespWithMetAcid);
    }
  }

  // ---- Step 4 本体 ----
  static _AgResult _evaluateAnionGap(
      AppL l, AbgInput input, ReferenceRanges ranges) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    final ag = input.na! - (input.cl! + input.hco3);
    final alb = input.albumin ?? 4.0;
    final correctedAg = ag + 2.5 * (4.0 - alb);

    lines.add(ResultLine(
        l.agFormula(_fmt(ag), '${ranges.agLow}', '${ranges.agHigh}'),
        Severity.info));
    if (input.albumin != null && input.albumin != 4.0) {
      lines.add(ResultLine(
          l.agAlbCorrected(_fmt(correctedAg), _fmt(alb)), Severity.info));
    }

    final effectiveAg = correctedAg;
    if (effectiveAg > ranges.agHigh) {
      lines.add(ResultLine(
          l.agHigh(_fmt(effectiveAg), '${ranges.agHigh}'), Severity.acidosis));
      suggestions.add(l.sugHighAg);
    } else if (effectiveAg < ranges.agLow) {
      lines.add(ResultLine(
          l.agLow(_fmt(effectiveAg), '${ranges.agLow}'), Severity.warning));
    } else {
      lines.add(ResultLine(l.agNormal(_fmt(effectiveAg)), Severity.normal));
    }

    return _AgResult(
      section: ResultSection(
        title: l.step4Title,
        severity:
            effectiveAg > ranges.agHigh ? Severity.acidosis : Severity.info,
        lines: lines,
      ),
      correctedAg: correctedAg,
      suggestions: suggestions,
    );
  }

  // ---- Step 5 本体 ----
  static _SectionResult _evaluateDeltaRatio(
      AppL l, AbgInput input, double correctedAg) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    final deltaAg = correctedAg - _agRef;
    final deltaHco3 = _hco3Ref - input.hco3;

    lines.add(
        ResultLine(l.deltaValues(_fmt(deltaAg), _fmt(deltaHco3)), Severity.info));

    if (deltaAg <= 0) {
      lines.add(ResultLine(l.deltaNoGap, Severity.info));
      return _SectionResult(
        section: ResultSection(
            title: l.step5Title, severity: Severity.info, lines: lines),
        suggestions: suggestions,
      );
    }

    if (deltaHco3.abs() < 0.0001) {
      lines.add(ResultLine(l.deltaHco3Zero, Severity.info));
    } else {
      final ratio = deltaAg / deltaHco3;
      lines.add(ResultLine(l.deltaRatio(_fmt(ratio, digits: 2)), Severity.info));

      if (ratio < 0.4) {
        lines.add(ResultLine(l.deltaLt04, Severity.warning));
        suggestions.add(l.sugDeltaLt04);
      } else if (ratio < 1.0) {
        lines.add(ResultLine(l.delta04to1, Severity.warning));
        suggestions.add(l.sugDelta04to1);
      } else if (ratio <= 2.0) {
        lines.add(ResultLine(l.delta1to2, Severity.normal));
      } else {
        lines.add(ResultLine(l.deltaGt2, Severity.warning));
        suggestions.add(l.sugDeltaGt2);
      }
    }

    return _SectionResult(
      section: ResultSection(
        title: l.step5Title,
        severity: lines.any((x) => x.severity == Severity.warning)
            ? Severity.warning
            : Severity.info,
        lines: lines,
      ),
      suggestions: suggestions,
    );
  }

  // ---- Step 6 本体 ----
  static _SectionResult _evaluateOxygenation(
      AppL l, AbgInput input, ReferenceRanges ranges) {
    final lines = <ResultLine>[];
    final suggestions = <String>[];

    if (ranges.venous) {
      lines.add(ResultLine(l.venousOxyNotApplicable, Severity.warning));
      if (input.pao2 != null) {
        lines.add(ResultLine(
            l.venousOxyReference(ranges.o2Label, _fmt(input.pao2!)),
            Severity.info));
      }
      return _SectionResult(
        section: ResultSection(
            title: l.step6Title, severity: Severity.warning, lines: lines),
        suggestions: suggestions,
      );
    }

    if (input.pao2 == null) {
      return _SectionResult(
        section: ResultSection(
          title: l.step6Title,
          severity: Severity.info,
          lines: [ResultLine(l.pao2NotEntered, Severity.info)],
        ),
        suggestions: suggestions,
      );
    }

    final pao2 = input.pao2!;
    lines.add(ResultLine(
        pao2 < ranges.pao2Low
            ? l.pao2LineLow(_fmt(pao2), '${ranges.pao2Low}')
            : l.pao2Line(_fmt(pao2)),
        pao2 < ranges.pao2Low ? Severity.warning : Severity.normal));

    if (input.hasOxygenationInputs) {
      final fio2Frac = input.fio2! / 100.0;
      final pf = pao2 / fio2Frac;
      String pfLabel;
      Severity pfSev;
      if (pf >= 300) {
        pfLabel = l.pfNormal;
        pfSev = Severity.normal;
      } else if (pf >= 200) {
        pfLabel = l.pfArdsMild;
        pfSev = Severity.warning;
      } else if (pf >= 100) {
        pfLabel = l.pfArdsModerate;
        pfSev = Severity.warning;
      } else {
        pfLabel = l.pfArdsSevere;
        pfSev = Severity.acidosis;
      }
      lines.add(ResultLine(l.pfRatio(_fmt(pf, digits: 0), pfLabel), pfSev));
      if (pf < 300) suggestions.add(l.sugPfLow(pfLabel));

      final pAO2 = fio2Frac * (760 - 47) - input.paco2 / 0.8;
      final aado2 = pAO2 - pao2;
      lines.add(ResultLine(
          l.aado2(_fmt(aado2, digits: 0), _fmt(pAO2, digits: 0)),
          Severity.info));
    } else {
      lines.add(ResultLine(l.fio2NotEntered, Severity.info));
    }

    return _SectionResult(
      section: ResultSection(
        title: l.step6Title,
        severity: lines.any((x) => x.severity == Severity.acidosis)
            ? Severity.acidosis
            : (lines.any((x) => x.severity == Severity.warning)
                ? Severity.warning
                : Severity.normal),
        lines: lines,
      ),
      suggestions: suggestions,
    );
  }

  // ---- 体温補正（参考表示） ----
  static ResultSection? _temperatureCorrection(AppL l, AbgInput input) {
    final t = input.temperature;
    if (t == null || t == 37) return null;
    final dT = t - 37;
    final phCorr = input.ph - 0.0146 * dT;
    final paco2Corr = input.paco2 * math.pow(10, 0.019 * dT);
    final lines = <ResultLine>[
      ResultLine(l.tempCorrHeader(_fmt(t)), Severity.info),
      ResultLine(l.tempCorrPh(_fmt(phCorr, digits: 2)), Severity.info),
      ResultLine(l.tempCorrPaco2(_fmt(paco2Corr.toDouble())), Severity.info),
      ResultLine(l.tempCorrNote, Severity.info),
    ];
    if (input.pao2 != null) {
      final pao2Corr = input.pao2! * math.pow(10, 0.024 * dT);
      lines.insert(
          3, ResultLine(l.tempCorrPao2(_fmt(pao2Corr.toDouble())), Severity.info));
    }
    return ResultSection(
        title: l.tempSectionTitle, severity: Severity.info, lines: lines);
  }

  // ---- 鑑別診断 ----
  static List<String> _differentials(
      AppL l, PrimaryDisorder primary, double? correctedAg,
      ReferenceRanges ranges) {
    switch (primary) {
      case PrimaryDisorder.respiratoryAcidosis:
        return [l.diffRespAcidosis];
      case PrimaryDisorder.respiratoryAlkalosis:
        return [l.diffRespAlkalosis];
      case PrimaryDisorder.metabolicAlkalosis:
        return [l.diffMetAlkalosis];
      case PrimaryDisorder.metabolicAcidosis:
        if (correctedAg != null && correctedAg <= ranges.agHigh) {
          return [l.diffNormalAgMetAcidosis];
        }
        return [l.diffHighAgMetAcidosis];
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
