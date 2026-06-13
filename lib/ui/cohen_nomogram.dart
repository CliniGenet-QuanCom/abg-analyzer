import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_l.dart';
import '../theme/app_theme.dart';

/// 酸塩基平衡ノモグラム（Cohen 図）。
///
/// X 軸: 動脈血 pH(7.0–7.8) と上軸の [H+](nmol/L)。Y 軸: HCO3-(0–60)。
/// 8 つの障害に対応する 95% 信頼帯を CustomPainter で塗りつぶし、PCO2 等圧線を
/// 破線で重ね、患者値を赤点でプロットする。InteractiveViewer でピンチズーム可能。
class CohenNomogram extends StatefulWidget {
  final double ph;
  final double hco3;

  /// 判定結果（タップ時のポップアップに表示）。
  final String classification;

  const CohenNomogram({
    super.key,
    required this.ph,
    required this.hco3,
    this.classification = '',
  });

  @override
  State<CohenNomogram> createState() => _CohenNomogramState();
}

class _CohenNomogramState extends State<CohenNomogram> {
  void _showInfo(BuildContext context) {
    final l = AppL.ofContext(context);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.nomoPlottedPoint),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('pH: ${widget.ph.toStringAsFixed(2)}'),
            Text('HCO3-: ${widget.hco3.toStringAsFixed(1)} mmol/L'),
            Text('${l.nomoPaco2CalcPrefix}'
                '${_pco2From(widget.ph, widget.hco3).toStringAsFixed(1)} mmHg'),
            const SizedBox(height: 8),
            if (widget.classification.isNotEmpty)
              Text(
                '${l.nomoAssessmentPrefix}${widget.classification}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  static double _pco2From(double ph, double hco3) =>
      hco3 / (0.03 * math.pow(10, ph - 6.1));

  Widget _chart(BuildContext context, {required bool fullScreen}) {
    final l = AppL.ofContext(context);
    final fontFamily =
        AppTheme.fontFamilyFor(Localizations.localeOf(context).languageCode);
    return LayoutBuilder(builder: (context, constraints) {
      final side = math.min(constraints.maxWidth,
          fullScreen ? constraints.maxHeight : constraints.maxWidth);
      return Center(
        child: SizedBox(
          width: side,
          height: side,
          child: InteractiveViewer(
            maxScale: 6,
            minScale: 1,
            boundaryMargin: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => _showInfo(context),
              child: CustomPaint(
                size: Size(side, side),
                painter: _CohenPainter(
                  ph: widget.ph,
                  hco3: widget.hco3,
                  l: l,
                  fontFamily: fontFamily,
                  brightness: Theme.of(context).brightness,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _openFullScreen() {
    final l = AppL.ofContext(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(l.nomoTitle)),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: _chart(context, fullScreen: true),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL.ofContext(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: l.nomoFullScreen,
              icon: const Icon(Icons.fullscreen),
              onPressed: _openFullScreen,
            ),
          ],
        ),
        AspectRatio(
          aspectRatio: 1,
          child: _chart(context, fullScreen: false),
        ),
        Text(
          l.nomoTapHint,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _RegionLabel {
  final String text;
  final double ph;
  final double hco3;
  final Color color;
  final bool italic;
  final double fontSize;

  /// maxWidth をプロット幅に対する割合で指定（帯域幅の約 80% を目安）。
  final double widthFactor;

  /// プロット枠内に座標をクランプするか（混合域ラベル用）。
  final bool clamp;

  const _RegionLabel(this.text, this.ph, this.hco3, this.color,
      {this.italic = false,
      this.fontSize = 10,
      this.widthFactor = 0.24,
      this.clamp = false});
}

class _CohenPainter extends CustomPainter {
  final double ph;
  final double hco3;
  final AppL l;
  final String? fontFamily;
  final Brightness brightness;

  _CohenPainter({
    required this.ph,
    required this.hco3,
    required this.l,
    required this.fontFamily,
    required this.brightness,
  });

  static const double minPh = 7.0;
  static const double maxPh = 7.8;
  static const double minHco3 = 0;
  static const double maxHco3 = 60;

  // 余白
  static const double mLeft = 44;
  static const double mRight = 44;
  static const double mTop = 60;
  static const double mBottom = 34;

  late Rect _plot;

  double _x(double ph) =>
      _plot.left + (ph - minPh) / (maxPh - minPh) * _plot.width;
  double _y(double hco3) =>
      _plot.bottom - (hco3 - minHco3) / (maxHco3 - minHco3) * _plot.height;
  Offset _p(double ph, double h) => Offset(_x(ph), _y(h));

  static double _log10(double x) => math.log(x) / math.ln10;
  static double _phFrom(double hco3, double pco2) =>
      6.1 + _log10(hco3 / (0.03 * pco2));
  static double _hco3From(double ph, double pco2) =>
      0.03 * pco2 * math.pow(10, ph - 6.1);

  @override
  void paint(Canvas canvas, Size size) {
    _plot = Rect.fromLTRB(
        mLeft, mTop, size.width - mRight, size.height - mBottom);

    final isDark = brightness == Brightness.dark;
    final ink = isDark ? Colors.white70 : Colors.black87;

    // 背景
    canvas.drawRect(Offset.zero & size,
        Paint()..color = isDark ? const Color(0xFF1A1C1E) : Colors.white);

    canvas.save();
    canvas.clipRect(_plot);
    _drawBands(canvas);
    _drawIsobars(canvas, ink);
    _drawNormal(canvas);
    _drawPatient(canvas);
    canvas.restore();

    _drawAxes(canvas, size, ink);
    _drawLabels(canvas);
    _drawIsobarLabels(canvas, ink);
  }

  // ---- 信頼帯 ----
  void _fillPoly(Canvas canvas, List<Offset> dataPts, Color color) {
    if (dataPts.isEmpty) return;
    final path = Path()..moveTo(_x(dataPts.first.dx), _y(dataPts.first.dy));
    for (final o in dataPts.skip(1)) {
      path.lineTo(_x(o.dx), _y(o.dy));
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  /// 呼吸性: PCO2 をパラメータに中心線 ± 幅で帯を作る。
  List<Offset> _respBand(double pcoLo, double pcoHi,
      double Function(double) center, double Function(double) halfW) {
    final up = <Offset>[];
    final lo = <Offset>[];
    const n = 24;
    for (var i = 0; i <= n; i++) {
      final pco = pcoLo + (pcoHi - pcoLo) * i / n;
      final c = center(pco);
      final hw = halfW(pco);
      final hu = c + hw, hl = c - hw;
      up.add(Offset(_phFrom(hu, pco), hu));
      lo.add(Offset(_phFrom(hl, pco), hl));
    }
    return [...up, ...lo.reversed];
  }

  /// 代謝性: HCO3 をパラメータに、期待 PCO2 ± 幅で帯を作る。
  List<Offset> _metBand(double hLo, double hHi,
      double Function(double) centerPco, double halfWpco) {
    final left = <Offset>[];
    final right = <Offset>[];
    const n = 24;
    for (var i = 0; i <= n; i++) {
      final h = hLo + (hHi - hLo) * i / n;
      final pc = centerPco(h);
      left.add(Offset(_phFrom(h, pc - halfWpco), h));
      right.add(Offset(_phFrom(h, pc + halfWpco), h));
    }
    return [...left, ...right.reversed];
  }

  void _drawBands(Canvas canvas) {
    // 代謝性アシドーシス（赤）
    _fillPoly(canvas, _metBand(3, 21, (h) => 1.5 * h + 8, 2.5),
        const Color(0x4DE53935));
    // 代謝性アルカローシス（青）
    _fillPoly(canvas, _metBand(27, 53, (h) => 0.7 * h + 21, 3.5),
        const Color(0x4D1E88E5));
    // 急性呼吸性アシドーシス（オレンジ）
    _fillPoly(
        canvas,
        _respBand(41, 90, (p) => 24 + (p - 40) / 10,
            (p) => 1.4 + 0.04 * (p - 40)),
        const Color(0x4DFB8C00));
    // 慢性呼吸性アシドーシス（黄）
    _fillPoly(
        canvas,
        _respBand(41, 95, (p) => 24 + 3.5 * (p - 40) / 10,
            (p) => 1.6 + 0.06 * (p - 40)),
        const Color(0x4DFDD835));
    // 急性呼吸性アルカローシス（水色）
    _fillPoly(
        canvas,
        _respBand(15, 39, (p) => 24 - 2 * (40 - p) / 10,
            (p) => 1.2 + 0.045 * (40 - p)),
        const Color(0x4D4DD0E1));
    // 慢性呼吸性アルカローシス（緑）
    _fillPoly(
        canvas,
        _respBand(12, 39, (p) => 24 - 5 * (40 - p) / 10,
            (p) => 1.2 + 0.06 * (40 - p)),
        const Color(0x4D43A047));
  }

  void _drawNormal(Canvas canvas) {
    final c = _p(7.40, 24);
    final rx = (0.035 / (maxPh - minPh)) * _plot.width;
    final ry = (4.0 / (maxHco3 - minHco3)) * _plot.height;
    final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
        rect,
        Paint()
          ..color = (brightness == Brightness.dark
              ? const Color(0xFF1A1C1E)
              : Colors.white));
    canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.black54);
  }

  void _drawPatient(Canvas canvas) {
    final c = _p(ph.clamp(minPh, maxPh), hco3.clamp(minHco3, maxHco3));
    // 視認性向上のため、白い輪郭を先に描いてから赤●を重ねる。
    canvas.drawCircle(
        c,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white);
    canvas.drawCircle(c, 8, Paint()..color = Colors.white);
    canvas.drawCircle(c, 6, Paint()..color = Colors.red);
  }

  // ---- PCO2 等圧線 ----
  void _drawIsobars(Canvas canvas, Color ink) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (final pco in const [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]) {
      final pts = <Offset>[];
      for (double p = minPh; p <= maxPh + 1e-9; p += 0.01) {
        final h = _hco3From(p, pco.toDouble());
        if (h >= minHco3 && h <= maxHco3) pts.add(_p(p, h));
      }
      _dashedPolyline(canvas, pts, paint);
    }
  }

  void _dashedPolyline(Canvas canvas, List<Offset> pts, Paint paint,
      {double dash = 6, double gap = 4}) {
    if (pts.length < 2) return;
    var draw = true;
    var remaining = dash;
    for (var i = 0; i < pts.length - 1; i++) {
      var a = pts[i];
      final b = pts[i + 1];
      var segLen = (b - a).distance;
      final dir = segLen == 0 ? Offset.zero : (b - a) / segLen;
      while (segLen > 0) {
        final step = math.min(remaining, segLen);
        final next = a + dir * step;
        if (draw) canvas.drawLine(a, next, paint);
        a = next;
        segLen -= step;
        remaining -= step;
        if (remaining <= 0) {
          draw = !draw;
          remaining = draw ? dash : gap;
        }
      }
    }
  }

  void _drawIsobarLabels(Canvas canvas, Color ink) {
    for (final pco in const [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]) {
      final hAtRight = _hco3From(maxPh, pco.toDouble());
      if (hAtRight <= maxHco3) {
        // 右端(pH=7.8)で交わる等圧線は右端にラベル。
        _text(canvas, '$pco', Offset(_x(maxPh) + 2, _y(hAtRight) - 5),
            color: ink, size: 8, anchorLeft: true);
      } else {
        // 上端で交わる等圧線(40–100)は、上軸 [H+] の数字と重ならないよう
        // プロット枠より上方に離して配置する。
        final phAtTop = _phFrom(maxHco3, pco.toDouble());
        _text(canvas, '$pco', Offset(_x(phAtTop), _plot.top - 27),
            color: ink, size: 8, center: true);
      }
    }
  }

  // ---- 軸 ----
  void _drawAxes(Canvas canvas, Size size, Color ink) {
    final axis = Paint()
      ..color = ink
      ..strokeWidth = 1;
    final grid = Paint()
      ..color = ink.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    canvas.drawRect(_plot,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = ink
          ..strokeWidth = 1);

    // 下軸: pH
    for (var i = 0; i <= 8; i++) {
      final ph = 7.0 + i * 0.1;
      final x = _x(ph);
      canvas.drawLine(Offset(x, _plot.top), Offset(x, _plot.bottom), grid);
      canvas.drawLine(
          Offset(x, _plot.bottom), Offset(x, _plot.bottom + 4), axis);
      _text(canvas, ph.toStringAsFixed(1), Offset(x, _plot.bottom + 6),
          color: ink, size: 9, center: true);
    }
    _text(canvas, l.axisPh, Offset(_plot.center.dx, size.height - 11),
        color: ink, size: 9, center: true);

    // 左軸: HCO3
    for (var h = 0; h <= 60; h += 4) {
      final y = _y(h.toDouble());
      canvas.drawLine(Offset(_plot.left, y), Offset(_plot.right, y), grid);
      canvas.drawLine(Offset(_plot.left - 4, y), Offset(_plot.left, y), axis);
      _text(canvas, '$h', Offset(_plot.left - 6, y),
          color: ink, size: 9, anchorRight: true, middle: true);
    }
    _textRotated(canvas, l.axisHco3, Offset(10, _plot.center.dy),
        color: ink, size: 9, angle: -math.pi / 2);

    // 上軸: [H+] nmol/L（20–100 のみ）。
    // [H+] = 10^(9-pH) nmol/L → 逆算 pH = 9 - log10([H+]) で座標変換。
    // ラベルが重ならないよう最小間隔 20px を確保し、収まらない分は間引く。
    final hEntries = <MapEntry<int, double>>[];
    for (final h in const [20, 30, 40, 50, 60, 70, 80, 90, 100]) {
      final ph = 9 - _log10(h.toDouble());
      if (ph < minPh || ph > maxPh) continue;
      hEntries.add(MapEntry(h, _x(ph)));
    }
    hEntries.sort((a, b) => a.value.compareTo(b.value));
    double? lastX;
    for (final e in hEntries) {
      if (lastX != null && (e.value - lastX).abs() < 20) continue;
      lastX = e.value;
      canvas.drawLine(
          Offset(e.value, _plot.top), Offset(e.value, _plot.top - 4), axis);
      _text(canvas, '${e.key}', Offset(e.value, _plot.top - 13),
          color: ink, size: 9, center: true);
    }
    _text(canvas, l.axisHplus, Offset(_plot.center.dx, 4),
        color: ink, size: 9, center: true);

    // 右軸タイトル: pCO2
    _textRotated(canvas, l.axisPco2, Offset(size.width - 8, _plot.center.dy),
        color: ink, size: 9, angle: math.pi / 2);
  }

  // ---- 帯域・混合のラベル（座標・スタイルは固定、文言は l から取得） ----
  // 主要障害名（10pt・回転なし・各色領域の中央）。
  List<_RegionLabel> _mainLabels() => [
        _RegionLabel(l.rMetAcid, 7.17, 8, Colors.black87, widthFactor: 0.24),
        _RegionLabel(l.rMetAlk, 7.50, 42, Colors.black87, widthFactor: 0.26),
        _RegionLabel(l.rAcuteRespAcid, 7.225, 28, Colors.black87,
            widthFactor: 0.26),
        _RegionLabel(l.rChronicRespAcid, 7.30, 38, Colors.black87,
            widthFactor: 0.26),
        _RegionLabel(l.rAcuteRespAlk, 7.53, 20, Colors.black87,
            widthFactor: 0.24),
        _RegionLabel(l.rChronicRespAlk, 7.47, 14, Colors.black87,
            widthFactor: 0.26),
      ];

  // 混合・代償不全（8pt・赤・斜体・回転なし、各混合域の中心、枠内クランプ）。
  List<_RegionLabel> _mixedLabels() => [
        _RegionLabel(l.mMixedRespAcidMetAlk, 7.33, 52, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.20, clamp: true),
        _RegionLabel(l.mMetAlkNoComp, 7.62, 52, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.20, clamp: true),
        _RegionLabel(l.mMixedRespMetAlk, 7.60, 33, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.20, clamp: true),
        _RegionLabel(l.mAcuteOnChronicRespAlk, 7.64, 10, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.18, clamp: true),
        _RegionLabel(l.mMixedMetAcidRespAlk, 7.42, 5, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.20, clamp: true),
        _RegionLabel(l.mMixedRespMetAcid, 7.13, 21, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.18, clamp: true),
        _RegionLabel(l.mMetAcidNoComp, 7.09, 9, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.18, clamp: true),
        _RegionLabel(l.mAcuteOnChronicRespAcid, 7.17, 34, Colors.red,
            italic: true, fontSize: 8, widthFactor: 0.18, clamp: true),
      ];

  Offset _labelPos(_RegionLabel label) {
    var pos = _p(label.ph, label.hco3);
    if (label.clamp) {
      pos = Offset(
        pos.dx.clamp(_plot.left + 4, _plot.right - 4),
        pos.dy.clamp(_plot.top + 4, _plot.bottom - 4),
      );
    }
    return pos;
  }

  void _drawLabel(Canvas canvas, _RegionLabel label) {
    final pos = _labelPos(label);
    _text(canvas, label.text, pos,
        color: label.color,
        size: label.fontSize,
        center: true,
        middle: true,
        italic: label.italic,
        maxWidth: label.widthFactor * _plot.width);
  }

  void _drawLabels(Canvas canvas) {
    for (final label in _mixedLabels()) {
      _drawLabel(canvas, label);
    }
    for (final label in _mainLabels()) {
      _drawLabel(canvas, label);
    }
    _drawNormalLabel(canvas);
  }

  /// 「Normal」は正常域（中央）に水平表示。
  void _drawNormalLabel(Canvas canvas) {
    final pos = _p(7.40, 24);
    _text(canvas, l.rNormal, pos,
        color: Colors.black87, size: 10, center: true, middle: true);
  }

  // ---- テキスト描画ヘルパ ----
  void _text(Canvas canvas, String s, Offset at,
      {required Color color,
      double size = 9,
      bool center = false,
      bool middle = false,
      bool anchorRight = false,
      bool anchorLeft = false,
      bool italic = false,
      double? maxWidth}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: color,
              fontSize: size,
              height: 1.05,
              fontFamily: fontFamily,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? double.infinity);
    var dx = at.dx;
    var dy = at.dy;
    if (center) dx -= tp.width / 2;
    if (middle) dy -= tp.height / 2;
    if (anchorRight) dx -= tp.width;
    if (anchorRight && !middle) dy -= tp.height / 2;
    if (anchorLeft && !middle) dy -= tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _textRotated(Canvas canvas, String s, Offset at,
      {required Color color, double size = 9, required double angle}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style:
              TextStyle(color: color, fontSize: size, fontFamily: fontFamily)),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CohenPainter old) =>
      old.ph != ph ||
      old.hco3 != hco3 ||
      old.l.runtimeType != l.runtimeType ||
      old.fontFamily != fontFamily ||
      old.brightness != brightness;
}
