# 🔔 Firebase Cloud Messaging (FCM) 設定指南

本文檔將指導您如何設定 Firebase 推送通知功能。

---

## 📋 目錄

1. [前提條件](#前提條件)
2. [建立 Firebase 專案](#建立-firebase-專案)
3. [Android 設定](#android-設定)
4. [iOS 設定](#ios-設定)
5. [測試推送通知](#測試推送通知)
6. [常見問題](#常見問題)

---

## ✅ 前提條件

- Google 帳號
- 已完成 Flutter 專案基本設定
- Android Studio 或 Xcode（用於平台特定設定）

---

## 🚀 建立 Firebase 專案

### 步驟 1: 前往 Firebase Console

1. 打開瀏覽器前往: https://console.firebase.google.com/
2. 點擊「新增專案」或「Add project」

### 步驟 2: 建立專案

1. **輸入專案名稱**: 例如 `flutter-one-btn-call-car`
2. **啟用 Google Analytics** (可選): 建議啟用以追蹤通知效能
3. **選擇 Analytics 帳戶**: 選擇現有帳戶或建立新帳戶
4. 點擊「建立專案」

### 步驟 3: 啟用 Cloud Messaging

1. 在 Firebase Console 左側選單中，點擊 **⚙️ 專案設定** (Project Settings)
2. 選擇「**Cloud Messaging**」標籤
3. 記錄以下資訊（稍後會用到）:
   - **Server Key** (用於後端發送通知)
   - **Sender ID** (用於 App 接收通知)

---

## 📱 Android 設定

### 步驟 1: 新增 Android App 到 Firebase

1. 在 Firebase Console 中，點擊「新增應用程式」
2. 選擇 **Android** 圖標
3. 填寫應用程式資訊:
   - **Android 套件名稱**: `com.chijia.flutter_one_btn_call_car`
   - **應用程式暱稱** (選填): `一鍵叫車 Android`
   - **Debug 簽章憑證 SHA-1** (選填但建議): 從 `ANDROID_SIGNATURES.md` 複製 Debug SHA-1

### 步驟 2: 下載 google-services.json

1. 點擊「下載 google-services.json」按鈕
2. 將下載的檔案放到專案路徑:
   ```
   android/app/google-services.json
   ```

**重要**: 確認檔案位置正確！

### 步驟 3: 修改 android/build.gradle.kts

打開 `android/build.gradle.kts` (專案根目錄的 build.gradle.kts)，添加 Google Services 插件：

```kotlin
plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
    // 添加這一行
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

### 步驟 4: 修改 android/app/build.gradle.kts

打開 `android/app/build.gradle.kts`，在檔案**最底部**添加：

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // ... 其他 plugins
    
    // 添加這一行（必須在最後）
    id("com.google.gms.google-services")
}

// ... 其他配置

// 在檔案最底部添加（如果還沒有的話）
dependencies {
    // ... 其他依賴
    
    // Firebase 相關（Flutter 插件會自動處理，這裡僅供參考）
    // implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
}
```

### 步驟 5: 更新 .gitignore

確認 `android/app/google-services.json` 已加入 `.gitignore`:

```gitignore
# Firebase
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

---

## 🍎 iOS 設定

### 步驟 1: 新增 iOS App 到 Firebase

1. 在 Firebase Console 中，點擊「新增應用程式」
2. 選擇 **iOS** 圖標
3. 填寫應用程式資訊:
   - **iOS 套件 ID**: `com.chijia.flutterOneBtnCallCar`
   - **應用程式暱稱** (選填): `一鍵叫車 iOS`
   - **App Store ID** (選填): 如果已上架填寫

### 步驟 2: 下載 GoogleService-Info.plist

1. 點擊「下載 GoogleService-Info.plist」按鈕
2. 將下載的檔案放到專案路徑:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

### 步驟 3: 使用 Xcode 添加檔案

1. 打開終端機，執行:
   ```bash
   cd /Users/kolichung/CursorProjects/flutter_one_btn_call_car
   open ios/Runner.xcworkspace
   ```

2. 在 Xcode 中:
   - 找到左側專案導航中的 **Runner** 資料夾
   - 右鍵點擊 **Runner** → 選擇「Add Files to "Runner"...」
   - 選擇剛才下載的 `GoogleService-Info.plist`
   - **重要**: 勾選「Copy items if needed」
   - **重要**: 勾選「Runner」target
   - 點擊「Add」

### 步驟 4: 啟用 Push Notifications Capability

在 Xcode 中:

1. 選擇左側的 **Runner** 專案
2. 選擇 **Runner** target
3. 點擊「**Signing & Capabilities**」標籤
4. 點擊「**+ Capability**」按鈕
5. 搜尋並添加 「**Push Notifications**」
6. 點擊「**+ Capability**」按鈕
7. 搜尋並添加「**Background Modes**」
8. 在 Background Modes 中勾選:
   - ✅ **Remote notifications**

### 步驟 5: 設定 APNs 金鑰（重要！）

iOS 推送通知需要 APNs (Apple Push Notification service) 金鑰。

#### 5.1 建立 APNs 金鑰

1. 前往 [Apple Developer Console](https://developer.apple.com/account/)
2. 登入您的 Apple Developer 帳號
3. 選擇「Certificates, Identifiers & Profiles」
4. 點擊左側「**Keys**」
5. 點擊「**+**」(Create a key)
6. 填寫資訊:
   - **Key Name**: `Flutter One Btn Call Car APNs`
   - 勾選「**Apple Push Notifications service (APNs)**」
7. 點擊「Continue」→「Register」→「Download」
8. **重要**: 下載 `.p8` 檔案並妥善保管（只能下載一次！）
9. 記錄:
   - **Key ID** (例如: ABC123DEF4)
   - **Team ID** (在頁面右上角)

#### 5.2 上傳 APNs 金鑰到 Firebase

1. 回到 Firebase Console
2. 點擊 **⚙️ 專案設定** → 選擇 **Cloud Messaging** 標籤
3. 找到「Apple 應用程式設定」區塊
4. 點擊「上傳」按鈕
5. 填寫資訊:
   - **APNs 驗證金鑰**: 上傳剛才下載的 `.p8` 檔案
   - **金鑰 ID**: 填入剛才記錄的 Key ID
   - **團隊 ID**: 填入剛才記錄的 Team ID
6. 點擊「上傳」

---

## 🧪 測試推送通知

### 1. 安裝依賴並運行

```bash
cd /Users/kolichung/CursorProjects/flutter_one_btn_call_car

# 清理並重新安裝
flutter clean
flutter pub get

# Android
flutter run

# iOS
cd ios
pod install
cd ..
flutter run
```

### 2. 檢查 FCM Token

運行 App 後，查看 Console 輸出，應該會看到:

```
🚀 開始初始化 FCM...
✅ 通知權限已授予
📱 設備 ID: [DEVICE_ID]
🔑 FCM Token: [LONG_TOKEN_STRING]
✅ FCM 初始化完成
```

### 3. 登入並註冊設備

1. 在 App 中登入（手機號或 LINE 登入）
2. 登入成功後，查看 Console 輸出:
   ```
   📤 向服務器註冊 FCM...
   ✅ FCM 註冊成功: 设备注册成功
   ```

### 4. 從 Firebase Console 發送測試通知

1. 前往 Firebase Console
2. 選擇「**Cloud Messaging**」(在「Engage」區塊)
3. 點擊「**Send your first message**」或「**New campaign**」
4. 選擇「**Firebase Notification messages**」
5. 填寫通知內容:
   - **通知標題**: `測試通知`
   - **通知文字**: `這是一則測試推送通知`
6. 點擊「下一步」
7. 選擇目標:
   - 選擇「**單一裝置**」
   - 貼上從 Console 複製的 FCM Token
8. 點擊「下一步」→「檢查」→「發布」

### 5. 驗證通知

**前台測試** (App 正在運行):
- 應該在 Console 看到: `🔔 前台通知: 測試通知`

**背景測試** (App 在背景):
- 應該在通知欄收到通知

**完全關閉測試** (App 已關閉):
- 應該在通知欄收到通知
- 點擊通知會打開 App

---

## 🔧 程式碼使用說明

### 在登入後自動註冊 FCM

已經自動整合在 `AuthService` 中:

```dart
// lib/services/auth_service.dart
await _fcmService.registerToServer(); // 登入成功後自動調用
```

### 處理前台通知

修改 `lib/services/fcm_service.dart` 中的 `_handleForegroundMessage` 方法:

```dart
void _handleForegroundMessage(RemoteMessage message) {
  print('🔔 前台通知: ${message.notification?.title}');
  
  // 顯示應用內通知
  // 例如: 顯示 SnackBar 或 Dialog
}
```

### 處理背景通知點擊

修改 `lib/services/fcm_service.dart` 中的 `_handleMessageOpenedApp` 方法:

```dart
void _handleMessageOpenedApp(RemoteMessage message) {
  final type = message.data['type'];
  
  // 根據通知類型導航到不同頁面
  switch (type) {
    case 'driver_assigned':
      // 導航到叫車頁面
      break;
    case 'trip_finished':
      // 導航到歷史記錄頁面
      break;
  }
}
```

---

## 🎯 後端整合

### 通知類型建議

根據業務邏輯，後端可發送以下類型的通知:

#### 1. 司機已分配
```json
{
  "type": "driver_assigned",
  "case_id": 123,
  "driver_name": "王司機",
  "driver_phone": "0987654321"
}
```

#### 2. 司機已到達
```json
{
  "type": "driver_arrived",
  "case_id": 123,
  "message": "司機已到達上車地點"
}
```

#### 3. 行程開始
```json
{
  "type": "trip_started",
  "case_id": 123
}
```

#### 4. 行程完成
```json
{
  "type": "trip_finished",
  "case_id": 123,
  "case_money": 350,
  "message": "行程已完成，費用為 350 元"
}
```

### 後端發送通知範例 (Python/Django)

```python
from firebase_admin import messaging

def send_notification_to_customer(customer, notification_type, data):
    # 從資料庫獲取客戶的 FCM Token
    fcm_devices = customer.fcm_devices.filter(is_active=True)
    
    for device in fcm_devices:
        message = messaging.Message(
            notification=messaging.Notification(
                title='一鍵叫車',
                body=data.get('message', '您有新的通知'),
            ),
            data={
                'type': notification_type,
                **data
            },
            token=device.registration_id,
        )
        
        try:
            response = messaging.send(message)
            print(f'成功發送通知: {response}')
        except Exception as e:
            print(f'發送通知失敗: {e}')
```

---

## ❓ 常見問題

### Q1: Android 無法收到通知

**檢查清單**:
- ✅ `google-services.json` 是否在 `android/app/` 目錄下
- ✅ `build.gradle.kts` 是否已添加 `google-services` 插件
- ✅ 是否在 Manifest 中添加 `POST_NOTIFICATIONS` 權限
- ✅ 裝置 Android 版本是否 >= 13 (需要運行時權限)
- ✅ 檢查 Console 是否有錯誤訊息

**解決方法**:
```bash
# 清理並重新編譯
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Q2: iOS 無法收到通知

**檢查清單**:
- ✅ `GoogleService-Info.plist` 是否在 `ios/Runner/` 目錄下
- ✅ Xcode 是否已啟用 Push Notifications capability
- ✅ Xcode 是否已啟用 Background Modes → Remote notifications
- ✅ APNs 金鑰是否已上傳到 Firebase Console
- ✅ 是否使用實體設備測試（模擬器不支援推送通知）

**解決方法**:
```bash
# 重新安裝 CocoaPods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Q3: FCM Token 為 null

**可能原因**:
- Firebase 初始化失敗
- 網路連線問題
- `google-services.json` / `GoogleService-Info.plist` 配置錯誤

**解決方法**:
1. 檢查 Firebase 配置檔案是否正確
2. 確認網路連線正常
3. 重新安裝 App

### Q4: 401 錯誤 - 註冊 FCM 失敗

**原因**: 未登入或 Session 過期

**解決方法**:
- FCM 註冊會在登入成功後自動執行
- 如果登出後再登入，會重新註冊

### Q5: 前台收不到通知，但背景可以

**原因**: `FirebaseMessaging.onMessage` 沒有正確處理

**解決方法**:
- 檢查 `lib/services/fcm_service.dart` 中的 `_handleForegroundMessage` 方法
- 可以添加本地通知庫 (如 `flutter_local_notifications`) 在前台顯示通知

---

## 📚 相關資源

- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase 官方文檔](https://firebase.flutter.dev/)
- [FCM 官方文檔](https://firebase.google.com/docs/cloud-messaging)
- [Apple Developer Console](https://developer.apple.com/account/)

---

## 🎉 完成！

設定完成後，您的 App 應該能夠:

✅ 在登入時自動註冊 FCM  
✅ 接收前台通知  
✅ 接收背景通知  
✅ 點擊通知打開 App  
✅ 在登出時取消註冊  

如有任何問題，請檢查 Console 輸出或參考常見問題章節。

