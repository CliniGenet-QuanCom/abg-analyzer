import 'package:blood_gas_analyzer/l10n/app_l.dart';
import 'package:blood_gas_analyzer/ui/cohen_nomogram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Locale locale, Widget child) => MaterialApp(
      locale: locale,
      supportedLocales: AppL.supportedLocales,
      localizationsDelegates: const [
        AppL.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SizedBox(width: 400, height: 700, child: child),
      ),
    );

void main() {
  for (final code in ['ja', 'en', 'zh', 'ko']) {
    testWidgets('Cohen ノモグラムが $code で例外なく描画される', (tester) async {
      await tester.pumpWidget(_wrap(
        Locale(code),
        const CohenNomogram(ph: 7.22, hco3: 14, classification: 'x'),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CohenNomogram), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('極端値・範囲外でも例外なく描画される', (tester) async {
    await tester.pumpWidget(_wrap(
      const Locale('en'),
      const CohenNomogram(ph: 6.9, hco3: 0, classification: ''),
    ));
    expect(tester.takeException(), isNull);
  });
}
