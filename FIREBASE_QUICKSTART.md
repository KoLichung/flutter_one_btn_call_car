# 🚀 Firebase FCM 快速設定指南

完整版請參考: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

---

## ⚡ 快速步驟總覽

### 1️⃣ 建立 Firebase 專案 (5分鐘)

1. 前往 https://console.firebase.google.com/
2. 點擊「新增專案」
3. 輸入專案名稱: `flutter-one-btn-call-car`
4. 建立完成

---

### 2️⃣ Android 設定 (10分鐘)

#### 步驟 A: 在 Firebase Console 新增 Android App

- **套件名稱**: `com.chijia.flutter_one_btn_call_car`
- 下載 `google-services.json`

#### 步驟 B: 放置設定檔

```bash
# 將下載的檔案放到這個位置
android/app/google-services.json
```

#### 步驟 C: 修改 android/build.gradle.kts

在 `plugins` 區塊添加:

```kotlin
plugins {
    // ... 其他 plugins
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

#### 步驟 D: 修改 android/app/build.gradle.kts

在 `plugins` 區塊添加（**在最後**）:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // ... 其他 plugins
    
    // 添加這一行
    id("com.google.gms.google-services")
}
```

---

### 3️⃣ iOS 設定 (15分鐘)

#### 步驟 A: 在 Firebase Console 新增 iOS App

- **套件 ID**: `com.chijia.flutterOneBtnCallCar`
- 下載 `GoogleService-Info.plist`

#### 步驟 B: 使用 Xcode 添加設定檔

```bash
# 打開 Xcode
cd /Users/kolichung/CursorProjects/flutter_one_btn_call_car
open ios/Runner.xcworkspace
```

1. 在 Xcode 中，右鍵點擊 **Runner** 資料夾
2. 選擇「Add Files to "Runner"...」
3. 選擇 `GoogleService-Info.plist`
4. ✅ 勾選「Copy items if needed」
5. ✅ 勾選「Runner」target
6. 點擊「Add」

#### 步驟 C: 啟用 Push Notifications

在 Xcode 中:

1. 選擇 **Runner** 專案 → **Runner** target
2. 點擊「**Signing & Capabilities**」
3. 點擊「**+ Capability**」
4. 添加「**Push Notifications**」
5. 再次點擊「**+ Capability**」
6. 添加「**Background Modes**」
7. 勾選「**Remote notifications**」

#### 步驟 D: 設定 APNs 金鑰 (重要！)

1. 前往 https://developer.apple.com/account/
2. 選擇「Certificates, Identifiers & Profiles」→「Keys」
3. 點擊「+」建立新金鑰
4. 名稱: `Flutter Call Car APNs`
5. 勾選「**Apple Push Notifications service (APNs)**」
6. 下載 `.p8` 檔案（**只能下載一次，請妥善保管！**）
7. 記錄 **Key ID** 和 **Team ID**

#### 步驟 E: 上傳 APNs 金鑰到 Firebase

1. 回到 Firebase Console
2. **⚙️ 專案設定** → **Cloud Messaging**
3. 找到「Apple 應用程式設定」
4. 上傳 `.p8` 檔案，填入 Key ID 和 Team ID

---

### 4️⃣ 更新 .gitignore (1分鐘)

確認已添加到 `.gitignore`:

```gitignore
# Firebase 配置檔案（請勿提交）
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

---

### 5️⃣ 安裝並測試 (5分鐘)

```bash
cd /Users/kolichung/CursorProjects/flutter_one_btn_call_car

# 清理並安裝
flutter clean
flutter pub get

# iOS 需要額外安裝 CocoaPods
cd ios
pod install
cd ..

