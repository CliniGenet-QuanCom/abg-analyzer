import 'app_l.dart';

/// 한국어.
class AppLKo extends AppL {
  const AppLKo();

  @override
  String get appTitle => 'Blood Gas Analyzer';
  @override
  String get appBarTitle => 'ABG/VBG 판정';
  @override
  String get languageName => '한국어';
  @override
  String get selectLanguage => '언어';
  @override
  String get systemDefault => '시스템 설정 따름';
  @override
  String get toggleTheme => '테마 전환';

  @override
  String get arterialAbg => '동맥혈 (ABG)';
  @override
  String get venousVbg => '정맥혈 (VBG)';
  @override
  String get adult => '성인';
  @override
  String get pediatric => '소아';

  @override
  String get interpret => '판정';
  @override
  String get clear => '지우기';
  @override
  String get copy => '복사';
  @override
  String get share => '공유';
  @override
  String get historyMenu => '기록';
  @override
  String get disclaimerMenu => '면책 조항';

  @override
  String get groupRequired => '필수 항목';
  @override
  String get groupOxygenation => '산소화';
  @override
  String get groupOxygenationVenousNa => '산소화(정맥혈에는 비적용)';
  @override
  String get groupElectrolytes => '전해질(AG 계산용)';
  @override
  String get groupOther => '기타(선택)';

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
  String get fieldAlb => 'Alb (g/dL) 선택';
  @override
  String get fieldBe => 'BE (mEq/L)';
  @override
  String get fieldTemp => '체온 (°C)';
  @override
  String hintEg(String v) => '예: $v';
  @override
  String get hintFio2RoomAir => '실내공기=21';
  @override
  String get hintReference => '참고값';
  @override
  String get hintAlbDefault => '기본 4.0';
  @override
  String get toggleSign => '부호(+/-) 전환';

  @override
  String get ocrButton => '결과지 촬영 자동 입력 (OCR)';
  @override
  String get ocrCamera => '사진 촬영';
  @override
  String get ocrGallery => '이미지 선택';
  @override
  String get ocrReviewTitle => 'OCR 결과 확인';
  @override
  String ocrReviewDesc(int found, int total) =>
      '$total개 중 $found개 항목을 자동 추출했습니다. 적용 전에 오류를 수정하세요.';
  @override
  String get ocrApply => '양식에 반영';
  @override
  String get cancel => '취소';
  @override
  String get ocrShowRaw => '인식된 전체 텍스트 보기';
  @override
  String get ocrNoText => '(텍스트를 인식하지 못했습니다)';
  @override
  String ocrReference(String items) => '참고(계산에는 미사용): $items';

  @override
  String get snackRequired => 'pH·PaCO2·HCO3-는 필수입니다(숫자를 입력하세요).';
  @override
  String get snackPhRange => 'pH 값이 예상 범위(6.5–8.0)를 벗어났습니다. 확인하세요.';
  @override
  String get snackCopied => '결과를 클립보드에 복사했습니다.';
  @override
  String snackOcrApplied(int count) => '$count개 항목을 양식에 반영했습니다. 값을 확인하세요.';
  @override
  String snackOcrFailed(String error) => 'OCR 실패: $error';

  @override
  String get historyTitle => '입력 기록';
  @override
  String get historyEmpty => '기록이 없습니다.';
  @override
  String get historyDeleteAll => '모두 삭제';
  @override
  String get historyDeleteAllTitle => '기록 모두 삭제';
  @override
  String get historyDeleteAllBody => '저장된 기록을 모두 삭제하시겠습니까?';
  @override
  String get delete => '삭제';
  @override
  String get tagArterial => '동맥';
  @override
  String get tagVenous => '정맥';
  @override
  String get tagPediatric => '소아';
  @override
  String get resultLabel => '분석 결과';

  @override
  String get disclaimerTitle => '면책 조항';
  @override
  String get disclaimerBody => '''
본 앱은 동맥혈/정맥혈 가스(ABG/VBG) 해석을 학습·확인하기 위한 보조 도구입니다.

• 계산·해석 결과는 일반적인 알고리즘에 기반한 참고 정보이며, 진단·치료를 위한 의료기기가 아닙니다.
• 보상 공식과 기준값은 주로 성인 기준입니다. 소아·신생아·임신 등에서는 다를 수 있습니다.
• 입력 오류나 특수한 병태에서는 결과가 부정확할 수 있습니다.
• 최종 임상 판단은 환자 전체 상태를 고려하여 반드시 자격 있는 의료진이 내려야 합니다.
• 본 앱 사용으로 발생한 어떠한 손해에 대해서도 개발자는 책임지지 않습니다.

모든 환자 데이터는 기기 내에만 저장되며 외부로 전송되지 않습니다.''';
  @override
  String get disclaimerAgree => '동의하고 시작';

