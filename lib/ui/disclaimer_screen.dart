import 'package:flutter/material.dart';

import '../l10n/app_l.dart';

/// 免責事項画面。初回起動時はフルスクリーン、それ以外は閲覧用。
class DisclaimerScreen extends StatelessWidget {
  final bool firstLaunch;
  final VoidCallback? onAccept;

  const DisclaimerScreen({
    super.key,
    this.firstLaunch = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppL.ofContext(context);
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
              Text(l.disclaimerTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          Text(l.disclaimerBody,
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
                label: Text(l.disclaimerAgree),
              ),
            ),
        ],
      ),
    );

    if (firstLaunch) {
      return Scaffold(body: SafeArea(child: body));
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.disclaimerTitle)),
      body: body,
    );
  }
}
