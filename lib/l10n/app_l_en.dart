import 'app_l.dart';

/// English strings.
class AppLEn extends AppL {
  const AppLEn();

  @override
  String get appTitle => 'Blood Gas Analyzer';
  @override
  String get appBarTitle => 'ABG/VBG Assessment';
  @override
  String get languageName => 'English';
  @override
  String get selectLanguage => 'Language';
  @override
  String get systemDefault => 'System default';
  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get arterialAbg => 'Arterial (ABG)';
  @override
  String get venousVbg => 'Venous (VBG)';
  @override
  String get adult => 'Adult';
  @override
  String get pediatric => 'Pediatric';

  @override
  String get interpret => 'Interpret';
  @override
  String get clear => 'Clear';
  @override
  String get copy => 'Copy';
  @override
  String get share => 'Share';
  @override
  String get historyMenu => 'History';
  @override
  String get disclaimerMenu => 'Disclaimer';

  @override
  String get groupRequired => 'Required';
  @override
  String get groupOxygenation => 'Oxygenation';
  @override
  String get groupOxygenationVenousNa => 'Oxygenation (N/A for venous)';
  @override
  String get groupElectrolytes => 'Electrolytes (for AG)';
  @override
  String get groupOther => 'Other (optional)';

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
  String get fieldAlb => 'Alb (g/dL) optional';
  @override
  String get fieldBe => 'BE (mEq/L)';
  @override
  String get fieldTemp => 'Temp (°C)';
  @override
  String hintEg(String v) => 'e.g. $v';
  @override
  String get hintFio2RoomAir => 'room air = 21';
  @override
  String get hintReference => 'reference';
  @override
  String get hintAlbDefault => 'default 4.0';
  @override
  String get toggleSign => 'Toggle sign (+/-)';

  @override
  String get ocrButton => 'Scan report to auto-fill (OCR)';
  @override
  String get ocrCamera => 'Take photo';
  @override
  String get ocrGallery => 'Choose image';
  @override
  String get ocrReviewTitle => 'Review OCR result';
  @override
  String ocrReviewDesc(int found, int total) =>
      'Auto-extracted $found of $total fields. Edit any errors before applying.';
  @override
  String get ocrApply => 'Apply to form';
  @override
  String get cancel => 'Cancel';
  @override
  String get ocrShowRaw => 'Show recognized text';
  @override
  String get ocrNoText => '(no text recognized)';
  @override
  String ocrReference(String items) => 'Reference (not used in calc): $items';

  @override
  String get snackRequired =>
      'pH, PaCO2 and HCO3- are required (enter numbers).';
  @override
  String get snackPhRange =>
      'pH is out of expected range (6.5–8.0). Please check.';
  @override
  String get snackCopied => 'Result copied to clipboard.';
  @override
  String snackOcrApplied(int count) =>
      '$count fields applied to the form. Please verify.';
  @override
  String snackOcrFailed(String error) => 'OCR failed: $error';

  @override
  String get historyTitle => 'Input history';
  @override
  String get historyEmpty => 'No history.';
  @override
  String get historyDeleteAll => 'Delete all';
  @override
  String get historyDeleteAllTitle => 'Delete all history';
  @override
  String get historyDeleteAllBody => 'Delete all saved history?';
  @override
  String get delete => 'Delete';
  @override
  String get tagArterial => 'Arterial';
  @override
  String get tagVenous => 'Venous';
  @override
  String get tagPediatric => 'Pediatric';
  @override
  String get resultLabel => 'Result';

  @override
  String get disclaimerTitle => 'Disclaimer';
  @override
  String get disclaimerBody => '''
This app is a supportive tool for learning and checking arterial/venous blood gas (ABG/VBG) interpretation.

• Calculations and interpretations are reference information based on common algorithms; this is not a medical device for diagnosis or treatment.
• Compensation formulas and reference values are mainly for adults. Children, neonates, and pregnancy may differ.
• Input errors or unusual conditions may yield inaccurate results.
• Final clinical decisions must always be made by a qualified healthcare professional considering the whole patient picture.
• The developer assumes no responsibility for any damages arising from use of this app.

All patient data is stored only on the device and is never transmitted externally.''';
  @override
  String get disclaimerAgree => 'Agree and start';

  @override
  String get primaryDiagnosisLabel => 'Primary diagnosis';
  @override
  String get clinicalSuggestionsTitle => 'Clinical implications / differentials';