  @override
  String get primaryDiagnosisLabel => '일차 진단';
  @override
  String get clinicalSuggestionsTitle => '임상적 시사 / 감별진단';

  @override
  String get step1Title => 'Step 1: 일차 이상 판정';
  @override
  String get step2Title => 'Step 2: 원발 장애 분류';
  @override
  String get step3Title => 'Step 3: 보상 평가';
  @override
  String get step4Title => 'Step 4: 음이온차 (AG)';
  @override
  String get step5Title => 'Step 5: 델타비 (Δ/Δ)';
  @override
  String get step6Title => 'Step 6: 산소화 평가';
  @override
  String get tempSectionTitle => '참고: 체온 보정';
  @override
  String get analysisModeVenousTitle => '분석 모드: 정맥혈(VBG)';

  @override
  String get dxNormal => '정상 범위(뚜렷한 산-염기 이상 없음)';
  @override
  String get dxMetAcidosis => '대사성 산증';
  @override
  String get dxMetAlkalosis => '대사성 알칼리증';
  @override
  String get dxRespAcidosis => '호흡성 산증';
  @override
  String get dxRespAlkalosis => '호흡성 알칼리증';

  @override
  String phAcidemia(String ph, String low) => '산혈증 (pH $ph < $low)';
  @override
  String phAlkalemia(String ph, String high) => '알칼리혈증 (pH $ph > $high)';
  @override
  String phNormal(String ph) => '정상 pH ($ph)';
  @override
  String abnLow(String name, String value, String unit, String low, String high) =>
      '$name $value $unit(낮음, 정상 $low–$high)';
  @override
  String abnHigh(String name, String value, String unit, String low, String high) =>
      '$name $value $unit(높음, 정상 $low–$high)';
  @override
  String abnNormal(String name, String value, String unit, String low, String high) =>
      '$name $value $unit(정상 $low–$high)';

  @override
  String primaryDisorderLine(String label) => '원발 장애: $label';
  @override
  String get mixedRespMetAcidosis => '호흡성 산증 + 대사성 산증의 혼합성 장애가 의심됩니다.';
  @override
  String get mixedRespMetAlkalosis => '호흡성 알칼리증 + 대사성 알칼리증의 혼합성 장애가 의심됩니다.';

  @override
  String wintersExpected(String value, String measured) =>
      'Winters 공식 예상 PaCO2 = $value ± 2 mmHg (측정 $measured)';
  @override
  String metAlkExpected(String value, String measured) =>
      '예상 PaCO2 = 0.7×HCO3- + 21 = $value ± 2 mmHg (측정 $measured)';
  @override
  String respExpectedAcuteChronic(String acute, String chronic, String measured) =>
      '급성 예상 HCO3- = $acute / 만성 = $chronic mEq/L (측정 $measured)';
  @override
  String get respCompAppropriate => '적절한 호흡성 보상(예상 범위 내).';
  @override
  String get respCompHigh => '측정 PaCO2가 예상보다 높음 → 보상 부족 또는 호흡성 산증 동반.';
  @override
  String get respCompLow => '측정 PaCO2가 예상보다 낮음 → 과보상 또는 호흡성 알칼리증 동반.';
  @override
  String metCompAppropriate(String phase) => '측정 HCO3-가 예상 범위 내 → $phase에 가까운 적절한 대사성 보상.';
  @override
  String get phaseAcute => '급성';
  @override
  String get phaseChronic => '만성';
  @override
  String get metCompHigh => '측정 HCO3-가 예상보다 높음 → 대사성 알칼리증 동반 의심.';
  @override
  String get metCompLow => '측정 HCO3-가 예상보다 낮음 → 대사성 산증 동반 의심.';
  @override
  String get noCompNeeded => '원발 장애가 없어 보상 평가가 필요하지 않습니다.';
  @override
  String get sugMixedRespAcidosis => '대사성 장애에 호흡성 산증이 동반된 혼합성 장애 가능성.';
  @override
  String get sugMixedRespAlkalosis => '대사성 장애에 호흡성 알칼리증이 동반된 혼합성 장애 가능성.';
  @override
  String get sugRespWithMetAlk => '호흡성 장애에 대사성 알칼리증이 동반된 혼합성 장애 가능성.';
  @override
  String get sugRespWithMetAcid => '호흡성 장애에 대사성 산증이 동반된 혼합성 장애 가능성.';

