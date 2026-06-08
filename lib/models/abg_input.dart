/// ABG（動脈血液ガス）の入力値。
///
/// 必須は pH・PaCO2・HCO3-。その他は任意で、与えられた場合のみ
/// 対応する解析（AG、デルタ比、酸素化など）を実行する。
class AbgInput {
  final double ph;
  final double paco2; // mmHg
  final double hco3; // mEq/L
  final double? pao2; // mmHg
  final double? be; // mEq/L (Base Excess)
  final double? fio2; // % (21–100)
  final double? na; // mEq/L
  final double? cl; // mEq/L
  final double? albumin; // g/dL（AG 補正用、未入力なら 4.0 とみなす）
  final double? temperature; // ℃（温度補正用、任意）

  const AbgInput({
    required this.ph,
    required this.paco2,
    required this.hco3,
    this.pao2,
    this.be,
    this.fio2,
    this.na,
    this.cl,
    this.albumin,
    this.temperature,
  });

  bool get hasAnionGapInputs => na != null && cl != null;
  bool get hasOxygenationInputs => pao2 != null && fio2 != null && fio2! > 0;

  Map<String, dynamic> toJson() => {
        'ph': ph,
        'paco2': paco2,
        'hco3': hco3,
        'pao2': pao2,
        'be': be,
        'fio2': fio2,
        'na': na,
        'cl': cl,
        'albumin': albumin,
        'temperature': temperature,
      };

  factory AbgInput.fromJson(Map<String, dynamic> json) {
    double? d(dynamic v) => v == null ? null : (v as num).toDouble();
    return AbgInput(
      ph: d(json['ph'])!,
      paco2: d(json['paco2'])!,
      hco3: d(json['hco3'])!,
      pao2: d(json['pao2']),
      be: d(json['be']),
      fio2: d(json['fio2']),
      na: d(json['na']),
      cl: d(json['cl']),
      albumin: d(json['albumin']),
      temperature: d(json['temperature']),
    );
  }
}
