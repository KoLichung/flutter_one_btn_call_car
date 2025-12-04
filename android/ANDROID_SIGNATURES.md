# Android Package Signatures for LINE Login

## 📦 為 LINE Developers Console 配置使用

---

## ✅ Debug 版本 (開發測試用)

### SHA-1
```
53:C3:BD:3E:AE:E1:A8:A5:0E:08:9B:69:D4:CE:C3:B3:6C:C3:02:0A
```

### SHA-256 ⭐ (LINE Login 需要這個)
```
6E:23:3F:00:44:7B:E1:82:4D:C0:38:29:E1:FA:8C:B7:B3:2D:B7:01:BC:5A:3D:BB:36:63:46:65:3C:81:7E:DF
```

**用途**: 
- 在開發階段使用 `flutter run` 或 Android Studio 直接運行時使用
- 安裝在實體設備或模擬器進行測試

**Keystore 位置**: 
```
~/.android/debug.keystore
```

---

## ✅ Release 版本 (正式發布用)

### SHA-1
```
D1:4D:C6:AA:E7:FB:FF:47:46:F8:BA:AC:FB:E5:D4:82:4D:CF:D6:A8
```

### SHA-256 ⭐ (LINE Login 需要這個)
```
FF:5C:95:0F:35:96:DC:CF:34:46:1C:03:72:5F:61:3F:61:3F:7B:41:17:09:CC:9F:F0:87:77:2F:CC:B6:7A:BC
```

**用途**: 
- 打包正式版 APK/AAB 發布到 Google Play Store 或其他渠道
- 使用 `flutter build apk --release` 或 `flutter build appbundle` 時使用

**Keystore 位置**: 
```
android/app/upload-keystore.jks
```

**Keystore 資訊**:
- **Store Password**: `flutter123`
- **Key Password**: `flutter123`
- **Key Alias**: `upload`
- **有效期**: 10,000 天

**配置檔案**: 
```
android/key.properties
```

---

## 📋 LINE Developers Console 設定步驟

### 1. 登入 LINE Developers Console
前往: https://developers.line.biz/console/

### 2. 選擇您的 Channel
- Channel ID: **2008591636**

### 3. 進入 LINE Login 設定
點擊「LINE Login」標籤

### 4. 設定 Android App

找到「Android app settings」區塊，填入以下資訊：

#### Package name (包名)
```
com.chijia.flutter_one_btn_call_car
```

#### Package signature (開發階段)
**使用 Debug SHA-256** (冒號分隔或不分隔都可以):
```
6E:23:3F:00:44:7B:E1:82:4D:C0:38:29:E1:FA:8C:B7:B3:2D:B7:01:BC:5A:3D:BB:36:63:46:65:3C:81:7E:DF
```

或無冒號格式:
```
6E233F00447BE1824DC03829E1FA8CB7B32DB701BC5A3DBB3663466538C817EDF
```

#### Package signature (正式發布時)
**切換為 Release SHA-256**:
```
FF:5C:95:0F:35:96:DC:CF:34:46:1C:03:72:5F:61:3F:61:3F:7B:41:17:09:CC:9F:F0:87:77:2F:CC:B6:7A:BC
```

或無冒號格式:
```
FF5C950F3596DCCF34461C03725F613F613F7B411709CC9FF087772FCCB67ABC
```

---

## 🔄 使用場景

### 開發測試階段
✅ 在 LINE Console 填入 **Debug SHA-256**
```
6E:23:3F:00:44:7B:E1:82:4D:C0:38:29:E1:FA:8C:B7:B3:2D:B7:01:BC:5A:3D:BB:36:63:46:65:3C:81:7E:DF
```

運行命令:
```bash
flutter run
flutter install
```

### 正式發布階段
✅ 在 LINE Console **添加** Release SHA-256 (不要刪除 Debug 的)
```
FF:5C:95:0F:35:96:DC:CF:34:46:1C:03:72:5F:61:3F:61:3F:7B:41:17:09:CC:9F:F0:87:77:2F:CC:B6:7A:BC
```

運行命令:
```bash
flutter build apk --release
flutter build appbundle --release
```

---

## ⚠️ 重要提醒

### 1. 可以同時配置多個簽名
LINE Console 允許您為同一個 Package Name 添加多個 SHA-256 指紋：
- ✅ Debug SHA-256 (開發測試用)
- ✅ Release SHA-256 (正式發布用)

**建議**: 兩個都添加到 LINE Console，這樣開發和發布都能正常使用！

### 2. Keystore 檔案安全
⚠️ **重要**: `upload-keystore.jks` 和 `key.properties` 包含敏感資訊
- ❌ 不要提交到 Git
- ❌ 不要分享給他人
- ✅ 請妥善保管並備份

已自動添加到 `.gitignore`:
```
android/key.properties
android/app/upload-keystore.jks
```

### 3. 如何重新生成指紋 (如果需要)

**Debug 版本**:
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android | grep SHA256
```

**Release 版本**:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks \
  -alias upload \
  -storepass flutter123 \
  -keypass flutter123 | grep SHA256
```

---

## 📝 快速配置清單

- [ ] 登入 LINE Developers Console
- [ ] 選擇 Channel 2008591636
- [ ] 進入「LINE Login」→「App settings」
- [ ] 填入 Package Name: `com.chijia.flutter_one_btn_call_car`
- [ ] 添加 Debug SHA-256 (開發用)
- [ ] 添加 Release SHA-256 (發布用)
- [ ] 點擊「Save」或「Update」
- [ ] 等待 5-10 分鐘讓設定生效
- [ ] 重新運行 App 測試

---

## 🚀 測試 LINE 登入

配置完成後:

```bash
# 1. 清理並重新編譯
cd /Users/kolichung/CursorProjects/flutter_one_btn_call_car
flutter clean
flutter pub get

# 2. 運行到 Android 設備
flutter run

# 3. 點擊「LINE 登入」按鈕測試
```

---

**所有簽名已準備完成！請複製 SHA-256 到 LINE Developers Console！** 🎉