  @override
  String agFormula(String value, String low, String high) =>
      'AG = Na - (Cl + HCO3-) = $value mEq/L(정상 $low–$high)';
  @override
  String agAlbCorrected(String value, String alb) =>
      '알부민 보정 AG = $value mEq/L(Alb $alb g/dL)';
  @override
  String agHigh(String value, String high) =>
      'AG 증가($value > $high) → 고 AG 대사성 산증 시사.';
  @override
  String agLow(String value, String low) =>
      'AG 낮음($value < $low) → 저알부민혈증·고 Ca/Mg·이상단백혈증 고려.';
  @override
  String agNormal(String value) => 'AG 정상($value).';
  @override
  String get agNotAvailable => 'Na/Cl 미입력으로 AG를 계산할 수 없습니다.';
  @override
  String get sugHighAg =>
      '고 AG 대사성 산증 감별: 젖산산증, 케톤산증, 신부전(요독증), 중독(메탄올/에틸렌글리콜/살리실산) 등.';

  @override
  String deltaValues(String dAg, String dHco3) => 'ΔAG = $dAg, ΔHCO3- = $dHco3';
  @override
  String get deltaNoGap => 'AG 증가가 없어 델타비 해석이 제한적입니다.';
  @override
  String get deltaHco3Zero => 'ΔHCO3- ≈ 0이라 비를 계산할 수 없습니다.';
  @override
  String deltaRatio(String ratio) => '델타비 = ΔAG / ΔHCO3- = $ratio';
  @override
  String get deltaLt04 => '< 0.4 → 정상 AG 대사성 산증 동반 시사.';
  @override
  String get delta04to1 => '0.4–1.0 → 고 AG와 정상 AG 대사성 산증의 혼합형.';
  @override
  String get delta1to2 => '1.0–2.0 → 순수 고 AG 대사성 산증에 부합.';
  @override
  String get deltaGt2 => '> 2.0 → 대사성 알칼리증(또는 만성 호흡성 산증) 동반 시사.';
  @override
  String get sugDeltaLt04 => '고 AG에 정상 AG(고염소성) 대사성 산증 동반.';
  @override
  String get sugDelta04to1 => '고 AG와 정상 AG 대사성 산증의 혼합.';
  @override
  String get sugDeltaGt2 => '고 AG 대사성 산증에 대사성 알칼리증(또는 만성 호흡성 산증) 동반.';
  @override
  String get deltaNotAvailable => 'AG를 구할 수 없어 델타비를 평가할 수 없습니다.';

  @override
  String get pao2NotEntered => 'PaO2 미입력으로 산소화를 평가할 수 없습니다.';
  @override
  String pao2Line(String value) => 'PaO2 = $value mmHg';
  @override
  String pao2LineLow(String value, String low) =>
      'PaO2 = $value mmHg(저산소혈증: 정상 하한 $low)';
  @override
  String pfRatio(String value, String label) =>
      'P/F 비 = PaO2 / FiO2 = $value → $label';
  @override
  String get pfNormal => '정상~경증';
  @override
  String get pfArdsMild => '경증 ARDS 범위 (200–299)';
  @override
  String get pfArdsModerate => '중등증 ARDS 범위 (100–199)';
  @override
  String get pfArdsSevere => '중증 ARDS 범위 (<100)';
  @override
  String sugPfLow(String label) =>
      'P/F 비 저하($label). ARDS 진단에는 Berlin 기준(PEEP≥5cmH2O, 양측 음영, 심인성 배제)이 필요합니다.';
  @override
  String aado2(String value, String palv) =>
      'A-aDO2 ≈ $value mmHg(PAO2 $palv − PaO2, 해수면/R=0.8 가정)';
  @override
  String get fio2NotEntered => 'FiO2 미입력으로 P/F 비·A-aDO2를 계산할 수 없습니다.';
  @override
  String get venousOxyNotApplicable => '정맥혈 모드에서는 산소화 평가(P/F 비·A-aDO2)를 적용하지 않습니다.';
  @override
  String venousOxyReference(String label, String value) =>
      '참고: $label = $value mmHg(정맥혈 값은 산소화 지표로 사용하지 않음)';

  @override
  String tempCorrHeader(String temp) => '체온 $temp°C에서의 참고 보정값(해석 본체는 37°C 값으로 수행):';
  @override
  String tempCorrPh(String value) => '  보정 pH ≈ $value';
  @override
  String tempCorrPaco2(String value) => '  보정 PaCO2 ≈ $value mmHg';
  @override
  String tempCorrPao2(String value) => '  보정 PaO2 ≈ $value mmHg';
  @override
  String get tempCorrNote =>
      '  * 체온 보정은 alpha-stat/pH-stat 논쟁이 있으니 기관 방침을 따르세요.';

