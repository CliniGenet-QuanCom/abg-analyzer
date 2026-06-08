import 'package:flutter/material.dart';

import 'data/history_repository.dart';
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
  final ValueNotifier<ThemeMode> _themeMode =
      ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'ABG 解釈',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: _Gate(repo: _repo, themeMode: _themeMode),
        );
      },
    );
  }
}

/// 初回起動時に免責画面を表示するゲート。
class _Gate extends StatefulWidget {
  final HistoryRepository repo;
  final ValueNotifier<ThemeMode> themeMode;
  const _Gate({required this.repo, required this.themeMode});

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
    return HomeScreen(repo: widget.repo, themeMode: widget.themeMode);
  }
}
