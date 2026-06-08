# ABG 解釈アプリ (abg_analyzer)

動脈血液ガス（ABG: Arterial Blood Gas）の結果解釈を支援する Flutter 製アプリ。
**完全ローカル動作**（サーバー不要・外部送信なし）。Android / iOS / Web 対応。

> ⚠️ 本アプリは学習・確認用の補助ツールであり、医療機器ではありません。
> 最終的な臨床判断は必ず資格のある医療者が行ってください。

## 機能

- **入力**: pH / PaCO2 / PaO2 / HCO3- / BE / FiO2 / Na / Cl / Alb / 体温
- **動脈血(ABG) / 静脈血(VBG) モード切替**（画面上部トグル）
  - VBG 正常値: pH 7.31–7.41 / PvCO2 41–51 / HCO3- 22–26 に切替
  - 代償式は動脈血ロジックを流用、酸素化評価(P/F・A-aDO2)は VBG では非適用
  - 結果に「静脈血（VBG）モード」注記を表示
- **解釈ロジック (Step 1〜6)**
  - Step 1: 一次性異常（アシデミア/アルカレミア、PaCO2・HCO3- の正常判定）
  - Step 2: 原発性障害の分類（呼吸性/代謝性 × アシドーシス/アルカローシス）
  - Step 3: 代償の評価（Winters 式、代謝性アルカローシス、急性/慢性呼吸性、混合性警告）
  - Step 4: アニオンギャップ（AG = Na −(Cl + HCO3-)、アルブミン補正）
  - Step 5: デルタ比（Δ/Δ）による合併病態の検出
  - Step 6: 酸素化評価（P/F 比・ARDS 分類・A-aDO2）
  - 参考: 体温補正
- **Davenport ダイアグラム**（fl_chart）: pH(7.0–7.8) × HCO3-(0–50) のノモグラム。
  正常点(7.4/24)基準で 4 障害領域を色帯表示、PCO2 等圧線(20/40/60/80)を重畳、患者値をプロット
- **カメラ OCR 自動入力**（Google ML Kit Text Recognition v2 / Android・iOS のみ）:
  結果用紙を撮影 or 画像選択 → pH・PaCO2・PaO2・HCO3-・BE・FiO2・Na・Cl を自動抽出
  （Lac・Hb は参考表示）。誤認識に備え、反映前に確認・手動修正できるレビュー画面を表示。
  - **座標（boundingBox）ベースの行マッチング**: TextLine の Y 座標で同一行を判定し、
    行内のラベルに対応する数値（X が右側）を抽出。モニターの 2 列レイアウト／i-STAT 感熱紙／
    ABL90 感熱紙の 3 形式に対応。各項目は妥当値レンジで検証し誤検出を抑制。
- **UI/UX**: Material 3 / テンキー最適化入力 / 段階表示 / 色分け（アシドーシス赤・アルカローシス青・正常緑・警告橙）/ ダークモード / 成人・小児の基準値切替
- **その他**: 結果のコピー・共有、SharedPreferences による入力履歴、初回起動時の免責画面

## プロジェクト構成

```
lib/
  main.dart                 アプリ起動・テーマ・免責ゲート
  models/                   AbgInput / AbgResult
  logic/abg_analyzer.dart   解釈エンジン（Step 1〜6）
  data/                     履歴保存(SharedPreferences) / 基準値
  services/                 OCR（ocr_parser=純粋解析 / ocr_service=条件付き実装）
  theme/app_theme.dart      Material 3 テーマ・色分け
  ui/                       入力フォーム・結果表示・履歴・免責画面・OCRレビュー
test/abg_analyzer_test.dart 解釈ロジックのユニットテスト（12 件）
```

## 開発・実行

このマシンには Flutter SDK が `C:\flutter`（PATH 登録済み）にあります。
新しいターミナルで `flutter` コマンドが使えます。

```powershell
cd "C:\Users\yseki\Documents\Google Drive\abg_analyzer(claude)"
flutter pub get
flutter test            # ユニットテスト
flutter analyze         # 静的解析
flutter run -d chrome   # Web で確認
```

## Android APK のビルド

1. **Android Studio をインストール**（https://developer.android.com/studio）。
   初回起動のセットアップウィザードで Android SDK・platform-tools・JDK が導入されます。
2. インストール後、ライセンスに同意:
   ```powershell
   flutter doctor --android-licenses
   flutter doctor          # [√] Android toolchain になることを確認
   ```
3. ビルド:
   ```powershell
   flutter build apk --debug      # デバッグ APK
   flutter build apk --release    # リリース APK
   ```
   出力: `build\app\outputs\flutter-apk\app-release.apk`
4. 実機確認: USB デバッグを有効にした端末を接続し `flutter run`。

> ⚠️ **Google Drive 同期フォルダでのビルドに関する注意**
> このプロジェクトは Google Drive 配下にあり、GoogleDriveFS がビルド中間ファイルを
> ロックして `AccessDeniedException`（`mergeReleaseNativeLibs` 等）が発生します。
> APK ビルドは **同期されないローカルフォルダにコピーして実行**してください。
> ```powershell
> robocopy "C:\Users\yseki\Documents\Google Drive\abg_analyzer(claude)" `
>   "C:\dev\abg_analyzer" /MIR /XD build .dart_tool .gradle .git
> cd C:\dev\abg_analyzer
> flutter pub get
> flutter build apk --release
> ```
> 生成済み APK（成人/小児・全機能入り、約 47MB・デバッグ署名）:
> `abg_analyzer-release.apk`（プロジェクト直下）/ デスクトップ `abg_analyzer.apk`

## 注意事項

- 代償式・基準値は主に **成人** の標準値（PaCO2 基準 40・HCO3- 基準 24・AG 基準 12）。
  小児モードはハイライト用の正常範囲を切り替えますが、代償式は成人検証値です。
- A-aDO2 は海面（大気圧 760・PH2O 47）・呼吸商 R=0.8 を仮定。
- OCR（カメラ自動入力）は Google ML Kit を用いるため **Android / iOS のみ**。Web/デスクトップでは
  ボタン非表示（条件付き export でビルドも安全）。ML Kit モデル同梱で APK は約 78MB。
- ML Kit はラテン以外のスクリプト認識クラスを参照するため、release ビルドの R8 で欠落クラス警告が出る。
  `android/app/proguard-rules.pro` に `-dontwarn com.google.mlkit.vision.text.{chinese,devanagari,japanese,korean}.**`
  を追加し、`build.gradle.kts` の release で `proguardFiles` を指定済み。
- OCR の数値抽出は結果用紙の書式に依存します。必ずレビュー画面で確認・修正してください。
- 日本語フォント **Noto Sans JP**（可変フォント）を `assets/fonts/` に**バンドル**し、
  `app_theme.dart` で `fontFamily: 'NotoSansJP'` をアプリ全体に適用。漢字が中国語グリフに
  フォールバックするのを防ぎ、ネット接続不要（完全オフライン）で日本語表示される。
