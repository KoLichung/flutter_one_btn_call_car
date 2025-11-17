# Google Maps API Key 設定說明

## 重要提醒
⚠️ **絕對不要**將 API Key 直接提交到 Git 版本控制系統中！

## 設定步驟

### 1. 取得 Google Maps API Key
1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 建立新專案或選擇現有專案
3. 啟用以下 API：
   - Maps SDK for Android
   - Maps SDK for iOS
4. 建立 API 金鑰並設定適當的限制

### 2. Android 設定

複製範例檔案並填入您的 API Key：

```bash
cd android
cp google_maps_api.properties.example google_maps_api.properties
```

編輯 `android/google_maps_api.properties`，將 `YOUR_GOOGLE_MAPS_API_KEY_HERE` 替換為您的實際 API Key：

```properties
GOOGLE_MAPS_API_KEY=您的_API_KEY
```

### 3. iOS 設定

複製範例檔案並填入您的 API Key：

```bash
cd ios/Flutter
cp Secrets.xcconfig.example Secrets.xcconfig
```

編輯 `ios/Flutter/Secrets.xcconfig`，將 `YOUR_GOOGLE_MAPS_API_KEY_HERE` 替換為您的實際 API Key：

```
GOOGLE_MAPS_API_KEY=您的_API_KEY
```

### 4. 驗證設定

執行專案以確認設定正確：

```bash
# Android
flutter run

# iOS
flutter run
```

如果地圖無法正常顯示，請檢查：
1. API Key 是否正確
2. 是否已在 Google Cloud Console 啟用相應的 API
3. API Key 的限制設定是否正確

## 檔案說明

### 不應提交到 Git 的檔案（已加入 .gitignore）
- `android/google_maps_api.properties` - 包含實際的 API Key
- `ios/Flutter/Secrets.xcconfig` - 包含實際的 API Key

### 應該提交到 Git 的檔案
- `android/google_maps_api.properties.example` - 範例檔案
- `ios/Flutter/Secrets.xcconfig.example` - 範例檔案
- 所有其他配置檔案

## 團隊協作

當新成員加入專案時，請確保他們：
1. 取得自己的 Google Maps API Key
2. 按照上述步驟建立配置檔案
3. 不要分享或提交實際的 API Key

## 安全性建議

1. 為不同的環境（開發、測試、正式）使用不同的 API Key
2. 在 Google Cloud Console 設定 API Key 的應用程式限制
3. 定期輪換 API Key
4. 監控 API Key 的使用情況，及時發現異常

