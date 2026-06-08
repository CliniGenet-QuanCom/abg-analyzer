import 'ocr_parser.dart';

/// web / 非対応プラットフォーム用スタブ。
class OcrService {
  /// この環境で OCR が使えるか。
  static bool get isSupported => false;

  Future<OcrExtraction?> capture(CaptureSource source) async {
    throw UnsupportedError('OCR はこのプラットフォームでは利用できません。');
  }

  void dispose() {}
}
