# 🚀 快速開始指南

## 30 秒快速啟動

```bash
# 1. 安裝依賴
flutter pub get

# 2. 執行應用程式（會打開模擬器/裝置）
flutter run
```

> ⚠️ **注意**: 地圖功能需要 Google Maps API Key 才能正常顯示。不過您可以先執行看看 UI 效果！

---

## 完整設定（包含地圖功能）

### 步驟 1: 取得 Google Maps API Key

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 建立新專案
3. 啟用 **Maps SDK for Android** 和 **Maps SDK for iOS**
4. 建立 API 金鑰並複製

### 步驟 2: 配置 API Key

#### Android
編輯 `android/app/src/main/AndroidManifest.xml`

找到第 15 行：
```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```
替換成您的 API Key。

#### iOS
編輯 `ios/Runner/AppDelegate.swift`

找到第 12 行：
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```
替換成您的 API Key。

### 步驟 3: 執行應用程式

```bash
flutter run
```

---

## 測試流程

### 1️⃣ 登入
- 輸入任意手機號碼（至少 10 位數）
- 或點擊 LINE 登入按鈕
- 點擊登入

### 2️⃣ 叫車
- 點擊「一鍵叫車」按鈕
- 等待 2 秒（模擬搜尋）
- 查看司機資訊
- 點擊「確認上車」
- 點擊「結束行程」

### 3️⃣ 查看紀錄
- 切換到「個人資料」Tab
- 點擊「叫車紀錄」
- 點擊任意紀錄查看詳情和路線圖

---

## 專案結構

```
lib/
├── main.dart              # 應用程式入口
├── models/                # 資料模型
│   ├── user.dart
│   └── ride_record.dart
└── screens/               # 所有頁面
    ├── login_page.dart          # 登入/註冊
    ├── home_page.dart           # 主頁（Tab 導航）
    ├── call_car_page.dart       # 叫車頁面 🚕
    ├── profile_page.dart        # 個人資料
    ├── ride_history_page.dart   # 叫車紀錄
    └── ride_detail_page.dart    # 行程詳情
```

---

## 功能清單

### ✅ 已完成
- 登入/註冊頁面（手機 + LINE）
- 一鍵叫車功能
- Google Maps 整合
- 車輛搜尋與配對
- 行程追蹤
- 叫車紀錄查看
- 行程軌跡顯示
- 個人資料管理

### 📝 說明
所有功能都是 **UI 模擬**，使用模擬資料展示完整流程。

---

## 常見問題

### Q: 地圖沒有顯示？
**A**: 需要配置 Google Maps API Key。參考上方「完整設定」步驟。

### Q: 可以在真機上測試嗎？
**A**: 可以！執行 `flutter devices` 查看可用裝置，然後 `flutter run -d <device-id>`

### Q: 如何重新開始？
**A**: 重新啟動應用程式，或點擊登出按鈕。

### Q: 資料會保存嗎？
**A**: 目前所有資料都是模擬的，重啟後會重置。

---

## 下一步

1. ✅ **體驗完整 UI 流程**
2. 📱 **在真機上測試**
3. 🔧 **整合後端 API**
4. 🚀 **部署到商店**

---

## 更多資訊

- 📖 完整說明: `README.md`
- 🔧 詳細設定: `SETUP.md`
- 📋 功能文檔: `docs/FEATURES.md`
- 📝 實現總結: `docs/IMPLEMENTATION_SUMMARY.md`

---

## 需要幫助？

如有任何問題，請參考文檔或查看程式碼註解。

**祝您使用愉快！** 🎉

