import 'app_l.dart';

/// 简体中文。
class AppLZh extends AppL {
  const AppLZh();

  @override
  String get appTitle => 'Blood Gas Analyzer';
  @override
  String get appBarTitle => 'ABG/VBG 判读';
  @override
  String get languageName => '简体中文';
  @override
  String get selectLanguage => '语言';
  @override
  String get systemDefault => '跟随系统';
  @override
  String get toggleTheme => '切换主题';

  @override
  String get arterialAbg => '动脉血 (ABG)';
  @override
  String get venousVbg => '静脉血 (VBG)';
  @override
  String get adult => '成人';
  @override
  String get pediatric => '儿童';

  @override
  String get interpret => '判读';
  @override
  String get clear => '清除';
  @override
  String get copy => '复制';
  @override
  String get share => '分享';
  @override
  String get historyMenu => '历史';
  @override
  String get disclaimerMenu => '免责声明';

  @override
  String get groupRequired => '必填项';
  @override
  String get groupOxygenation => '氧合';
  @override
  String get groupOxygenationVenousNa => '氧合（静脉血不适用）';
  @override
  String get groupElectrolytes => '电解质（用于 AG）';
  @override
  String get groupOther => '其他（可选）';

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
  String get fieldAlb => 'Alb (g/dL) 可选';
  @override
  String get fieldBe => 'BE (mEq/L)';
  @override
  String get fieldTemp => '体温 (°C)';
  @override
  String hintEg(String v) => '例: $v';
  @override
  String get hintFio2RoomAir => '室内空气=21';
  @override
  String get hintReference => '参考值';
  @override
  String get hintAlbDefault => '默认 4.0';
  @override
  String get toggleSign => '切换正负号 (+/-)';

  @override
  String get ocrButton => '拍摄报告单自动填写 (OCR)';
  @override
  String get ocrCamera => '拍照';
  @override
  String get ocrGallery => '选择图片';
  @override
  String get ocrReviewTitle => '确认 OCR 结果';
  @override
  String ocrReviewDesc(int found, int total) =>
      '已自动提取 $found / $total 项。应用前请修正错误。';
  @override
  String get ocrApply => '填入表单';
  @override
  String get cancel => '取消';
  @override
  String get ocrShowRaw => '显示识别文本';
  @override
  String get ocrNoText => '（未能识别文本）';
  @override
  String ocrReference(String items) => '参考（不用于计算）: $items';

  @override
  String get snackRequired => 'pH、PaCO2 和 HCO3- 为必填（请输入数值）。';
  @override
  String get snackPhRange => 'pH 超出预期范围（6.5–8.0），请检查。';
  @override
  String get snackCopied => '结果已复制到剪贴板。';
  @override
  String snackOcrApplied(int count) => '已将 $count 项填入表单，请核对。';
  @override
  String snackOcrFailed(String error) => 'OCR 失败: $error';

  @override
  String get historyTitle => '输入历史';
  @override
  String get historyEmpty => '暂无历史。';
  @override
  String get historyDeleteAll => '全部删除';
  @override
  String get historyDeleteAllTitle => '删除全部历史';
  @override
  String get historyDeleteAllBody => '删除所有已保存的历史？';
  @override
  String get delete => '删除';
  @override
  String get tagArterial => '动脉';
  @override
  String get tagVenous => '静脉';
  @override
  String get tagPediatric => '儿童';
  @override
  String get resultLabel => '分析结果';

  @override
  String get disclaimerTitle => '免责声明';
  @override
  String get disclaimerBody => '''
本应用是用于学习和核对动脉血/静脉血气（ABG/VBG）判读的辅助工具。

• 计算与判读结果基于常见算法，仅供参考，并非用于诊断或治疗的医疗器械。
• 代偿公式与参考值主要针对成人。儿童、新生儿及妊娠可能不同。
• 输入错误或特殊病情可能导致结果不准确。
• 最终临床决策须由具备资质的医务人员结合患者整体情况做出。
• 因使用本应用造成的任何损失，开发者概不负责。

所有患者数据仅保存在本设备，绝不向外部传输。''';
  @override
  String get disclaimerAgree => '同意并开始';

  @override
  String get primaryDiagnosisLabel => '初步诊断';
  @override
  String get clinicalSuggestionsTitle => '临床提示 / 鉴别诊断';

