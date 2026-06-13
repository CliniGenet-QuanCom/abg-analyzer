import 'app_l.dart';

/// 日本語。
class AppLJa extends AppL {
  const AppLJa();

  @override
  String get appTitle => 'Blood Gas Analyzer';
  @override
  String get appBarTitle => 'ABG/VBG判定';
  @override
  String get languageName => '日本語';
  @override
  String get selectLanguage => '言語';
  @override
  String get systemDefault => '端末の設定に従う';
  @override
  String get toggleTheme => 'テーマ切替';

  @override
  String get arterialAbg => '動脈血 (ABG)';
  @override
  String get venousVbg => '静脈血 (VBG)';
  @override
  String get adult => '成人';
  @override
  String get pediatric => '小児';

  @override
  String get interpret => '解釈する';
  @override
  String get clear => 'クリア';
  @override
  String get copy => 'コピー';
  @override
  String get share => '共有';
  @override
  String get historyMenu => '履歴';
  @override
  String get disclaimerMenu => '免責事項';

  @override
  String get groupRequired => '必須項目';
  @override
  String get groupOxygenation => '酸素化';
  @override
  String get groupOxygenationVenousNa => '酸素化（静脈血では非適用）';
  @override
  String get groupElectrolytes => '電解質（AG 計算用）';
  @override
  String get groupOther => 'その他（任意）';

  @override
  String get fieldPh => 'pH';
  @override
  String get fieldPaco2 => 'PaCO2 (mmHg)';
  @override
  String get fieldPvco2 => 'PvCO2 (mmHg)';
  @override
  String get fieldHco3 => 'HCO3- (mEq/L)';
  @override
  String get fieldPao2 => 'PaO2 (mmHg)';
  @override
  String get fieldPvo2 => 'PvO2 (mmHg)';
  @override
  String get fieldFio2 => 'FiO2 (%)';
  @override
  String get fieldNa => 'Na (mEq/L)';
  @override
  String get fieldCl => 'Cl (mEq/L)';
  @override
  String get fieldAlb => 'Alb (g/dL) 任意';
  @override
  String get fieldBe => 'BE (mEq/L)';
  @override
  String get fieldTemp => '体温 (℃)';
  @override
  String hintEg(String v) => '例: $v';
  @override
  String get hintFio2RoomAir => '室内気=21';
  @override
  String get hintReference => '参考値';
  @override
  String get hintAlbDefault => '既定 4.0';
  @override
  String get toggleSign => '符号 (+/-) を反転';

  @override
  String get ocrButton => '結果用紙を撮影して自動入力 (OCR)';
  @override
  String get ocrCamera => 'カメラで撮影';
  @override
  String get ocrGallery => '画像を選択';
  @override
  String get ocrReviewTitle => 'OCR 結果の確認';
  @override
  String ocrReviewDesc(int found, int total) =>
      '$found / $total 項目を自動抽出しました。誤りがあれば修正してから反映してください。';
  @override
  String get ocrApply => 'フォームに反映';
  @override
  String get cancel => 'キャンセル';
  @override
  String get ocrShowRaw => '認識した全文を表示';
  @override
  String get ocrNoText => '(テキストを認識できませんでした)';
  @override
  String ocrReference(String items) => '参考（計算には未使用）: $items';

  @override
  String get snackRequired => 'pH・PaCO2・HCO3- は必須です（数値を入力してください）。';
  @override
  String get snackPhRange => 'pH の値が想定範囲外です（6.5–8.0）。入力を確認してください。';
  @override
  String get snackCopied => '結果をクリップボードにコピーしました。';
  @override
  String snackOcrApplied(int count) => '$count 項目をフォームに反映しました。値を確認してください。';
  @override
  String snackOcrFailed(String error) => 'OCR に失敗しました: $error';

  @override
  String get historyTitle => '入力履歴';
  @override
  String get historyEmpty => '履歴はありません。';
  @override
  String get historyDeleteAll => 'すべて削除';
  @override
  String get historyDeleteAllTitle => '履歴をすべて削除';
  @override
  String get historyDeleteAllBody => '保存された履歴をすべて削除しますか？';
  @override
  String get delete => '削除';
  @override
  String get tagArterial => '動脈';
  @override
  String get tagVenous => '静脈';
  @override
  String get tagPediatric => '小児';
  @override
  String get resultLabel => '解析結果';

