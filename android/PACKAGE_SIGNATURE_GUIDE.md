# 🔐 Android Package Signature 說明

---

## ✅ 已為您生成兩個版本的簽名

### 📱 Debug 版本 (開發測試用)

**SHA-256 指紋**:
```
6E:23:3F:00:44:7B:E1:82:4D:C0:38:29:E1:FA:8C:B7:B3:2D:B7:01:BC:5A:3D:BB:36:63:46:65:3C:81:7E:DF
```

**用途**: 
- 使用 `flutter run` 在 Android 設備/模擬器上測試
- 開發階段的 LINE 登入功能測試

---

### 📦 Release 版本 (正式發布用)

**SHA-256 指紋**:
```
FF:5C:95:0F:35:96:DC:CF:34:46:1C:03:72:5F:61:3F:61:3F:7B:41:17:09:CC:9F:F0:87:77:2F:CC:B6:7A:BC
```

**用途**: 
- 打包正式版 APK/AAB 發布
- 上架到 Google Play Store 或其他渠道

**Keystore 資訊**:
- 檔案位置: `android/app/upload-keystore.jks`
- Store Password: `flutter123`
- Key Password: `flutter123`
- Key Alias: `upload`

---

## 🎯 LINE Developers Console 設定

### 步驟 1: 登入並選擇 Channel
1. 前往 https://developers.line.biz/console/
2. 選擇 Channel ID: **2008591636**
3. 點擊「LINE Login」標籤

### 步驟 2: 設定 Android App

在「App settings」區塊找到「Android」設定：

#### Package Name
```
com.chijia.flutter_one_btn_call_car
```

#### Package Signature (建議兩個都添加)

**開發測試用** - Debug SHA-256:
```
6E:23:3F:00:44:7B:E1:82:4D:C0:38:29:E1:FA:8C:B7:B3:2D:B7:01:BC:5A:3D:BB:36:63:46:65:3C:81:7E:DF
```

**正式發布用** - Release SHA-256:
```
FF:5C:95:0F:35:96:DC:CF:34:46:1C:03:72:5F:61:3F:61:3F:7B:41:17:09:CC:9F:F0:87:77:2F:CC:B6:7A:BC
```

### 步驟 3: 儲存設定
點擊「Update」或「Save」按鈕

---

## 💡 什麼是 Package Signature？

**簡單理解**:
- 就像是您的 App 的「數位指紋」或「身份證」
- 每個 Keystore (簽名檔) 都有唯一的 SHA-256 指紋
- LINE 用這個來確認是「您的 App」在請求登入，而不是別人假冒的

**為什麼需要**:
- 🔒 **安全性**: 防止其他人假冒您的 App 進行 LINE 登入
- ✅ **驗證**: LINE 會檢查簽名是否匹配才允許登入
- 🎯 **唯一性**: 確保只有您簽名的 APK 能使用您的 LINE Channel

---

## 🔄 Debug vs Release 的差異

### Debug Keystore
- **位置**: `~/.android/debug.keystore`
- **用途**: 開發測試
- **密碼**: 固定的 (android/android)
- **特點**: Android Studio 和 Flutter 自動使用
- **共用**: 所有開發者的 debug keystore 密碼都一樣，但指紋不同

### Release Keystore
- **位置**: `android/app/upload-keystore.jks` (您的專案中)
- **用途**: 正式發布
- **密碼**: 您設定的 (flutter123/flutter123)
- **特點**: 需要手動配置和保護
- **唯一**: 只有您有這個檔案，遺失就無法更新 App

---

## ⚠️ 重要注意事項

### 1. Keystore 檔案保護
⚠️ **Release Keystore 非常重要！**
- ❌ 不要提交到 Git (已加入 .gitignore)
- ❌ 不要分享給他人
- ✅ 請備份到安全的地方
- ⚠️ **遺失 = 無法在 Google Play 更新 App**

### 2. 密碼記錄
您的 Release Keystore 密碼:
```
Store Password: flutter123
Key Password: flutter123
Key Alias: upload
```

**建議**: 將這些資訊存放在安全的密碼管理器中

### 3. LINE Console 建議
✅ **同時添加 Debug 和 Release 簽名**
- 開發時使用 Debug 簽名測試
- 發布時使用 Release 簽名
- 兩個都設定就不用來回切換

---

## 🚀 測試流程

### 開發階段測試

1. **確認已在 LINE Console 添加 Debug SHA-256**
2. **運行 App**:
   ```bash
   flutter run
   ```
3. **點擊 LINE 登入測試**

### 發布前測試

1. **確認已在 LINE Console 添加 Release SHA-256**
2. **打包 Release 版本**:
   ```bash
   flutter build apk --release
   ```
3. **安裝到設備測試**:
   ```bash
   flutter install
   ```
4. **點擊 LINE 登入測試**

---

## 📋 設定檔案說明

### `android/key.properties`
```properties
storePassword=flutter123
keyPassword=flutter123
keyAlias=upload
storeFile=app/upload-keystore.jks
```

這個檔案告訴 Flutter 如何使用您的 Release Keystore。

### `android/app/upload-keystore.jks`
這是實際的簽名檔案，包含加密金鑰。

---

## 🔍 如何驗證簽名

如果您需要驗證 APK 的簽名:

```bash
# 查看 APK 的簽名
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk | grep SHA256
```

---

## 📞 常見問題

### Q: 為什麼 LINE 登入還是失敗？
A: 請檢查：
1. Package Name 是否完全匹配: `com.chijia.flutter_one_btn_call_car`
2. SHA-256 是否正確複製 (包含冒號)
3. LINE Console 設定是否已儲存
4. 等待 5-10 分鐘讓設定生效

### Q: Debug 和 Release 可以共用嗎？
A: 不行！它們有不同的簽名指紋，必須分別添加到 LINE Console。

### Q: 我可以換一個 Keystore 嗎？
A: 可以，但：
- 如果 App 已上架 Google Play，換 Keystore = 無法更新，只能發布新 App
- 換了需要在 LINE Console 更新新的 SHA-256

### Q: 密碼可以改嗎？
A: 不建議。已經生成的 Keystore 修改密碼很複雜，建議重新生成。

---

**所有簽名已準備完成！請將 SHA-256 複製到 LINE Developers Console！** 🎉

詳細簽名資訊請查看: `ANDROID_SIGNATURES.md`