  @override
  String get venousModeNote => '정맥혈(VBG) 모드';
  @override
  String get venousModeLine1 =>
      '정맥혈 정상값(pH 7.31–7.41 / PvCO2 41–51 / HCO3- 22–26)으로 판정합니다.';
  @override
  String get venousModeLine2 => '보상 평가는 동맥혈과 동일한 계산 로직을 사용합니다.';
  @override
  String get venousModeLine3 => '산소화 평가(P/F 비·A-aDO2)는 동맥혈 지표이므로 정맥혈 모드에서는 적용되지 않습니다.';
  @override
  String get venousModeLine4 =>
      '* VBG와 ABG는 특히 PCO2에서 차이가 있을 수 있습니다. 확정적 판단에는 동맥혈 확인을 고려하세요.';
  @override
  String get sugVenous =>
      '정맥혈 해석입니다. pH·HCO3-는 동맥혈과 잘 상관하지만 PvCO2는 PaCO2보다 높게 나옵니다.';

  @override
  String get diffRespAcidosis =>
      '호흡성 산증 감별: COPD 악화, 호흡 억제(진정제/오피오이드), 신경근 질환, 흉곽/기도 폐쇄, 환기 부전.';
  @override
  String get diffRespAlkalosis =>
      '호흡성 알칼리증 감별: 과환기(불안/통증), 저산소, 폐색전, 패혈증, 간부전, 살리실산 중독, 임신.';
  @override
  String get diffMetAlkalosis =>
      '대사성 알칼리증 감별: 구토/위액 소실, 이뇨제, 저칼륨혈증, 무기질코르티코이드 과다, 알칼리 과다 투여.';
  @override
  String get diffNormalAgMetAcidosis =>
      '정상 AG(고염소성) 대사성 산증 감별: 설사, 신세뇨관 산증(RTA), 다량 생리식염수, 탄산탈수효소 억제제.';
  @override
  String get diffHighAgMetAcidosis =>
      '고 AG 대사성 산증 감별(GOLDMARK/MUDPILES): 젖산, 케톤체, 신부전, 메탄올/에틸렌글리콜/살리실산 등.';

  @override
  String get shareHeader => '【혈액가스 판정 결과】';
  @override
  String shareModeNote(String note) => '［$note］';
  @override
  String sharePrimary(String dx) => '일차 진단: $dx';
  @override
  String get shareSuggestionsHeader => '임상적 시사 / 감별진단';
  @override
  String get shareDisclaimer => '* 본 결과는 임상 보조용이며 최종 판단은 반드시 의료진이 내려야 합니다.';

  @override
  String get nomoTitle => '산-염기 평형 노모그램 (Cohen)';
  @override
  String get nomoTapHint => '차트를 탭하면 값 표시 / 핀치로 확대.';
  @override
  String get nomoFullScreen => '전체 화면';
  @override
  String get nomoPlottedPoint => '표시 점';
  @override
  String get nomoAssessmentPrefix => '판정: ';
  @override
  String get nomoPaco2CalcPrefix => 'PaCO2(계산): ';
  @override
  String get axisPh => '동맥혈 pH';
  @override
  String get axisHco3 => '동맥혈장 [HCO3-] (mmol/L)';
  @override
  String get axisHplus => '동맥혈 [H+] (nmol/L)';
  @override
  String get axisPco2 => 'pCO2 (mmHg)';
  @override
  String get rNormal => '정상';
  @override
  String get rMetAcid => '대사성 산증';
  @override
  String get rMetAlk => '대사성 알칼리증';
  @override
  String get rAcuteRespAcid => '급성 호흡성 산증';
  @override
  String get rChronicRespAcid => '만성 호흡성 산증';
  @override
  String get rAcuteRespAlk => '급성 호흡성 알칼리증';
  @override
  String get rChronicRespAlk => '만성 호흡성 알칼리증';
  @override
  String get mMixedRespAcidMetAlk => '혼합 호흡성산+대사성알칼리';
  @override
  String get mMetAlkNoComp => '대사성 알칼리(보상 부족)';
  @override
  String get mMixedRespMetAlk => '혼합 호흡성+대사성 알칼리증';
  @override
  String get mAcuteOnChronicRespAlk => '만성 위 급성 호흡성알칼리';
  @override
  String get mMixedMetAcidRespAlk => '혼합 대사성산+호흡성알칼리';
  @override
  String get mMixedRespMetAcid => '혼합 호흡성+대사성 산증';
  @override
  String get mMetAcidNoComp => '대사성 산(보상 부족)';
  @override
  String get mAcuteOnChronicRespAcid => '만성 위 급성 호흡성산';
}