  @override
  String get step1Title => 'Step 1: Primary abnormality';
  @override
  String get step2Title => 'Step 2: Classify primary disorder';
  @override
  String get step3Title => 'Step 3: Compensation';
  @override
  String get step4Title => 'Step 4: Anion gap (AG)';
  @override
  String get step5Title => 'Step 5: Delta ratio (Δ/Δ)';
  @override
  String get step6Title => 'Step 6: Oxygenation';
  @override
  String get tempSectionTitle => 'Reference: temperature correction';
  @override
  String get analysisModeVenousTitle => 'Analysis mode: Venous (VBG)';

  @override
  String get dxNormal => 'Normal range (no clear acid–base disorder)';
  @override
  String get dxMetAcidosis => 'Metabolic acidosis';
  @override
  String get dxMetAlkalosis => 'Metabolic alkalosis';
  @override
  String get dxRespAcidosis => 'Respiratory acidosis';
  @override
  String get dxRespAlkalosis => 'Respiratory alkalosis';

  @override
  String phAcidemia(String ph, String low) => 'Acidemia (pH $ph < $low)';
  @override
  String phAlkalemia(String ph, String high) => 'Alkalemia (pH $ph > $high)';
  @override
  String phNormal(String ph) => 'Normal pH ($ph)';
  @override
  String abnLow(String name, String value, String unit, String low, String high) =>
      '$name $value $unit (low, normal $low–$high)';
  @override
  String abnHigh(String name, String value, String unit, String low, String high) =>
      '$name $value $unit (high, normal $low–$high)';
  @override
  String abnNormal(String name, String value, String unit, String low, String high) =>
      '$name $value $unit (normal $low–$high)';

  @override
  String primaryDisorderLine(String label) => 'Primary disorder: $label';
  @override
  String get mixedRespMetAcidosis =>
      'Mixed respiratory + metabolic acidosis suspected.';
  @override
  String get mixedRespMetAlkalosis =>
      'Mixed respiratory + metabolic alkalosis suspected.';

  @override
  String wintersExpected(String value, String measured) =>
      "Winter's formula: expected PaCO2 = $value ± 2 mmHg (measured $measured)";
  @override
  String metAlkExpected(String value, String measured) =>
      'Expected PaCO2 = 0.7×HCO3- + 21 = $value ± 2 mmHg (measured $measured)';
  @override
  String respExpectedAcuteChronic(String acute, String chronic, String measured) =>
      'Acute expected HCO3- = $acute / Chronic = $chronic mEq/L (measured $measured)';
  @override
  String get respCompAppropriate =>
      'Appropriate respiratory compensation (within expected range).';
  @override
  String get respCompHigh =>
      'Measured PaCO2 higher than expected → inadequate compensation or concurrent respiratory acidosis.';
  @override
  String get respCompLow =>
      'Measured PaCO2 lower than expected → overcompensation or concurrent respiratory alkalosis.';
  @override
  String metCompAppropriate(String phase) =>
      'Measured HCO3- within expected range → appropriate $phase metabolic compensation.';
  @override
  String get phaseAcute => 'acute';
  @override
  String get phaseChronic => 'chronic';
  @override
  String get metCompHigh =>
      'Measured HCO3- higher than expected → concurrent metabolic alkalosis suspected.';
  @override
  String get metCompLow =>
      'Measured HCO3- lower than expected → concurrent metabolic acidosis suspected.';
  @override
  String get noCompNeeded =>
      'No primary disorder; compensation assessment not needed.';
  @override
  String get sugMixedRespAcidosis =>
      'Possible mixed disorder: metabolic disorder with concurrent respiratory acidosis.';
  @override
  String get sugMixedRespAlkalosis =>
      'Possible mixed disorder: metabolic disorder with concurrent respiratory alkalosis.';
  @override
  String get sugRespWithMetAlk =>
      'Possible mixed disorder: respiratory disorder with concurrent metabolic alkalosis.';
  @override
  String get sugRespWithMetAcid =>
      'Possible mixed disorder: respiratory disorder with concurrent metabolic acidosis.';

