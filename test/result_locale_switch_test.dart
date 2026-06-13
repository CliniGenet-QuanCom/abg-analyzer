import 'package:blood_gas_analyzer/data/history_repository.dart';
import 'package:blood_gas_analyzer/l10n/app_l.dart';
import 'package:blood_gas_analyzer/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 回帰テスト: 解釈結果（評価・解説）が言語切替に追従すること。
///
/// かつては `_analyze()` 実行時のロケールで文字列を事前生成して保持していたため、
/// 言語を切り替えても入力欄ラベルだけが変わり、結果は元の言語のまま残っていた。
/// 結果を build 時に再計算する方式に変更したことで追従するようになった。
void main() {
  testWidgets('解釈結果が言語切替に追従して再描画される', (tester) async {
    // ListView の遅延生成で結果・ボタンが画面外に置かれないよう縦長サーフェスにする。
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final repo = HistoryRepository();
    final locale = ValueNotifier<Locale?>(const Locale('ja'));
    addTearDown(locale.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<Locale?>(
        valueListenable: locale,
        builder: (context, loc, _) => MaterialApp(
          locale: loc,
          supportedLocales: AppL.supportedLocales,
          localizationsDelegates: const [
            AppL.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: HomeScreen(
            repo: repo,
            themeMode: ValueNotifier(ThemeMode.light),
            locale: locale,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 必須グループ先頭3フィールド: pH / PaCO2 / HCO3- に代謝性アシドーシスの値を入力。
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '7.2'); // pH
    await tester.enterText(fields.at(1), '30'); // PaCO2
    await tester.enterText(fields.at(2), '12'); // HCO3-
    await tester.testTextInput.receiveAction(TextInputAction.done);

    // 「解釈する」を実行。
    await tester.tap(find.text('解釈する'));
    await tester.pumpAndSettle();

    // 日本語の評価が表示される。
    expect(find.textContaining('代謝性アシドーシス'), findsWidgets);
    expect(find.textContaining('Metabolic acidosis'), findsNothing);

    // 言語を英語へ切替 → 結果も英語へ追従する（再解釈なし）。
    locale.value = const Locale('en');
    await tester.pumpAndSettle();

    expect(find.textContaining('Metabolic acidosis'), findsWidgets);
    expect(find.textContaining('代謝性アシドーシス'), findsNothing);
  });
}