  @override
  String get step1Title => 'Step 1: 原发异常判定';
  @override
  String get step2Title => 'Step 2: 原发紊乱分类';
  @override
  String get step3Title => 'Step 3: 代偿评估';
  @override
  String get step4Title => 'Step 4: 阴离子间隙 (AG)';
  @override
  String get step5Title => 'Step 5: Δ比 (Δ/Δ)';
  @override
  String get step6Title => 'Step 6: 氧合评估';
  @override
  String get tempSectionTitle => '参考: 体温校正';
  @override
  String get analysisModeVenousTitle => '分析模式: 静脉血（VBG）';

  @override
  String get dxNormal => '正常范围（无明显酸碱紊乱）';
  @override
  String get dxMetAcidosis => '代谢性酸中毒';
  @override
  String get dxMetAlkalosis => '代谢性碱中毒';
  @override
  String get dxRespAcidosis => '呼吸性酸中毒';
  @override
  String get dxRespAlkalosis => '呼吸性碱中毒';

  @override
  String phAcidemia(String ph, String low) => '酸血症 (pH $ph < $low)';
  @override
  String phAlkalemia(String ph, String high) => '碱血症 (pH $ph > $high)';
  @override
  String phNormal(String ph) => '正常 pH ($ph)';
  @override
  String abnLow(String name, String value, String unit, String low, String high) =>
      '$name $value $unit（偏低, 正常 $low–$high）';
  @override
  String abnHigh(String name, String value, String unit, String low, String high) =>
      '$name $value $unit（偏高, 正常 $low–$high）';
  @override
  String abnNormal(String name, String value, String unit, String low, String high) =>
      '$name $value $unit（正常 $low–$high）';

  @override
  String primaryDisorderLine(String label) => '原发紊乱: $label';
  @override
  String get mixedRespMetAcidosis => '疑似呼吸性酸中毒＋代谢性酸中毒的混合性紊乱。';
  @override
  String get mixedRespMetAlkalosis => '疑似呼吸性碱中毒＋代谢性碱中毒的混合性紊乱。';

  @override
  String wintersExpected(String value, String measured) =>
      'Winters 公式 预期 PaCO2 = $value ± 2 mmHg (实测 $measured)';
  @override
  String metAlkExpected(String value, String measured) =>
      '预期 PaCO2 = 0.7×HCO3- + 21 = $value ± 2 mmHg (实测 $measured)';
  @override
  String respExpectedAcuteChronic(String acute, String chronic, String measured) =>
      '急性 预期 HCO3- = $acute / 慢性 = $chronic mEq/L (实测 $measured)';
  @override
  String get respCompAppropriate => '呼吸代偿适当（在预期范围内）。';
  @override
  String get respCompHigh => '实测 PaCO2 高于预期 → 代偿不足，或合并呼吸性酸中毒。';
  @override
  String get respCompLow => '实测 PaCO2 低于预期 → 过度代偿，或合并呼吸性碱中毒。';
  @override
  String metCompAppropriate(String phase) => '实测 HCO3- 在预期范围内 → 接近$phase的适当代谢代偿。';
  @override
  String get phaseAcute => '急性';
  @override
  String get phaseChronic => '慢性';
  @override
  String get metCompHigh => '实测 HCO3- 高于预期 → 疑似合并代谢性碱中毒。';
  @override
  String get metCompLow => '实测 HCO3- 低于预期 → 疑似合并代谢性酸中毒。';
  @override
  String get noCompNeeded => '无原发紊乱，无需评估代偿。';
  @override
  String get sugMixedRespAcidosis => '可能为代谢性紊乱合并呼吸性酸中毒的混合性紊乱。';
  @override
  String get sugMixedRespAlkalosis => '可能为代谢性紊乱合并呼吸性碱中毒的混合性紊乱。';
  @override
  String get sugRespWithMetAlk => '可能为呼吸性紊乱合并代谢性碱中毒的混合性紊乱。';
  @override
  String get sugRespWithMetAcid => '可能为呼吸性紊乱合并代谢性酸中毒的混合性紊乱。';

