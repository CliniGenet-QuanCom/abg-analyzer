import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/history_repository.dart';
import '../data/reference_ranges.dart';
import '../logic/abg_analyzer.dart';
import '../models/abg_input.dart';
import '../models/abg_result.dart';
import '../services/ocr_parser.dart';
import '../services/ocr_service.dart';
import 'cohen_nomogram.dart';
import 'disclaimer_screen.dart';
import 'history_screen.dart';
import 'ocr_review_dialog.dart';
import 'result_view.dart';

class HomeScreen extends StatefulWidget {
  final HistoryRepository repo;
  final ValueNotifier<ThemeMode> themeMode;
  const HomeScreen({super.key, required this.repo, required this.themeMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ph = TextEditingController();
  final _paco2 = TextEditingController();
  final _hco3 = TextEditingController();
  final _pao2 = TextEditingController();
  final _be = TextEditingController();
  final _fio2 = TextEditingController();
  final _na = TextEditingController();
  final _cl = TextEditingController();
  final _alb = TextEditingController();
  final _temp = TextEditingController();

  bool _pediatric = false;
  bool _venous = false;
  AbgResult? _result;
  AbgInput? _lastInput;

  final OcrService _ocr = OcrService();

  /// OCR フィールドキー → 対応する入力コントローラ。
  Map<String, TextEditingController> get _ctrlByKey => {
        'ph': _ph,
        'paco2': _paco2,
        'pao2': _pao2,
        'hco3': _hco3,
        'be': _be,
        'fio2': _fio2,
        'na': _na,
        'cl': _cl,
      };

  @override
  void dispose() {
    for (final c in [
      _ph,
      _paco2,
      _hco3,
      _pao2,
      _be,
      _fio2,
      _na,
      _cl,
      _alb,
      _temp,
    ]) {
      c.dispose();
    }
    _ocr.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final t = c.text.trim().replaceAll('，', '').replaceAll(',', '');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  void _analyze() {
    final ph = _parse(_ph);
    final paco2 = _parse(_paco2);
    final hco3 = _parse(_hco3);

    if (ph == null || paco2 == null || hco3 == null) {
      _snack('pH・PaCO2・HCO3- は必須です（数値を入力してください）。');
      return;
    }
    if (ph < 6.5 || ph > 8.0) {
      _snack('pH の値が想定範囲外です（6.5–8.0）。入力を確認してください。');
      return;
    }

    final input = AbgInput(
      ph: ph,
      paco2: paco2,
      hco3: hco3,
      pao2: _parse(_pao2),
      be: _parse(_be),
      fio2: _parse(_fio2),
      na: _parse(_na),
      cl: _parse(_cl),
      albumin: _parse(_alb),
      temperature: _parse(_temp),
    );

    final ranges =
        ReferenceRanges.select(venous: _venous, pediatric: _pediatric);
    final result = AbgAnalyzer.analyze(input, ranges: ranges);

    setState(() {
      _result = result;
      _lastInput = input;
    });

    widget.repo.add(HistoryEntry(
      timestamp: DateTime.now(),
      input: input,
      primaryDiagnosis: result.primaryDiagnosis,
      pediatric: _pediatric,
      venous: _venous,
    ));

    FocusScope.of(context).unfocus();
  }

  void _clear() {
    for (final c in [
      _ph,
      _paco2,
      _hco3,
      _pao2,
      _be,
      _fio2,
      _na,
      _cl,
      _alb,
      _temp,
    ]) {
      c.clear();
    }
    setState(() {
      _result = null;
      _lastInput = null;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _copy() async {
    if (_result == null) return;
    await Clipboard.setData(ClipboardData(text: _result!.toShareText()));
    _snack('結果をクリップボードにコピーしました。');
  }

  Future<void> _share() async {
    if (_result == null) return;
    try {
      await SharePlus.instance.share(
        ShareParams(text: _result!.toShareText(), subject: 'ABG 解釈結果'),
      );
    } catch (_) {
      await _copy(); // 共有が使えない環境ではコピーにフォールバック
    }
  }

  void _ocrMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(ctx);
                _runOcr(CaptureSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('画像を選択'),
              onTap: () {
                Navigator.pop(ctx);
                _runOcr(CaptureSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runOcr(CaptureSource source) async {
    OcrExtraction? extraction;
    // 処理中インジケータ
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      extraction = await _ocr.capture(source);
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).maybePop();
      _snack('OCR に失敗しました: $e');
      return;
    }
    if (mounted) Navigator.of(context, rootNavigator: true).maybePop();
    if (extraction == null) return; // 撮影キャンセル
    if (!mounted) return;

    final applied = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => OcrReviewDialog(
        values: extraction!.values,
        rawText: extraction.rawText,
      ),
    );
    if (applied == null) return;

    final ctrls = _ctrlByKey;
    var count = 0;
    applied.forEach((key, value) {
      final c = ctrls[key];
      if (c != null && value.trim().isNotEmpty) {
        c.text = value.trim();
        count++;
      }
    });
    setState(() => _result = null);
    _snack('$count 項目をフォームに反映しました。値を確認してください。');
  }

  void _loadFromHistory(AbgInput input, bool pediatric, bool venous) {
    void set(TextEditingController c, double? v) =>
        c.text = v == null ? '' : _trim(v);
    set(_ph, input.ph);
    set(_paco2, input.paco2);
    set(_hco3, input.hco3);
    set(_pao2, input.pao2);
    set(_be, input.be);
    set(_fio2, input.fio2);
    set(_na, input.na);
    set(_cl, input.cl);
    set(_alb, input.albumin);
    set(_temp, input.temperature);
    setState(() {
      _pediatric = pediatric;
      _venous = venous;
      _result = null;
    });
  }

  static String _trim(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABG/VBG判定'),
        actions: [
          IconButton(
            tooltip: 'テーマ切替',
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final m = widget.themeMode.value;
              widget.themeMode.value = m == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          IconButton(
            tooltip: '履歴',
            icon: const Icon(Icons.history),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HistoryScreen(
                  repo: widget.repo,
                  onSelect: _loadFromHistory,
                ),
              ));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'disclaimer') {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const DisclaimerScreen(),
                ));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'disclaimer', child: Text('免責事項')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          children: [
            _sampleTypeSelector(),
            const SizedBox(height: 8),
            _patientTypeSelector(),
            if (OcrService.isSupported) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _ocrMenu,
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('結果用紙を撮影して自動入力 (OCR)'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            _group('必須項目', [
              _field(_ph, 'pH', hint: _venous ? '例: 7.36' : '例: 7.35',
                  signed: false),
              _field(_paco2, '${_venous ? 'PvCO2' : 'PaCO2'} (mmHg)',
                  hint: _venous ? '例: 46' : '例: 40'),
              _field(_hco3, 'HCO3- (mEq/L)', hint: '例: 24'),
            ]),
            _group(_venous ? '酸素化（静脈血では非適用）' : '酸素化', [
              _field(_pao2, '${_venous ? 'PvO2' : 'PaO2'} (mmHg)',
                  hint: _venous ? '参考値' : '例: 90'),
              _field(_fio2, 'FiO2 (%)', hint: '室内気=21'),
            ]),
            _group('電解質（AG 計算用）', [
              _field(_na, 'Na (mEq/L)', hint: '例: 140'),
              _field(_cl, 'Cl (mEq/L)', hint: '例: 104'),
              _field(_alb, 'Alb (g/dL) 任意', hint: '既定 4.0'),
            ]),
            _group('その他（任意）', [
              _field(_be, 'BE (mEq/L)', hint: '例: -2', signed: true),
              _field(_temp, '体温 (℃)', hint: '例: 37'),
            ]),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _analyze,
                    icon: const Icon(Icons.calculate),
                    label: const Text('解釈する'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear),
                  label: const Text('クリア'),
                ),
              ],
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copy,
                      icon: const Icon(Icons.copy),
                      label: const Text('コピー'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share),
                      label: const Text('共有'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ResultView(result: _result!),
              if (_lastInput != null) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.show_chart,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('酸塩基平衡ノモグラム (Cohen)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CohenNomogram(
                          ph: _lastInput!.ph,
                          hco3: _lastInput!.hco3,
                          classification: _result!.primaryDiagnosis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _sampleTypeSelector() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
              value: false,
              label: Text('動脈血 (ABG)'),
              icon: Icon(Icons.favorite)),
          ButtonSegment(
              value: true,
              label: Text('静脈血 (VBG)'),
              icon: Icon(Icons.bloodtype)),
        ],
        selected: {_venous},
        onSelectionChanged: (s) => setState(() {
          _venous = s.first;
          _result = null;
        }),
      ),
    );
  }

  Widget _patientTypeSelector() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('成人'), icon: Icon(Icons.person)),
        ButtonSegment(
            value: true, label: Text('小児'), icon: Icon(Icons.child_care)),
      ],
      selected: {_pediatric},
      onSelectionChanged: (s) => setState(() => _pediatric = s.first),
    );
  }

  Widget _group(String title, List<Widget> fields) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: fields,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {String? hint, bool signed = false}) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: c,
        keyboardType:
            TextInputType.numberWithOptions(decimal: true, signed: signed),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }
}
