import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/history_repository.dart';
import 'l10n/app_l.dart';
import 'theme/app_theme.dart';
import 'ui/disclaimer_screen.dart';
import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AbgApp());
}

class AbgApp extends StatefulWidget {
  const AbgApp({super.key});

  @override
  State<AbgApp> createState() => _AbgAppState();
}

class _AbgAppState extends State<AbgApp> {
  final HistoryRepository _repo = HistoryRepository();
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  /// null = 端末設定に従う。
  final ValueNotifier<Locale?> _locale = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _repo.getLocaleCode().then((code) {
      if (code != null && mounted) _locale.value = Locale(code);
    });
  }

  @override
  void dispose() {
    _themeMode.dispose();
    _locale.dispose();
    super.dispose();
  }

  /// 実際に表示されるロケールの言語コード（未対応は ja にフォールバック）。
  String _effectiveLang(Locale? chosen) {
    final code = chosen?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return const {'ja', 'en', 'zh', 'ko'}.contains(code) ? code : 'ja';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: _locale,
          builder: (context, locale, _) {
            final fontFamily = AppTheme.fontFamilyFor(_effectiveLang(locale));
            return MaterialApp(
              onGenerateTitle: (context) => AppL.ofContext(context).appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(fontFamily: fontFamily),
              darkTheme: AppTheme.dark(fontFamily: fontFamily),
              themeMode: mode,
              locale: locale,
              supportedLocales: AppL.supportedLocales,
              localizationsDelegates: const [
                AppL.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (device, supported) {
                if (locale != null) return locale;
                if (device != null) {
                  for (final s in supported) {
                    if (s.languageCode == device.languageCode) return s;
                  }
                }
                return const Locale('ja');
              },
              home: _Gate(
                repo: _repo,
                themeMode: _themeMode,
                locale: _locale,
              ),
            );
          },
        );
      },
    );
  }
}

/// 初回起動時に免責画面を表示するゲート。
class _Gate extends StatefulWidget {
  final HistoryRepository repo;
  final ValueNotifier<ThemeMode> themeMode;
  final ValueNotifier<Locale?> locale;
  const _Gate({
    required this.repo,
    required this.themeMode,
    required this.locale,
  });

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  bool? _accepted;

  @override
  void initState() {
    super.initState();
    widget.repo.isDisclaimerAccepted().then((v) {
      if (mounted) setState(() => _accepted = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_accepted == false) {
      return DisclaimerScreen(
        firstLaunch: true,
        onAccept: () async {
          await widget.repo.setDisclaimerAccepted();
          if (mounted) setState(() => _accepted = true);
        },
      );
    }
    return HomeScreen(
      repo: widget.repo,
      themeMode: widget.themeMode,
      locale: widget.locale,
    );
  }
}