  @override
  String agFormula(String value, String low, String high) =>
      'AG = Na - (Cl + HCO3-) = $value mEq/L（正常 $low–$high）';
  @override
  String agAlbCorrected(String value, String alb) =>
      '白蛋白校正 AG = $value mEq/L（Alb $alb g/dL）';
  @override
  String agHigh(String value, String high) =>
      'AG 升高（$value > $high）→ 提示高 AG 代谢性酸中毒。';
  @override
  String agLow(String value, String low) =>
      'AG 偏低（$value < $low）→ 考虑低白蛋白血症、高 Ca/Mg、副蛋白血症。';
  @override
  String agNormal(String value) => 'AG 正常（$value）。';
  @override
  String get agNotAvailable => '未输入 Na/Cl，无法计算 AG。';
  @override
  String get sugHighAg =>
      '高 AG 代谢性酸中毒鉴别: 乳酸酸中毒, 酮症酸中毒, 肾衰竭(尿毒症), 中毒(甲醇/乙二醇/水杨酸) 等。';

  @override
  String deltaValues(String dAg, String dHco3) => 'ΔAG = $dAg、ΔHCO3- = $dHco3';
  @override
  String get deltaNoGap => '无 AG 升高，Δ比解释有限。';
  @override
  String get deltaHco3Zero => 'ΔHCO3- ≈ 0，无法计算比值。';
  @override
  String deltaRatio(String ratio) => 'Δ比 = ΔAG / ΔHCO3- = $ratio';
  @override
  String get deltaLt04 => '< 0.4 → 提示合并正常 AG 代谢性酸中毒。';
  @override
  String get delta04to1 => '0.4–1.0 → 高 AG 与正常 AG 代谢性酸中毒混合。';
  @override
  String get delta1to2 => '1.0–2.0 → 符合单纯高 AG 代谢性酸中毒。';
  @override
  String get deltaGt2 => '> 2.0 → 提示合并代谢性碱中毒（或慢性呼吸性酸中毒）。';
  @override
  String get sugDeltaLt04 => '高 AG 合并正常 AG（高氯性）代谢性酸中毒。';
  @override
  String get sugDelta04to1 => '高 AG 与正常 AG 代谢性酸中毒混合。';
  @override
  String get sugDeltaGt2 => '高 AG 代谢性酸中毒合并代谢性碱中毒（或慢性呼吸性酸中毒）。';
  @override
  String get deltaNotAvailable => '无法获得 AG，无法评估 Δ比。';

  @override
  String get pao2NotEntered => '未输入 PaO2，无法评估氧合。';
  @override
  String pao2Line(String value) => 'PaO2 = $value mmHg';
  @override
  String pao2LineLow(String value, String low) =>
      'PaO2 = $value mmHg（低氧血症: 正常下限 $low）';
  @override
  String pfRatio(String value, String label) =>
      'P/F 比 = PaO2 / FiO2 = $value → $label';
  @override
  String get pfNormal => '正常〜轻度';
  @override
  String get pfArdsMild => '轻度 ARDS 区间 (200–299)';
  @override
  String get pfArdsModerate => '中度 ARDS 区间 (100–199)';
  @override
  String get pfArdsSevere => '重度 ARDS 区间 (<100)';
  @override
  String sugPfLow(String label) =>
      'P/F 比下降（$label）。ARDS 诊断需符合 Berlin 标准（PEEP≥5cmH2O、双侧浸润、排除心源性）。';
  @override
  String aado2(String value, String palv) =>
      'A-aDO2 ≈ $value mmHg（PAO2 $palv − PaO2，海平面/R=0.8）';
  @override
  String get fio2NotEntered => '未输入 FiO2，无法计算 P/F 比与 A-aDO2。';
  @override
  String get venousOxyNotApplicable => '静脉血模式下不进行氧合评估（P/F 比、A-aDO2）。';
  @override
  String venousOxyReference(String label, String value) =>
      '参考: $label = $value mmHg（静脉血数值不用作氧合指标）';

  @override
  String tempCorrHeader(String temp) => '体温 $temp°C 的参考校正值（判读本身按 37°C 进行）:';
  @override
  String tempCorrPh(String value) => '  校正 pH ≈ $value';
  @override
  String tempCorrPaco2(String value) => '  校正 PaCO2 ≈ $value mmHg';
  @override
  String tempCorrPao2(String value) => '  校正 PaO2 ≈ $value mmHg';
  @override
  String get tempCorrNote =>
      '  * 体温校正存在 alpha-stat/pH-stat 争议，请遵循本机构规定。';

