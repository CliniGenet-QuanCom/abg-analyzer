import 'package:flutter/widgets.dart';

import 'app_l_en.dart';
import 'app_l_ja.dart';
import 'app_l_ko.dart';
import 'app_l_zh.dart';

/// アプリの多言語文字列（型安全）。
///
/// 抽象メンバを各言語実装が全て実装するため、訳抜けはコンパイル時に検出される。
/// 解釈エンジン等の純粋ロジックにも `AppL` を引数で渡して利用する。
abstract class AppL {
  const AppL();

  /// 対応ロケール。
  static const List<Locale> supportedLocales = [
    Locale('ja'),
    Locale('en'),
    Locale('zh'),
    Locale('ko'),
  ];

  /// ロケールから実装を選択。
  static AppL of(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const AppLEn();
      case 'zh':
        return const AppLZh();
      case 'ko':
        return const AppLKo();
      case 'ja':
      default:
        return const AppLJa();
    }
  }

  /// Widget ツリーから取得。
  static AppL ofContext(BuildContext context) =>
      Localizations.of<AppL>(context, AppL) ?? const AppLJa();

  static const LocalizationsDelegate<AppL> delegate = _AppLDelegate();

  // ---- 一般 ----
  String get appTitle;
  String get appBarTitle;
  String get languageName; // その言語名（メニュー表示用）
  String get selectLanguage;
  String get systemDefault;
  String get toggleTheme;

  // ---- 検体・患者種別 ----
  String get arterialAbg;
  String get venousVbg;
  String get adult;
  String get pediatric;

  // ---- ボタン ----
  String get interpret;
  String get clear;
  String get copy;
  String get share;
  String get historyMenu;
  String get disclaimerMenu;

  // ---- 入力グループ ----
  String get groupRequired;
  String get groupOxygenation;
  String get groupOxygenationVenousNa;
  String get groupElectrolytes;
  String get groupOther;

  // ---- フィールド ----
  String get fieldPh;
  String get fieldPaco2;
  String get fieldPvco2;
  String get fieldHco3;
  String get fieldPao2;
  String get fieldPvo2;
  String get fieldFio2;
  String get fieldNa;
  String get fieldCl;
  String get fieldAlb;
  String get fieldBe;
  String get fieldTemp;
  String hintEg(String v);
  String get hintFio2RoomAir;
  String get hintReference;
  String get hintAlbDefault;
  String get toggleSign;

  // ---- OCR ----
  String get ocrButton;
  String get ocrCamera;
  String get ocrGallery;
  String get ocrReviewTitle;
  String ocrReviewDesc(int found, int total);
  String get ocrApply;
  String get cancel;
  String get ocrShowRaw;
  String get ocrNoText;
  String ocrReference(String items);

  // ---- スナックバー ----
  String get snackRequired;
  String get snackPhRange;
  String get snackCopied;
  String snackOcrApplied(int count);
  String snackOcrFailed(String error);

  // ---- 履歴 ----
  String get historyTitle;
  String get historyEmpty;
  String get historyDeleteAll;
  String get historyDeleteAllTitle;
  String get historyDeleteAllBody;
  String get delete;
  String get tagArterial;
  String get tagVenous;
  String get tagPediatric;
  String get resultLabel;

  // ---- 免責 ----
  String get disclaimerTitle;
  String get disclaimerBody;
  String get disclaimerAgree;

  // ---- 結果表示 ----
  String get primaryDiagnosisLabel;
  String get clinicalSuggestionsTitle;

  // ---- ステップ見出し ----
  String get step1Title;
  String get step2Title;
  String get step3Title;
  String get step4Title;
  String get step5Title;
  String get step6Title;
  String get tempSectionTitle;
  String get analysisModeVenousTitle;

  // ---- 診断名 ----
  String get dxNormal;
  String get dxMetAcidosis;
  String get dxMetAlkalosis;
  String get dxRespAcidosis;
  String get dxRespAlkalosis;

  // ---- Step1 ----
  String phAcidemia(String ph, String low);
  String phAlkalemia(String ph, String high);
  String phNormal(String ph);
  String abnLow(String name, String value, String unit, String low, String high);
  String abnHigh(String name, String value, String unit, String low, String high);
  String abnNormal(
      String name, String value, String unit, String low, String high);

  // ---- Step2 ----
  String primaryDisorderLine(String label);
  String get mixedRespMetAcidosis;
  String get mixedRespMetAlkalosis;

  // ---- Step3 ----
  String wintersExpected(String value, String measured);
  String metAlkExpected(String value, String measured);
  String respExpectedAcuteChronic(String acute, String chronic, String measured);
  String get respCompAppropriate;
  String get respCompHigh;
  String get respCompLow;
  String metCompAppropriate(String phase);
  String get phaseAcute;
  String get phaseChronic;
  String get metCompHigh;
  String get metCompLow;
  String get noCompNeeded;
  String get sugMixedRespAcidosis;
  String get sugMixedRespAlkalosis;
  String get sugRespWithMetAlk;
  String get sugRespWithMetAcid;

  // ---- Step4 ----
  String agFormula(String value, String low, String high);
  String agAlbCorrected(String value, String alb);
  String agHigh(String value, String high);
  String agLow(String value, String low);
  String agNormal(String value);
  String get agNotAvailable;
  String get sugHighAg;

  // ---- Step5 ----
  String deltaValues(String dAg, String dHco3);
  String get deltaNoGap;
  String get deltaHco3Zero;
  String deltaRatio(String ratio);
  String get deltaLt04;
  String get delta04to1;
  String get delta1to2;
  String get deltaGt2;
  String get sugDeltaLt04;
  String get sugDelta04to1;
  String get sugDeltaGt2;
  String get deltaNotAvailable;

  // ---- Step6 ----
  String get pao2NotEntered;
  String pao2Line(String value);
  String pao2LineLow(String value, String low);
  String pfRatio(String value, String label);
  String get pfNormal;
  String get pfArdsMild;
  String get pfArdsModerate;
  String get pfArdsSevere;
  String sugPfLow(String label);
  String aado2(String value, String palv);
  String get fio2NotEntered;
  String get venousOxyNotApplicable;
  String venousOxyReference(String label, String value);

  // ---- 体温補正 ----
  String tempCorrHeader(String temp);
  String tempCorrPh(String value);
  String tempCorrPaco2(String value);
  String tempCorrPao2(String value);
  String get tempCorrNote;

  // ---- 静脈血モード ----
  String get venousModeNote;
  String get venousModeLine1;
  String get venousModeLine2;
  String get venousModeLine3;
  String get venousModeLine4;
  String get sugVenous;

  // ---- 鑑別 ----
  String get diffRespAcidosis;
  String get diffRespAlkalosis;
  String get diffMetAlkalosis;
  String get diffNormalAgMetAcidosis;
  String get diffHighAgMetAcidosis;

  // ---- 共有テキスト ----
  String get shareHeader;
  String shareModeNote(String note);
  String sharePrimary(String dx);
  String get shareSuggestionsHeader;
  String get shareDisclaimer;

  // ---- ノモグラム ----
  String get nomoTitle;
  String get nomoTapHint;
  String get nomoFullScreen;
  String get nomoPlottedPoint;
  String get nomoAssessmentPrefix;
  String get nomoPaco2CalcPrefix;
  String get axisPh;
  String get axisHco3;
  String get axisHplus;
  String get axisPco2;
  String get rNormal;
  String get rMetAcid;
  String get rMetAlk;
  String get rAcuteRespAcid;
  String get rChronicRespAcid;
  String get rAcuteRespAlk;
  String get rChronicRespAlk;
  String get mMixedRespAcidMetAlk;
  String get mMetAlkNoComp;
  String get mMixedRespMetAlk;
  String get mAcuteOnChronicRespAlk;
  String get mMixedMetAcidRespAlk;
  String get mMixedRespMetAcid;
  String get mMetAcidNoComp;
  String get mAcuteOnChronicRespAcid;
}

class _AppLDelegate extends LocalizationsDelegate<AppL> {
  const _AppLDelegate();

  @override
  bool isSupported(Locale locale) =>
      const {'ja', 'en', 'zh', 'ko'}.contains(locale.languageCode);

  @override
  Future<AppL> load(Locale locale) async => AppL.of(locale);

  @override
  bool shouldReload(_AppLDelegate old) => false;
}
