/// 解釈結果の重大度（色分けに使用）。
enum Severity {
  normal, // 緑
  acidosis, // 赤
  alkalosis, // 青
  warning, // 橙（混合性障害・代償不適切など）
  info, // 中立
}

/// 結果の 1 行。
class ResultLine {
  final String text;
  final Severity severity;
  const ResultLine(this.text, [this.severity = Severity.info]);
}

/// Step ごとの結果セクション。
class ResultSection {
  final String title;
  final Severity severity;
  final List<ResultLine> lines;
  const ResultSection({
    required this.title,
    this.severity = Severity.info,
    this.lines = const [],
  });
}

/// 解析全体の結果。
class AbgResult {
  /// 一次診断（例: 代謝性アシドーシス）。
  final String primaryDiagnosis;
  final Severity primarySeverity;

  /// 段階表示用セクション（Step 1〜6）。
  final List<ResultSection> sections;

  /// 鑑別診断・臨床的示唆。
  final List<String> clinicalSuggestions;

  /// 解析モードの注記（静脈血モード時などに表示）。null なら注記なし。
  final String? modeNote;

  const AbgResult({
    required this.primaryDiagnosis,
    required this.primarySeverity,
    required this.sections,
    required this.clinicalSuggestions,
    this.modeNote,
  });

  /// コピー・共有用のプレーンテキスト。
  String toShareText() {
    final b = StringBuffer();
    b.writeln('【血液ガス 解釈結果】');
    if (modeNote != null) b.writeln('［$modeNote］');
    b.writeln('一次診断: $primaryDiagnosis');
    b.writeln('');
    for (final s in sections) {
      b.writeln('■ ${s.title}');
      for (final l in s.lines) {
        b.writeln('  ・${l.text}');
      }
      b.writeln('');
    }
    if (clinicalSuggestions.isNotEmpty) {
      b.writeln('■ 臨床的示唆 / 鑑別診断');
      for (final c in clinicalSuggestions) {
        b.writeln('  ・$c');
      }
      b.writeln('');
    }
    b.writeln('※ 本結果は臨床判断の補助です。最終判断は必ず医療者が行ってください。');
    return b.toString();
  }
}