  @override
  String get venousModeNote => '静脉血（VBG）模式';
  @override
  String get venousModeLine1 =>
      '使用静脉血正常值（pH 7.31–7.41 / PvCO2 41–51 / HCO3- 22–26）进行判定。';
  @override
  String get venousModeLine2 => '代偿评估沿用与动脉血相同的计算逻辑。';
  @override
  String get venousModeLine3 => '氧合评估（P/F 比、A-aDO2）属动脉血指标，静脉血模式下不适用。';
  @override
  String get venousModeLine4 =>
      '* VBG 与 ABG 可能存在差异，尤其是 PCO2。确定性判断建议用动脉血确认。';
  @override
  String get sugVenous =>
      '这是静脉血判读。pH 与 HCO3- 与动脉血相关良好，但 PvCO2 通常高于 PaCO2。';

  @override
  String get diffRespAcidosis =>
      '呼吸性酸中毒鉴别: COPD 急性加重, 呼吸抑制(镇静药/阿片类), 神经肌肉疾病, 胸廓/气道梗阻, 通气不足。';
  @override
  String get diffRespAlkalosis =>
      '呼吸性碱中毒鉴别: 过度通气(焦虑/疼痛), 缺氧, 肺栓塞, 脓毒症, 肝衰竭, 水杨酸中毒, 妊娠。';
  @override
  String get diffMetAlkalosis =>
      '代谢性碱中毒鉴别: 呕吐/胃液丢失, 利尿剂, 低钾血症, 盐皮质激素过多, 过量补碱。';
  @override
  String get diffNormalAgMetAcidosis =>
      '正常 AG（高氯性）代谢性酸中毒鉴别: 腹泻, 肾小管酸中毒(RTA), 大量生理盐水, 碳酸酐酶抑制剂。';
  @override
  String get diffHighAgMetAcidosis =>
      '高 AG 代谢性酸中毒鉴别(GOLDMARK/MUDPILES): 乳酸, 酮体, 肾衰竭, 甲醇/乙二醇/水杨酸 等。';

  @override
  String get shareHeader => '【血气判读结果】';
  @override
  String shareModeNote(String note) => '［$note］';
  @override
  String sharePrimary(String dx) => '初步诊断: $dx';
  @override
  String get shareSuggestionsHeader => '临床提示 / 鉴别诊断';
  @override
  String get shareDisclaimer => '* 本结果仅为临床辅助，最终决策须由医务人员做出。';

  @override
  String get nomoTitle => '酸碱平衡诺谟图 (Cohen)';
  @override
  String get nomoTapHint => '点击图表显示数值 / 双指缩放。';
  @override
  String get nomoFullScreen => '全屏';
  @override
  String get nomoPlottedPoint => '绘制点';
  @override
  String get nomoAssessmentPrefix => '判定: ';
  @override
  String get nomoPaco2CalcPrefix => 'PaCO2(计算): ';
  @override
  String get axisPh => '动脉血 pH';
  @override
  String get axisHco3 => '动脉血浆 [HCO3-] (mmol/L)';
  @override
  String get axisHplus => '动脉血 [H+] (nmol/L)';
  @override
  String get axisPco2 => 'pCO2 (mmHg)';
  @override
  String get rNormal => '正常';
  @override
  String get rMetAcid => '代谢性酸中毒';
  @override
  String get rMetAlk => '代谢性碱中毒';
  @override
  String get rAcuteRespAcid => '急性呼吸性酸中毒';
  @override
  String get rChronicRespAcid => '慢性呼吸性酸中毒';
  @override
  String get rAcuteRespAlk => '急性呼吸性碱中毒';
  @override
  String get rChronicRespAlk => '慢性呼吸性碱中毒';
  @override
  String get mMixedRespAcidMetAlk => '混合 呼吸性酸＋代谢性碱';
  @override
  String get mMetAlkNoComp => '代谢性碱（代偿不足）';
  @override
  String get mMixedRespMetAlk => '混合 呼吸性＋代谢性碱中毒';
  @override
  String get mAcuteOnChronicRespAlk => '慢性基础上急性 呼吸性碱';
  @override
  String get mMixedMetAcidRespAlk => '混合 代谢性酸＋呼吸性碱';
  @override
  String get mMixedRespMetAcid => '混合 呼吸性＋代谢性酸中毒';
  @override
  String get mMetAcidNoComp => '代谢性酸（代偿不足）';
  @override
  String get mAcuteOnChronicRespAcid => '慢性基础上急性 呼吸性酸';
}
