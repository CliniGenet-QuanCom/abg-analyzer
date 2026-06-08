# Google ML Kit text recognition
# プラグインはラテン以外のスクリプト認識オプションクラスも参照するため、
# 同梱していないスクリプトの欠落クラス警告を無視する。
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit / Play services の本体は保持する。
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
