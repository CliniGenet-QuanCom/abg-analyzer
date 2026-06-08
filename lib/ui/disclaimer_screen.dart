import 'package:flutter/material.dart';

/// 免責事項画面。初回起動時はフルスクリーン、それ以外は閲覧用。
class DisclaimerScreen extends StatelessWidget {
  final bool firstLaunch;
  final VoidCallback? onAccept;

  const DisclaimerScreen({
    super.key,
    this.firstLaunch = false,
    this.onAccept,
  });

  static const String disclaimerText = '''
本アプリは動脈血液ガス（ABG）の解釈を学習・確認するための補助ツールです。

• 本アプリの計算・解釈結果は一般的なアルゴリズムに基づく参考情報であり、診断・治療を目的とした医療機器ではありません。
• 代償式や基準値は主に成人を対象とした標準値を用いています。小児・新生児・妊娠中などでは適用が異なる場合があります。
• 入力値の誤りや特殊な病態では結果が不正確になることがあります。
• 最終的な臨床判断は、患者の全体像を踏まえて必ず資格のある医療者が行ってください。
• 本アプリの利用により生じたいかなる損害についても、開発者は責任を負いません。

すべての患者データは端末内にのみ保存され、外部送信は行いません。
''';

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety,
                  color: Theme.of(context).colorScheme.primary, size: 32),
              const SizedBox(width: 12),
              Text('免責事項',
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          Text(disclaimerText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  )),
          const SizedBox(height: 24),
          if (firstLaunch)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check),
                label: const Text('同意して開始する'),
              ),
            ),
        ],
      ),
    );

    if (firstLaunch) {
      return Scaffold(body: SafeArea(child: body));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('免責事項')),
      body: body,
    );
  }
}