  @override
  String get disclaimerTitle => '免責事項';
  @override
  String get disclaimerBody => '''
本アプリは動脈血/静脈血ガス（ABG/VBG）の解釈を学習・確認するための補助ツールです。

• 本アプリの計算・解釈結果は一般的なアルゴリズムに基づく参考情報であり、診断・治療を目的とした医療機器ではありません。
• 代償式や基準値は主に成人を対象とした標準値を用いています。小児・新生児・妊娠中などでは適用が異なる場合があります。
• 入力値の誤りや特殊な病態では結果が不正確になることがあります。
• 最終的な臨床判断は、患者の全体像を踏まえて必ず資格のある医療者が行ってください。
• 本アプリの利用により生じたいかなる損害についても、開発者は責任を負いません。

すべての患者データは端末内にのみ保存され、外部送信は行いません。''';
  @override
  String get disclaimerAgree => '同意して開始する';

  @override
  String get primaryDiagnosisLabel => '一次診断';
  @override
  String get clinicalSuggestionsTitle => '臨床的示唆 / 鑑別診断';

  @override
  String get step1Title => 'Step 1: 一次性異常の判定';
  @override
  String get step2Title => 'Step 2: 原発性障害の分類';
  @override
  String get step3Title => 'Step 3: 代償の評価';
  @override
  String get step4Title => 'Step 4: アニオンギャップ (AG)';
  @override
  String get step5Title => 'Step 5: デルタ比 (Δ/Δ)';
  @override
  String get step6Title => 'Step 6: 酸素化評価';
  @override
  String get tempSectionTitle => '参考: 体温補正';
  @override
  String get analysisModeVenousTitle => '解析モード: 静脈血（VBG）';

  @override
  String get dxNormal => '正常範囲（明らかな酸塩基異常なし）';
  @override
  String get dxMetAcidosis => '代謝性アシドーシス';
  @override
  String get dxMetAlkalosis => '代謝性アルカローシス';
  @override
  String get dxRespAcidosis => '呼吸性アシドーシス';
  @override
  String get dxRespAlkalosis => '呼吸性アルカローシス';

  @override
  String phAcidemia(String ph, String low) => 'アシデミア (pH $ph < $low)';
  @override
  String phAlkalemia(String ph, String high) => 'アルカレミア (pH $ph > $high)';
  @override
  String phNormal(String ph) => '正常 pH ($ph)';
  @override
  String abnLow(String name, String value, String unit, String low, String high) =>
      '$name $value $unit（低値, 正常 $low–$high）';
  @override
  String abnHigh(String name, String value, String unit, String low, String high) =>
      '$name $value $unit（高値, 正常 $low–$high）';
  @override
  String abnNormal(String name, String value, String unit, String low, String high) =>
      '$name $value $unit（正常 $low–$high）';

  @override
  String primaryDisorderLine(String label) => '原発性障害: $label';
  @override
  String get mixedRespMetAcidosis => '呼吸性アシドーシス＋代謝性アシドーシスの混合性障害が疑われます。';
  @override
  String get mixedRespMetAlkalosis => '呼吸性アルカローシス＋代謝性アルカローシスの混合性障害が疑われます。';

  @override
  String wintersExpected(String value, String measured) =>
      'Winters 式 期待 PaCO2 = $value ± 2 mmHg (実測 $measured)';
  @override
  String metAlkExpected(String value, String measured) =>
      '期待 PaCO2 = 0.7×HCO3- + 21 = $value ± 2 mmHg (実測 $measured)';
  @override
  String respExpectedAcuteChronic(String acute, String chronic, String measured) =>
      '急性 期待 HCO3- = $acute / 慢性 = $chronic mEq/L (実測 $measured)';
  @override
  String get respCompAppropriate => '適切な呼吸性代償あり（期待範囲内）。';
  @override
  String get respCompHigh => '実測 PaCO2 が期待より高い → 呼吸性代償が不十分、または呼吸性アシドーシスの合併。';
  @override
  String get respCompLow => '実測 PaCO2 が期待より低い → 過剰代償、または呼吸性アルカローシスの合併。';
  @override
  String metCompAppropriate(String phase) => '実測 HCO3- は期待範囲内 → $phaseに近い適切な代謝性代償。';
  @override
  String get phaseAcute => '急性';
  @override
  String get phaseChronic => '慢性';
  @override
  String get metCompHigh => '実測 HCO3- が期待より高い → 代謝性アルカローシスの合併が疑われます。';
  @override
  String get metCompLow => '実測 HCO3- が期待より低い → 代謝性アシドーシスの合併が疑われます。';
  @override
  String get noCompNeeded => '原発性障害がないため代償評価は不要です。';
  @override
  String get sugMixedRespAcidosis => '代謝性障害に呼吸性アシドーシスを合併した混合性障害の可能性。';
  @override
  String get sugMixedRespAlkalosis => '代謝性障害に呼吸性アルカローシスを合併した混合性障害の可能性。';
  @override
  String get sugRespWithMetAlk => '呼吸性障害に代謝性アルカローシスを合併した混合性障害の可能性。';
  @override
  String get sugRespWithMetAcid => '呼吸性障害に代謝性アシドーシスを合併した混合性障害の可能性。';

