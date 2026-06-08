import 'dart:io' show Platform;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'ocr_parser.dart';

/// モバイル(Android/iOS)用の OCR 実装。
/// image_picker で撮影/選択 → ML Kit でテキスト認識 → 値を抽出する。
class OcrService {
  final ImagePicker _picker = ImagePicker();

  /// この環境で OCR が使えるか（ML Kit は Android/iOS のみ）。
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  Future<OcrExtraction?> capture(CaptureSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source == CaptureSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 100,
    );
    if (file == null) return null; // キャンセル

    final inputImage = InputImage.fromFilePath(file.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(inputImage);

      // TextLine ごとに boundingBox 付き要素を作る（座標ベース行マッチング用）。
      final elements = <OcrElement>[];
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final r = line.boundingBox;
          elements.add(OcrElement(
            text: line.text,
            left: r.left,
            top: r.top,
            right: r.right,
            bottom: r.bottom,
          ));
        }
      }

      final values = AbgOcrParser.extractFromElements(elements);
      // 取りこぼしはプレーンテキスト解析で補完。
      final flat = AbgOcrParser.extract(result.text);
      for (final k in [...values.keys]) {
        values[k] ??= flat[k];
      }
      return OcrExtraction(values: values, rawText: result.text);
    } finally {
      await recognizer.close();
    }
  }

  void dispose() {}
}
