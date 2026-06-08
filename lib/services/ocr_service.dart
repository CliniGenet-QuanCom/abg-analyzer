// プラットフォームごとに実装を切り替える。
// web（dart.library.io が無い環境）ではスタブを使い、ML Kit / dart:io を
// 取り込まないことで `flutter build web` が壊れないようにする。
export 'ocr_service_web.dart'
    if (dart.library.io) 'ocr_service_io.dart';