  @override
  String agFormula(String value, String low, String high) =>
      'AG = Na - (Cl + HCO3-) = $value mEq/L (normal $low–$high)';
  @override
  String agAlbCorrected(String value, String alb) =>
      'Albumin-corrected AG = $value mEq/L (Alb $alb g/dL)';
  @override
  String agHigh(String value, String high) =>
      'High AG ($value > $high) → suggests high-AG metabolic acidosis.';
  @override
  String agLow(String value, String low) =>
      'Low AG ($value < $low) → consider hypoalbuminemia, high Ca/Mg, paraproteinemia.';
  @override
  String agNormal(String value) => 'AG normal ($value).';
  @override
  String get agNotAvailable => 'Na/Cl not entered; AG cannot be calculated.';
  @override
  String get sugHighAg =>
      'High-AG metabolic acidosis: lactic acidosis, ketoacidosis, renal failure (uremia), toxins (methanol/ethylene glycol/salicylate), etc.';

  @override
  String deltaValues(String dAg, String dHco3) =>
      'ΔAG = $dAg, ΔHCO3- = $dHco3';
  @override
  String get deltaNoGap =>
      'No AG elevation; delta-ratio interpretation is limited.';
  @override
  String get deltaHco3Zero => 'ΔHCO3- ≈ 0; ratio cannot be computed.';
  @override
  String deltaRatio(String ratio) => 'Δ ratio = ΔAG / ΔHCO3- = $ratio';
  @override
  String get deltaLt04 =>
      '< 0.4 → suggests concurrent normal-AG metabolic acidosis.';
  @override
  String get delta04to1 =>
      '0.4–1.0 → mixed high-AG and normal-AG metabolic acidosis.';
  @override
  String get delta1to2 =>
      '1.0–2.0 → consistent with pure high-AG metabolic acidosis.';
  @override
  String get deltaGt2 =>
      '> 2.0 → suggests concurrent metabolic alkalosis (or chronic respiratory acidosis).';
  @override
  String get sugDeltaLt04 =>
      'High-AG plus normal-AG (hyperchloremic) metabolic acidosis.';
  @override
  String get sugDelta04to1 =>
      'Mixed high-AG and normal-AG metabolic acidosis.';
  @override
  String get sugDeltaGt2 =>
      'High-AG metabolic acidosis with concurrent metabolic alkalosis (or chronic respiratory acidosis).';
  @override
  String get deltaNotAvailable =>
      'AG unavailable; delta ratio cannot be evaluated.';

  @override
  String get pao2NotEntered =>
      'PaO2 not entered; oxygenation cannot be assessed.';
  @override
  String pao2Line(String value) => 'PaO2 = $value mmHg';
  @override
  String pao2LineLow(String value, String low) =>
      'PaO2 = $value mmHg (hypoxemia: normal lower limit $low)';
  @override
  String pfRatio(String value, String label) =>
      'P/F ratio = PaO2 / FiO2 = $value → $label';
  @override
  String get pfNormal => 'normal to mild';
  @override
  String get pfArdsMild => 'mild ARDS range (200–299)';
  @override
  String get pfArdsModerate => 'moderate ARDS range (100–199)';
  @override
  String get pfArdsSevere => 'severe ARDS range (<100)';
  @override
  String sugPfLow(String label) =>
      'Reduced P/F ratio ($label). ARDS diagnosis requires Berlin criteria (PEEP≥5cmH2O, bilateral opacities, exclusion of cardiogenic cause).';
  @override
  String aado2(String value, String palv) =>
      'A-aDO2 ≈ $value mmHg (PAO2 $palv − PaO2; sea level, R=0.8)';
  @override
  String get fio2NotEntered =>
      'FiO2 not entered; P/F ratio and A-aDO2 cannot be calculated.';
  @override
  String get venousOxyNotApplicable =>
      'Oxygenation (P/F ratio, A-aDO2) is not applicable in venous mode.';
  @override
  String venousOxyReference(String label, String value) =>
      'Reference: $label = $value mmHg (venous value not used as oxygenation index)';

  @override
  String tempCorrHeader(String temp) =>
      'Reference correction at body temp $temp°C (interpretation uses 37°C values):';
  @override
  String tempCorrPh(String value) => '  Corrected pH ≈ $value';
  @override
  String tempCorrPaco2(String value) => '  Corrected PaCO2 ≈ $value mmHg';
  @override
  String tempCorrPao2(String value) => '  Corrected PaO2 ≈ $value mmHg';
  @override
  String get tempCorrNote =>
      "  * Temperature correction is debated (alpha-stat/pH-stat); follow your institution's policy.";

