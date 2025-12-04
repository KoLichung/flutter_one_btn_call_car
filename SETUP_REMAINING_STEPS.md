# 🔔 FCM 推送通知 - 剩餘設定步驟

## ✅ 已完成的程式配置

1. ✅ Firebase 依賴已添加到 `pubspec.yaml`
2. ✅ Android Gradle 已配置 Google Services
3. ✅ Android Application.kt 已創建（含自訂音效通道）
4. ✅ FCM Service 已完整實作
5. ✅ 登入/登出時自動註冊/取消 FCM
6. ✅ 音效資料夾已創建

---

## 📱 您需要完成的步驟

### 1️⃣ 準備通知音效檔案 (重要！)

#### Android
請將您的 `ding_dong.mp3` 檔案放到以下位置：
```
android/app/src/main/res/raw/ding_dong.mp3
```

**注意**: 
- 檔名必須是 `ding_dong.mp3`（小寫，無特殊字元）
- 必須是 MP3 格式
- 建議檔案大小 < 1MB

#### iOS
iOS 需要 `.caf` 格式的音效檔，請將音效檔轉換後放到：
```
ios/Runner/ding_dong.caf
```

**轉換方法**（在 Mac 上）:
```bash
cd /Users/kolichung/CursorProjects/flutter_one_btn_call_car
afconvert -f caff -d LEI16 assets/ding_dong.mp3 ios/Runner/ding_dong.caf
```

如果您有 MP3 檔案，請先放到 `assets/ding_dong.mp3`，然後執行上面的轉換命令。

---

### 2️⃣ 在 Xcode 添加音效檔案

1. 打開 Xcode:
```bash
open ios/Runner.xcworkspace
```

2. 在 Xcode 左側找到 **Runner** 資料夾
3. 右鍵點擊 **Runner** → 選擇「Add Files to "Runner"...」
4. 選擇 `ios/Runner/ding_dong.caf`
5. ✅ 勾選「Copy items if needed」
6. ✅ 勾選「Runner」target
7. 點擊「Add」

---

### 3️⃣ iOS Pod 安裝

```bash
cd ios
pod install
cd ..
```

---

### 4️⃣ 運行並測試

```bash
flutter run
```

---

## 🎵 後端發送通知時的音效設定

### Android
後端發送通知時，會自動使用 `default_notification_channel` 的音效設定（已配置為 ding_dong.mp3）。

### iOS
後端發送通知時，需在 payload 中指定音效：

```json
{
  "notification": {
    "title": "司機已到達",
    "body": "您的司機已到達上車地點",
    "sound": "ding_dong.caf"
  },
  "data": {
    "type": "driver_arrived",
    "case_id": "123"
  }
}
```

---

## 🆘 如果您沒有音效檔案

如果暫時沒有 `ding_dong.mp3`，可以：

1. **使用系統預設音效**（暫時方案）
   - Android: 系統會使用預設通知音
   - iOS: 後端發送時使用 `"sound": "default"`

2. **下載測試音效**
   - 可從免費音效網站下載，例如: https://pixabay.com/sound-effects/
   - 搜尋 "ding dong" 或 "notification"

---

## ✅ 檢查清單

音效設定:
- [ ] `assets/ding_dong.mp3` 已放置
- [ ] `android/app/src/main/res/raw/ding_dong.mp3` 已放置
- [ ] iOS 音效已轉換為 `ios/Runner/ding_dong.caf`
- [ ] iOS 音效檔已在 Xcode 中添加
- [ ] `pod install` 已執行

Firebase 設定:
- [ ] `android/app/google-services.json` 已放置（您已完成）
- [ ] `ios/Runner/GoogleService-Info.plist` 已放置（您已完成）
- [ ] iOS 已在 Xcode 啟用 Push Notifications capability
- [ ] iOS 已在 Xcode 啟用 Background Modes → Remote notifications
- [ ] iOS APNs 金鑰已上傳到 Firebase Console

---

## 🚀 完成後即可測試

1. 登入 App
2. 查看 Console 確認 FCM Token 已獲取
3. 從 Firebase Console 發送測試通知
4. 應該會聽到 `ding_dong` 音效

---

**如需協助，請告訴我！** 🎉

