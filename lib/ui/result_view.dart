import 'package:flutter/material.dart';

import '../models/abg_result.dart';
import '../theme/app_theme.dart';

/// 解釈結果（一次診断バナー + Step ごとのセクション + 臨床的示唆）を描画。
class ResultView extends StatelessWidget {
  final AbgResult result;
  const ResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.modeNote != null) _modeNote(context, brightness),
        _primaryBanner(context, brightness),
        const SizedBox(height: 8),
        for (var i = 0; i < result.sections.length; i++)
          _sectionCard(context, brightness, result.sections[i]),
        if (result.clinicalSuggestions.isNotEmpty)
          _suggestionsCard(context, brightness),
      ],
    );
  }

  Widget _modeNote(BuildContext context, Brightness brightness) {
    final color = AppTheme.severityColor(Severity.warning, brightness);
    final bg = AppTheme.severityContainer(Severity.warning, brightness);
    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.bloodtype, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(result.modeNote!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryBanner(BuildContext context, Brightness brightness) {
    final color = AppTheme.severityColor(result.primarySeverity, brightness);
    final bg = AppTheme.severityContainer(result.primarySeverity, brightness);
    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(AppTheme.severityIcon(result.primarySeverity),
                color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('一次診断',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: color)),
                  const SizedBox(height: 2),
                  Text(result.primaryDiagnosis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                              color: color, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
      BuildContext context, Brightness brightness, ResultSection section) {
    final headerColor = AppTheme.severityColor(section.severity, brightness);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppTheme.severityIcon(section.severity),
                    size: 18, color: headerColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(section.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: headerColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final line in section.lines)
              _line(context, brightness, line),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, Brightness brightness, ResultLine line) {
    final color = AppTheme.severityColor(line.severity, brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 8),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Text(line.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: line.severity == Severity.info ? null : color,
                      height: 1.45,
                    )),
          ),
        ],
      ),
    );
  }

  Widget _suggestionsCard(BuildContext context, Brightness brightness) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('臨床的示唆 / 鑑別診断',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            for (final s in result.clinicalSuggestions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 6),
                      child: Icon(Icons.arrow_right, size: 18),
                    ),
                    Expanded(
                        child: Text(s,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.45))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
