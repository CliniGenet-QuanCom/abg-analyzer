import 'package:flutter/material.dart';

import '../models/abg_result.dart';

/// Material 3 テーマ（ライト/ダーク）。
class AppTheme {
  static const Color seed = Color(0xFF00696E); // ティール系

  static ThemeData light({String? fontFamily}) =>
      _themed(Brightness.light, fontFamily);
  static ThemeData dark({String? fontFamily}) =>
      _themed(Brightness.dark, fontFamily);

  /// アプリにバンドルした日本語フォントのファミリ名（pubspec の fonts と一致）。
  static const String jaFontFamily = 'NotoSansJP';

  /// ロケールに応じたフォントファミリを返す。
  ///
  /// 日本語ではバンドルの Noto Sans JP を使う（漢字が中国語グリフへフォールバック
  /// するのを防ぎ、オフラインでも正しく表示するため）。中国語・韓国語・英語では
  /// null を返し、端末の各言語フォント（簡体字・ハングル等）に委ねる。
  /// （Noto Sans JP はハングルを含まず、簡体字は日本語字形になるため。）
  static String? fontFamilyFor(String? languageCode) =>
      languageCode == 'ja' ? jaFontFamily : null;

  static ThemeData _themed(Brightness brightness, String? fontFamily) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      fontFamily: fontFamily,
    );
    return base.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  /// 重大度に応じた前景色（テキスト・アイコン）。
  static Color severityColor(Severity s, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    switch (s) {
      case Severity.acidosis:
        return dark ? const Color(0xFFFF8A80) : const Color(0xFFC62828); // 赤
      case Severity.alkalosis:
        return dark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0); // 青
      case Severity.normal:
        return dark ? const Color(0xFF80E27E) : const Color(0xFF2E7D32); // 緑
      case Severity.warning:
        return dark ? const Color(0xFFFFD180) : const Color(0xFFE65100); // 橙
      case Severity.info:
        return dark ? const Color(0xFFCFD8DC) : const Color(0xFF455A64);
    }
  }

  /// 重大度に応じた背景色（カードのトーン）。
  static Color severityContainer(Severity s, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    switch (s) {
      case Severity.acidosis:
        return dark ? const Color(0x33C62828) : const Color(0xFFFDECEA);
      case Severity.alkalosis:
        return dark ? const Color(0x331565C0) : const Color(0xFFE7F0FB);
      case Severity.normal:
        return dark ? const Color(0x332E7D32) : const Color(0xFFE8F5E9);
      case Severity.warning:
        return dark ? const Color(0x33E65100) : const Color(0xFFFFF3E0);
      case Severity.info:
        return dark ? const Color(0x22607D8B) : const Color(0xFFF5F7F8);
    }
  }

  static IconData severityIcon(Severity s) {
    switch (s) {
      case Severity.acidosis:
        return Icons.south; // 下向き（酸性に傾く）
      case Severity.alkalosis:
        return Icons.north;
      case Severity.normal:
        return Icons.check_circle_outline;
      case Severity.warning:
        return Icons.warning_amber_rounded;
      case Severity.info:
        return Icons.info_outline;
    }
  }
}
