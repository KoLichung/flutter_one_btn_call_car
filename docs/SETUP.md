# 快速設定指南

## 步驟 1: 取得 Google Maps API Key

### 1.1 前往 Google Cloud Console
訪問: https://console.cloud.google.com/

### 1.2 建立專案
1. 點擊頂部的專案選擇器
2. 點擊「新增專案」
3. 輸入專案名稱（例如：一鍵叫車）
4. 點擊「建立」

### 1.3 啟用必要的 API
1. 在導航選單中選擇「API 和服務」>「資料庫」
2. 搜尋並啟用以下 API：
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Places API**（可選，未來可能需要）

### 1.4 建立 API 金鑰
1. 在導航選單中選擇「API 和服務」>「憑證」
2. 點擊「建立憑證」>「API 金鑰」
3. 複製生成的 API 金鑰

### 1.5 限制 API 金鑰（建議）
1. 點擊剛建立的 API 金鑰進行編輯
2. 在「應用程式限制」下選擇「Android 應用程式」或「iOS 應用程式」
3. 在「API 限制」下選擇「限制金鑰」並選擇相關的 Maps API

## 步驟 2: 設定專案

### 2.1 Android 設定
編輯檔案：`android/app/src/main/AndroidManifest.xml`

找到這一行：
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

將 `YOUR_GOOGLE_MAPS_API_KEY_HERE` 替換為您的 API 金鑰。

### 2.2 iOS 設定
編輯檔案：`ios/Runner/AppDelegate.swift`

找到這一行：
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```

將 `YOUR_GOOGLE_MAPS_API_KEY_HERE` 替換為您的 API 金鑰。

## 步驟 3: 執行應用程式

### 3.1 安裝依賴
```bash
flutter pub get
```

### 3.2 執行 Android
```bash
flutter run
```
或選擇 Android 模擬器/裝置後在 IDE 中點擊執行。

### 3.3 執行 iOS（僅限 macOS）
```bash
cd ios
pod install
cd ..
flutter run
```
或選擇 iOS 模擬器/裝置後在 IDE 中點擊執行。

## 疑難排解

### 問題：地圖無法顯示
- **原因**：API 金鑰未正確設定或未啟用相應的 API
- **解決方法**：
  1. 檢查 API 金鑰是否正確複製
  2. 確認已啟用 Maps SDK for Android/iOS
  3. 檢查 API 金鑰的限制設定
  4. 查看 Google Cloud Console 的使用情況頁面確認 API 是否被呼叫

### 問題：Android 編譯錯誤
- **原因**：Gradle 或 SDK 版本問題
- **解決方法**：
  ```bash
  cd android
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  ```

### 問題：iOS 編譯錯誤
- **原因**：CocoaPods 依賴問題
- **解決方法**：
  ```bash
  cd ios
  pod deintegrate
  pod install
  cd ..
  flutter clean
  flutter pub get
  ```

### 問題：定位權限未授予
- **Android**：在應用程式執行時會自動請求權限
- **iOS**：在應用程式執行時會自動請求權限，確保 Info.plist 中已設定位置使用說明

## 測試 API Key 是否正常

1. 執行應用程式
2. 登入後應該能看到地圖
3. 如果看到空白或錯誤訊息，請檢查：
   - Android Logcat（Android）
   - Console（iOS）
   查看錯誤訊息

## Google Maps API 免費額度

- Google Maps Platform 提供每月 $200 美元的免費額度
- 對於開發和測試來說通常足夠使用
- 詳情請參考：https://cloud.google.com/maps-platform/pricing

## 完成！

設定完成後，您就可以開始使用一鍵叫車應用程式了！