  @override
  String agFormula(String value, String low, String high) =>
      'AG = Na - (Cl + HCO3-) = $value mEq/L（正常 $low–$high）';
  @override
  String agAlbCorrected(String value, String alb) =>
      'アルブミン補正 AG = $value mEq/L（Alb $alb g/dL）';
  @override
  String agHigh(String value, String high) =>
      'AG 開大（$value > $high）→ AG 開大性代謝性アシドーシスを示唆。';
  @override
  String agLow(String value, String low) =>
      'AG 低値（$value < $low）→ 低アルブミン血症・高Ca/Mg・パラプロテイン血症などを考慮。';
  @override
  String agNormal(String value) => 'AG 正常（$value）。';
  @override
  String get agNotAvailable => 'Na・Cl が未入力のため AG は計算できません。';
  @override
  String get sugHighAg =>
      'AG 開大性代謝性アシドーシスの鑑別: 乳酸アシドーシス, ケトアシドーシス, 腎不全(尿毒症), 中毒(メタノール/エチレングリコール/サリチル酸) 等。';

  @override
  String deltaValues(String dAg, String dHco3) => 'ΔAG = $dAg、ΔHCO3- = $dHco3';
  @override
  String get deltaNoGap => 'AG 開大がないためデルタ比の解釈は限定的です。';
  @override
  String get deltaHco3Zero => 'ΔHCO3- ≒ 0 のため比は計算できません。';
  @override
  String deltaRatio(String ratio) => 'Δ比 = ΔAG / ΔHCO3- = $ratio';
  @override
  String get deltaLt04 => '< 0.4 → 正常 AG 代謝性アシドーシスの合併を示唆。';
  @override
  String get delta04to1 => '0.4–1.0 → AG 開大性と正常 AG 代謝性アシドーシスの混合型。';
  @override
  String get delta1to2 => '1.0–2.0 → 純粋な AG 開大性代謝性アシドーシスとして矛盾しない。';
  @override
  String get deltaGt2 => '> 2.0 → 代謝性アルカローシス、または慢性呼吸性アシドーシスの合併を示唆。';
  @override
  String get sugDeltaLt04 => 'AG 開大性に正常 AG（高Cl性）代謝性アシドーシスを合併。';
  @override
  String get sugDelta04to1 => 'AG 開大性＋正常 AG 代謝性アシドーシスの混合。';
  @override
  String get sugDeltaGt2 => 'AG 開大性代謝性アシドーシスに代謝性アルカローシス（または慢性呼吸性アシドーシス）を合併。';
  @override
  String get deltaNotAvailable => 'AG が計算できないためデルタ比は評価できません。';

  @override
  String get pao2NotEntered => 'PaO2 が未入力のため酸素化評価はできません。';
  @override
  String pao2Line(String value) => 'PaO2 = $value mmHg';
  @override
  String pao2LineLow(String value, String low) =>
      'PaO2 = $value mmHg（低酸素血症: 正常下限 $low）';
  @override
  String pfRatio(String value, String label) =>
      'P/F 比 = PaO2 / FiO2 = $value → $label';
  @override
  String get pfNormal => '正常〜軽度';
  @override
  String get pfArdsMild => '軽症 ARDS 域 (200–299)';
  @override
  String get pfArdsModerate => '中等症 ARDS 域 (100–199)';
  @override
  String get pfArdsSevere => '重症 ARDS 域 (<100)';
  @override
  String sugPfLow(String label) =>
      'P/F 比低下（$label）。ARDS の診断には PEEP≥5cmH2O・両側陰影・心原性除外など Berlin 基準の確認が必要。';
  @override
  String aado2(String value, String palv) =>
      'A-aDO2 ≒ $value mmHg（PAO2 $palv − PaO2、海面/R=0.8 仮定）';
  @override
  String get fio2NotEntered => 'FiO2 未入力のため P/F 比・A-aDO2 は計算できません。';
  @override
  String get venousOxyNotApplicable => '静脈血モードのため酸素化評価（P/F 比・A-aDO2）は適用しません。';
  @override
  String venousOxyReference(String label, String value) =>
      '参考: $label = $value mmHg（静脈血の値は酸素化指標として用いません）';

  @override
  String tempCorrHeader(String temp) => '体温 $temp℃ での参考補正値（解釈本体は 37℃ 値で実施）:';
  @override
  String tempCorrPh(String value) => '  補正 pH ≒ $value';
  @override
  String tempCorrPaco2(String value) => '  補正 PaCO2 ≒ $value mmHg';
  @override
  String tempCorrPao2(String value) => '  補正 PaO2 ≒ $value mmHg';
  @override
  String get tempCorrNote =>
      '  ※ 温度補正は alpha-stat/pH-stat の議論があり、施設方針に従ってください。';