# 運行 App
flutter run
```

---

### 6️⃣ 驗證 FCM 是否正常運作

運行 App 後，查看 Console 輸出:

✅ 成功:
```
🚀 開始初始化 FCM...
✅ 通知權限已授予
📱 設備 ID: xxx
🔑 FCM Token: xxx
✅ FCM 初始化完成
```

登入後:
```
📤 向服務器註冊 FCM...
✅ FCM 註冊成功: 设备注册成功
```

❌ 如果失敗:
- 檢查 `google-services.json` / `GoogleService-Info.plist` 是否在正確位置
- 檢查網路連線
- 查看 Console 錯誤訊息

---

### 7️⃣ 發送測試通知

#### 方法 A: 使用 Firebase Console

1. 前往 Firebase Console
2. 選擇「**Cloud Messaging**」(Engage 區塊)
3. 點擊「**New campaign**」
4. 選擇「**Firebase Notification messages**」
5. 填寫通知內容
6. 選擇「**單一裝置**」，貼上 FCM Token
7. 發送

#### 方法 B: 使用後端 API

後端調用 FCM API 發送通知給特定用戶。

---

## 📋 設定檢查清單

### Android
- [ ] Firebase 專案已建立
- [ ] Android App 已新增到 Firebase
- [ ] `google-services.json` 已下載並放到 `android/app/`
- [ ] `android/build.gradle.kts` 已添加 `google-services` 插件
- [ ] `android/app/build.gradle.kts` 已添加 `google-services` 插件
- [ ] App 已成功運行並獲取 FCM Token

### iOS
- [ ] iOS App 已新增到 Firebase
- [ ] `GoogleService-Info.plist` 已下載並添加到 Xcode
- [ ] Xcode 已啟用 Push Notifications capability
- [ ] Xcode 已啟用 Background Modes → Remote notifications
- [ ] APNs 金鑰已建立並下載
- [ ] APNs 金鑰已上傳到 Firebase Console
- [ ] 使用實體設備測試（模擬器不支援推送通知）

### 共通
- [ ] `firebase_core` 和 `firebase_messaging` 已添加到 `pubspec.yaml`
- [ ] `flutter pub get` 已執行
- [ ] iOS 已執行 `pod install`
- [ ] App 登入後可成功註冊 FCM
- [ ] 可以接收測試通知

---

## 🆘 常見錯誤快速修復

### 錯誤 1: Android 編譯失敗

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 錯誤 2: iOS CocoaPods 錯誤

```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
flutter clean
flutter run
```

### 錯誤 3: FCM Token 為 null

- 檢查網路連線
- 確認 Firebase 配置檔案是否正確
- 重新安裝 App

### 錯誤 4: iOS 收不到通知

- **必須使用實體設備測試！** (模擬器不支援)
- 確認 APNs 金鑰已上傳到 Firebase
- 確認已在 Xcode 啟用 Push Notifications

---

## 🎯 後端整合要點

### API 端點已實作

✅ `POST /one_btn_call_car_api/fcm/register/`

請求 Body:
```json
{
  "registration_id": "FCM_TOKEN",
  "device_id": "UNIQUE_DEVICE_ID",
  "type": "android"  // 或 "ios"
}
```

### 何時註冊 FCM

已自動整合在以下場景:
- ✅ 手機號註冊成功後
- ✅ 手機號登入成功後
- ✅ LINE 登入成功後

### 何時取消註冊

- ✅ 用戶登出時

---

## 📱 通知類型建議

後端可根據業務邏輯發送不同類型的通知:

| 類型 | 觸發時機 | 用途 |
|------|----------|------|
| `driver_assigned` | 司機接單 | 通知乘客司機資訊 |
| `driver_arrived` | 司機到達 | 提醒乘客上車 |
| `trip_started` | 開始行程 | 記錄開始時間 |
| `trip_finished` | 行程完成 | 顯示費用，請求評價 |

---

## ✅ 完成後的功能

- 🔔 用戶登入後自動註冊推送通知
- 📱 App 在前台/背景/關閉時都能收到通知
- 🚗 司機狀態更新時即時通知乘客
- 💰 行程完成時推送費用通知
- 🔓 登出時自動取消註冊

---

**需要完整說明？請查看 [FIREBASE_SETUP.md](FIREBASE_SETUP.md)**

