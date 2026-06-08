import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/ocr_parser.dart';

/// OCR 抽出結果を確認・手動修正してからフォームに反映するためのダイアログ。
///
/// 返り値: フィールドキー -> 入力テキスト（空文字は未入力）。
/// キャンセル時は null を返す。
class OcrReviewDialog extends StatefulWidget {
  final Map<String, double?> values;
  final String rawText;

  const OcrReviewDialog({
    super.key,
    required this.values,
    required this.rawText,
  });

  @override
  State<OcrReviewDialog> createState() => _OcrReviewDialogState();
}

class _OcrReviewDialogState extends State<OcrReviewDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in AbgOcrParser.fields)
        f.key: TextEditingController(text: _fmt(widget.values[f.key])),
    };
  }

  static String _fmt(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Lac / Hb は本アプリの計算には使わないため参考表示のみ。
  Widget _referenceRow(BuildContext context) {
    final items = <String>[];
    for (final f in AbgOcrParser.referenceFields) {
      final v = widget.values[f.key];
      if (v != null) {
        items.add('${f.label} ${_fmt(v)}${f.unit.isEmpty ? '' : ' ${f.unit}'}');
      }
    }
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '参考（計算には未使用）: ${items.join(' / ')}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final found =
        widget.values.values.where((v) => v != null).length;
    return AlertDialog(
      title: const Text('OCR 結果の確認'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$found / ${AbgOcrParser.fields.length} 項目を自動抽出しました。'
                '誤りがあれば修正してから反映してください。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final f in AbgOcrParser.fields)
                    SizedBox(
                      width: 158,
                      child: TextField(
                        controller: _controllers[f.key],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                        ],
                        decoration: InputDecoration(
                          labelText:
                              '${f.label}${f.unit.isEmpty ? '' : ' (${f.unit})'}',
                          // 抽出できた項目は色付きで識別
                          filled: widget.values[f.key] != null,
                          fillColor: widget.values[f.key] != null
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.4)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              _referenceRow(context),
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('認識した全文を表示',
                    style: Theme.of(context).textTheme.bodyMedium),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      widget.rawText.isEmpty ? '(テキストを認識できませんでした)' : widget.rawText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton.icon(
          onPressed: () {
            final result = <String, String>{
              for (final e in _controllers.entries) e.key: e.value.text.trim(),
            };
            Navigator.pop(context, result);
          },
          icon: const Icon(Icons.input),
          label: const Text('フォームに反映'),
        ),
      ],
    );
  }
}