  @override
  String get venousModeNote => '静脈血（VBG）モード';
  @override
  String get venousModeLine1 =>
      '静脈血の正常値（pH 7.31–7.41 / PvCO2 41–51 / HCO3- 22–26）で判定しています。';
  @override
  String get venousModeLine2 => '代償の評価は動脈血と同じ計算ロジックを流用しています。';
  @override
  String get venousModeLine3 =>
      '酸素化評価（P/F 比・A-aDO2）は動脈血の指標のため、静脈血モードでは適用されません。';
  @override
  String get venousModeLine4 =>
      '※ VBG と ABG では特に PCO2 に乖離があり得ます。確定的判断には動脈血での確認を考慮してください。';
  @override
  String get sugVenous =>
      '静脈血での解釈です。pH・HCO3- は動脈血とよく相関しますが、PvCO2 は PaCO2 より高めに出ます。';

  @override
  String get diffRespAcidosis =>
      '呼吸性アシドーシスの鑑別: COPD増悪, 呼吸抑制(鎮静薬/オピオイド), 神経筋疾患, 胸郭/気道閉塞, 換気不全。';
  @override
  String get diffRespAlkalosis =>
      '呼吸性アルカローシスの鑑別: 過換気(不安/疼痛), 低酸素, 肺塞栓, 敗血症, 肝不全, サリチル酸中毒, 妊娠。';
  @override
  String get diffMetAlkalosis =>
      '代謝性アルカローシスの鑑別: 嘔吐/胃液喪失, 利尿薬, 低K血症, ミネラルコルチコイド過剰, アルカリ過剰投与。';
  @override
  String get diffNormalAgMetAcidosis =>
      '正常 AG（高Cl性）代謝性アシドーシスの鑑別: 下痢, 尿細管性アシドーシス(RTA), 生理食塩水大量投与, 炭酸脱水酵素阻害薬。';
  @override
  String get diffHighAgMetAcidosis =>
      'AG 開大性代謝性アシドーシスの鑑別(GOLDMARK/MUDPILES): 乳酸, ケトン体, 腎不全, メタノール/エチレングリコール/サリチル酸 等。';

  @override
  String get shareHeader => '【血液ガス 解釈結果】';
  @override
  String shareModeNote(String note) => '［$note］';
  @override
  String sharePrimary(String dx) => '一次診断: $dx';
  @override
  String get shareSuggestionsHeader => '臨床的示唆 / 鑑別診断';
  @override
  String get shareDisclaimer => '※ 本結果は臨床判断の補助です。最終判断は必ず医療者が行ってください。';

  @override
  String get nomoTitle => '酸塩基平衡ノモグラム (Cohen)';
  @override
  String get nomoTapHint => 'グラフをタップで数値表示 / ピンチでズーム。';
  @override
  String get nomoFullScreen => '全画面';
  @override
  String get nomoPlottedPoint => 'プロット点';
  @override
  String get nomoAssessmentPrefix => '判定: ';
  @override
  String get nomoPaco2CalcPrefix => 'PaCO2(計算): ';
  @override
  String get axisPh => '動脈血 pH';
  @override
  String get axisHco3 => '動脈血漿 [HCO3-] (mmol/L)';
  @override
  String get axisHplus => '動脈血 [H+] (nmol/L)';
  @override
  String get axisPco2 => 'pCO2 (mmHg)';
  @override
  String get rNormal => '正常';
  @override
  String get rMetAcid => '代謝性アシドーシス';
  @override
  String get rMetAlk => '代謝性アルカローシス';
  @override
  String get rAcuteRespAcid => '急性呼吸性アシドーシス';
  @override
  String get rChronicRespAcid => '慢性呼吸性アシドーシス';
  @override
  String get rAcuteRespAlk => '急性呼吸性アルカローシス';
  @override
  String get rChronicRespAlk => '慢性呼吸性アルカローシス';
  @override
  String get mMixedRespAcidMetAlk => '混合 呼吸性アシ＋代謝性アルカ';
  @override
  String get mMetAlkNoComp => '代謝性アルカ（代償不全）';
  @override
  String get mMixedRespMetAlk => '混合 呼吸性＋代謝性アルカローシス';
  @override
  String get mAcuteOnChronicRespAlk => '急性 on 慢性 呼吸性アルカ';
  @override
  String get mMixedMetAcidRespAlk => '混合 代謝性アシ＋呼吸性アルカ';
  @override
  String get mMixedRespMetAcid => '混合 呼吸性＋代謝性アシドーシス';
  @override
  String get mMetAcidNoComp => '代謝性アシ（代償不全）';
  @override
  String get mAcuteOnChronicRespAcid => '急性 on 慢性 呼吸性アシ';
}