  @override
  String get venousModeNote => 'Venous (VBG) mode';
  @override
  String get venousModeLine1 =>
      'Assessed using venous normal ranges (pH 7.31–7.41 / PvCO2 41–51 / HCO3- 22–26).';
  @override
  String get venousModeLine2 =>
      'Compensation is evaluated with the same formulas as arterial blood.';
  @override
  String get venousModeLine3 =>
      'Oxygenation (P/F ratio, A-aDO2) uses arterial indices and is not applicable here.';
  @override
  String get venousModeLine4 =>
      '* VBG and ABG can differ, especially in PCO2. Consider arterial confirmation for definitive decisions.';
  @override
  String get sugVenous =>
      'Venous interpretation. pH and HCO3- correlate well with arterial, but PvCO2 tends to be higher than PaCO2.';

  @override
  String get diffRespAcidosis =>
      'Respiratory acidosis: COPD exacerbation, respiratory depression (sedatives/opioids), neuromuscular disease, chest/airway obstruction, hypoventilation.';
  @override
  String get diffRespAlkalosis =>
      'Respiratory alkalosis: hyperventilation (anxiety/pain), hypoxia, pulmonary embolism, sepsis, liver failure, salicylate toxicity, pregnancy.';
  @override
  String get diffMetAlkalosis =>
      'Metabolic alkalosis: vomiting/gastric loss, diuretics, hypokalemia, mineralocorticoid excess, alkali administration.';
  @override
  String get diffNormalAgMetAcidosis =>
      'Normal-AG (hyperchloremic) metabolic acidosis: diarrhea, renal tubular acidosis (RTA), large-volume saline, carbonic anhydrase inhibitors.';
  @override
  String get diffHighAgMetAcidosis =>
      'High-AG metabolic acidosis (GOLDMARK/MUDPILES): lactate, ketones, renal failure, methanol/ethylene glycol/salicylate, etc.';

  @override
  String get shareHeader => '[Blood Gas Interpretation]';
  @override
  String shareModeNote(String note) => '[$note]';
  @override
  String sharePrimary(String dx) => 'Primary diagnosis: $dx';
  @override
  String get shareSuggestionsHeader => 'Clinical implications / differentials';
  @override
  String get shareDisclaimer =>
      '* This result is a clinical aid. Final decisions must be made by a healthcare professional.';

  @override
  String get nomoTitle => 'Acid–Base Nomogram (Cohen)';
  @override
  String get nomoTapHint => 'Tap the chart to show values / pinch to zoom.';
  @override
  String get nomoFullScreen => 'Full screen';
  @override
  String get nomoPlottedPoint => 'Plotted point';
  @override
  String get nomoAssessmentPrefix => 'Assessment: ';
  @override
  String get nomoPaco2CalcPrefix => 'PaCO2(calc): ';
  @override
  String get axisPh => 'Arterial blood pH';
  @override
  String get axisHco3 => 'Arterial plasma [HCO3-] (mmol/L)';
  @override
  String get axisHplus => 'Arterial blood [H+] (nmol/L)';
  @override
  String get axisPco2 => 'pCO2 (mmHg)';
  @override
  String get rNormal => 'Normal';
  @override
  String get rMetAcid => 'Metabolic acidosis';
  @override
  String get rMetAlk => 'Metabolic alkalosis';
  @override
  String get rAcuteRespAcid => 'Acute respiratory acidosis';
  @override
  String get rChronicRespAcid => 'Chronic respiratory acidosis';
  @override
  String get rAcuteRespAlk => 'Acute respiratory alkalosis';
  @override
  String get rChronicRespAlk => 'Chronic respiratory alkalosis';
  @override
  String get mMixedRespAcidMetAlk => 'Mixed Resp.Acid. & Met. Alk.';
  @override
  String get mMetAlkNoComp => 'Met.Alk. w/o expected Resp. comp.';
  @override
  String get mMixedRespMetAlk => 'Mixed Resp. & Met. Alkalosis';
  @override
  String get mAcuteOnChronicRespAlk => 'Acute on Chronic Resp. Alk.';
  @override
  String get mMixedMetAcidRespAlk => 'Mixed Met.Acid. & Resp.Alk.';
  @override
  String get mMixedRespMetAcid => 'Mixed Resp. & Met. Acidosis';
  @override
  String get mMetAcidNoComp => 'Met.Acid. w/o expected resp. comp.';
  @override
  String get mAcuteOnChronicRespAcid => 'Acute on Chronic Resp. Acid.';
}
