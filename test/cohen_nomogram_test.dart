import 'package:blood_gas_analyzer/ui/cohen_nomogram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cohen ノモグラムが例外なく描画される', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 700,
            child: CohenNomogram(
              ph: 7.22,
              hco3: 14,
              classification: '代謝性アシドーシス',
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CohenNomogram), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 言語トグル（日本語）を押しても例外なく再描画される。
    await tester.tap(find.text('日本語'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('極端値・範囲外でも例外なく描画される', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 640,
            child: CohenNomogram(ph: 6.9, hco3: 0, classification: ''),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
