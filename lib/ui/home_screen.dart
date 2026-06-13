import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/history_repository.dart';
import '../data/reference_ranges.dart';
import '../l10n/app_l.dart';
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
  final ValueNotifier<Locale?> locale;
  const HomeScreen({
    super.key,
    required this.repo,
    required this.themeMode,
    required this.locale,
  });

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

  /// 現在のロケール [l] で結果を組み立てる。
  /// 言語切替に追従させるため結果は保持せず、表示・共有のたびに再生成する。
  AbgResult? _buildResult(AppL l) {
    final input = _lastInput;
    if (input == null) return null;
    final ranges =
        ReferenceRanges.select(venous: _venous, pediatric: _pediatric);
    return AbgAnalyzer.analyze(input, l: l, ranges: ranges);
  }

  void _analyze() {
    final ph = _parse(_ph);
    final paco2 = _parse(_paco2);
    final hco3 = _parse(_hco3);

    final l = AppL.ofContext(context);
    if (ph == null || paco2 == null || hco3 == null) {
      _snack(l.snackRequired);
      return;
    }
    if (ph < 6.5 || ph > 8.0) {
      _snack(l.snackPhRange);
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
    final result = AbgAnalyzer.analyze(input, l: l, ranges: ranges);

    setState(() {
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
      _lastInput = null;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _copy() async {
    final l = AppL.ofContext(context);
    final result = _buildResult(l);
    if (result == null) return;
    await Clipboard.setData(ClipboardData(text: result.toShareText(l)));
    _snack(l.snackCopied);
  }

  Future<void> _share() async {
    final l = AppL.ofContext(context);
    final result = _buildResult(l);
    if (result == null) return;
    try {
      await SharePlus.instance.share(
        ShareParams(text: result.toShareText(l), subject: l.appTitle),
      );
    } catch (_) {
      await _copy(); // 共有が使えない環境ではコピーにフォールバック
    }
  }

  void _ocrMenu() {
    final l = AppL.ofContext(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(l.ocrCamera),
              onTap: () {
                Navigator.pop(ctx);
                _runOcr(CaptureSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l.ocrGallery),
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
      if (mounted) _snack(AppL.ofContext(context).snackOcrFailed('$e'));
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
    setState(() => _lastInput = null);
    if (mounted) _snack(AppL.ofContext(context).snackOcrApplied(count));
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
      _lastInput = null;
    });
  }

  static String _trim(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL.ofContext(context);
    final result = _buildResult(l);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appBarTitle),
        actions: [
          _languageMenu(l),
          IconButton(
            tooltip: l.toggleTheme,
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final m = widget.themeMode.value;
              widget.themeMode.value = m == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          IconButton(
            tooltip: l.historyMenu,
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
              PopupMenuItem(value: 'disclaimer', child: Text(l.disclaimerMenu)),
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
                  label: Text(l.ocrButton),
                ),
              ),
            ],
            const SizedBox(height: 8),
            _group(l.groupRequired, [
              _field(_ph, l.fieldPh, hint: l.hintEg(_venous ? '7.36' : '7.35')),
              _field(_paco2, _venous ? l.fieldPvco2 : l.fieldPaco2,
                  hint: l.hintEg(_venous ? '46' : '40')),
              _field(_hco3, l.fieldHco3, hint: l.hintEg('24')),
            ]),
            _group(_venous ? l.groupOxygenationVenousNa : l.groupOxygenation, [
              _field(_pao2, _venous ? l.fieldPvo2 : l.fieldPao2,
                  hint: _venous ? l.hintReference : l.hintEg('90')),
              _field(_fio2, l.fieldFio2, hint: l.hintFio2RoomAir),
            ]),
            _group(l.groupElectrolytes, [
              _field(_na, l.fieldNa, hint: l.hintEg('140')),
              _field(_cl, l.fieldCl, hint: l.hintEg('104')),
              _field(_alb, l.fieldAlb, hint: l.hintAlbDefault),
            ]),
            _group(l.groupOther, [
              _field(_be, l.fieldBe, hint: l.hintEg('-2'), negatable: true),
              _field(_temp, l.fieldTemp, hint: l.hintEg('37')),
            ]),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _analyze,
                    icon: const Icon(Icons.calculate),
                    label: Text(l.interpret),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear),
                  label: Text(l.clear),
                ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copy,
                      icon: const Icon(Icons.copy),
                      label: Text(l.copy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share),
                      label: Text(l.share),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ResultView(result: result),
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
                            Text(l.nomoTitle,
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
                          classification: result.primaryDiagnosis,
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
    final l = AppL.ofContext(context);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<bool>(
        segments: [
          ButtonSegment(
              value: false,
              label: Text(l.arterialAbg),
              icon: const Icon(Icons.favorite)),
          ButtonSegment(
              value: true,
              label: Text(l.venousVbg),
              icon: const Icon(Icons.bloodtype)),
        ],
        selected: {_venous},
        onSelectionChanged: (s) => setState(() {
          _venous = s.first;
          _lastInput = null;
        }),
      ),
    );
  }

  Widget _patientTypeSelector() {
    final l = AppL.ofContext(context);
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
            value: false, label: Text(l.adult), icon: const Icon(Icons.person)),
        ButtonSegment(
            value: true,
            label: Text(l.pediatric),
            icon: const Icon(Icons.child_care)),
      ],
      selected: {_pediatric},
      onSelectionChanged: (s) => setState(() => _pediatric = s.first),
    );
  }

  /// 言語切替メニュー（端末設定＋4言語）。選択は永続化する。
  Widget _languageMenu(AppL l) {
    return PopupMenuButton<String>(
      tooltip: l.selectLanguage,
      icon: const Icon(Icons.translate),
      onSelected: (code) async {
        final newLocale = code == 'system' ? null : Locale(code);
        widget.locale.value = newLocale;
        await widget.repo.setLocaleCode(code == 'system' ? null : code);
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'system', child: Text(l.systemDefault)),
        const PopupMenuDivider(),
        for (final loc in AppL.supportedLocales)
          PopupMenuItem(
              value: loc.languageCode,
              child: Text(AppL.of(loc).languageName)),
      ],
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

  /// 入力値の符号（先頭のマイナス）を反転する。
  /// iOS Safari/PWA の数値テンキーには「-」キーが無いため、この ± ボタンで対応する。
  void _toggleSign(TextEditingController c) {
    final t = c.text.trim();
    final String next;
    if (t.startsWith('-')) {
      next = t.substring(1);
    } else if (t.isEmpty) {
      next = '-';
    } else {
      next = '-$t';
    }
    c.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  Widget _field(TextEditingController c, String label,
      {String? hint, bool negatable = false}) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: c,
        // ネイティブ(iOS/Android)アプリでは signed:true でテンキーに「+/-」が出る。
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          // iOS Safari/PWA のテンキーには「-」が無いため、符号反転ボタンを併設。
          suffixIcon: negatable
              ? IconButton(
                  tooltip: AppL.ofContext(context).toggleSign,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Text('±',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () => _toggleSign(c),
                )
              : null,
        ),
      ),
    );
  }
}
