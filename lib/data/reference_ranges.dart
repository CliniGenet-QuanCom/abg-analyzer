/// 基準値（正常範囲）。動脈血(ABG)/静脈血(VBG) × 成人/小児 を切り替えできる。
///
/// 注意: 酸塩基平衡の代償式（Winters 式など）は動脈血・成人での検証値を用いる。
/// VBG モードでは正常値（ハイライト判定）のみ静脈血用に切り替え、代償式の
/// ロジックは動脈血と同一を流用する。
class ReferenceRanges {
  final String label;

  final double phLow;
  final double phHigh;

  final double paco2Low;
  final double paco2High;

  final double hco3Low;
  final double hco3High;

  final double beLow;
  final double beHigh;

  final double agLow;
  final double agHigh;

  /// 正常 PaO2 のおおよその下限（室内気）。酸素化評価の参考表示用。
  final double pao2Low;

  /// 静脈血モードか。true の場合、酸素化評価(P/F 比・A-aDO2)は非適用。
  final bool venous;

  /// CO2 の表示ラベル（動脈: PaCO2 / 静脈: PvCO2）。
  final String co2Label;

  /// O2 の表示ラベル（動脈: PaO2 / 静脈: PvO2）。
  final String o2Label;

  const ReferenceRanges({
    required this.label,
    required this.phLow,
    required this.phHigh,
    required this.paco2Low,
    required this.paco2High,
    required this.hco3Low,
    required this.hco3High,
    required this.beLow,
    required this.beHigh,
    required this.agLow,
    required this.agHigh,
    required this.pao2Low,
    this.venous = false,
    this.co2Label = 'PaCO2',
    this.o2Label = 'PaO2',
  });

  // ---- 動脈血 (ABG) ----
  static const ReferenceRanges adult = ReferenceRanges(
    label: '成人・動脈',
    phLow: 7.35,
    phHigh: 7.45,
    paco2Low: 35,
    paco2High: 45,
    hco3Low: 22,
    hco3High: 26,
    beLow: -2,
    beHigh: 2,
    agLow: 8,
    agHigh: 12,
    pao2Low: 80,
  );

  /// 小児（おおよその目安）。新生児〜乳児では HCO3- がやや低めになる。
  static const ReferenceRanges pediatric = ReferenceRanges(
    label: '小児・動脈',
    phLow: 7.35,
    phHigh: 7.45,
    paco2Low: 30,
    paco2High: 40,
    hco3Low: 20,
    hco3High: 24,
    beLow: -4,
    beHigh: 2,
    agLow: 8,
    agHigh: 12,
    pao2Low: 70,
  );

  // ---- 静脈血 (VBG) ----
  /// 成人・静脈血の正常値。pH 7.31–7.41 / PvCO2 41–51 / HCO3- 22–26。
  static const ReferenceRanges adultVenous = ReferenceRanges(
    label: '成人・静脈',
    phLow: 7.31,
    phHigh: 7.41,
    paco2Low: 41,
    paco2High: 51,
    hco3Low: 22,
    hco3High: 26,
    beLow: -2,
    beHigh: 2,
    agLow: 8,
    agHigh: 12,
    pao2Low: 30, // 参考値（静脈血では酸素化評価には使用しない）
    venous: true,
    co2Label: 'PvCO2',
    o2Label: 'PvO2',
  );

  /// 小児・静脈血（おおよその目安。成人静脈値を基に小児の HCO3- を反映）。
  static const ReferenceRanges pediatricVenous = ReferenceRanges(
    label: '小児・静脈',
    phLow: 7.31,
    phHigh: 7.41,
    paco2Low: 36,
    paco2High: 46,
    hco3Low: 20,
    hco3High: 24,
    beLow: -4,
    beHigh: 2,
    agLow: 8,
    agHigh: 12,
    pao2Low: 30,
    venous: true,
    co2Label: 'PvCO2',
    o2Label: 'PvO2',
  );

  /// 動脈/静脈 × 成人/小児 から該当する基準値を選択。
  static ReferenceRanges select(
      {required bool venous, required bool pediatric}) {
    if (venous) {
      return pediatric ? pediatricVenous : adultVenous;
    }
    return pediatric ? ReferenceRanges.pediatric : adult;
  }
}
