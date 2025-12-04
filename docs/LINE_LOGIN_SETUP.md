# LINE 登入配置指南

## 📋 前置準備

### 1. 註冊 LINE Developers 帳號
1. 前往 [LINE Developers Console](https://developers.line.biz/console/)
2. 使用 LINE 帳號登入
3. 創建一個新的 Provider（如果還沒有）

### 2. 創建 LINE Login Channel
1. 在 Provider 中點擊 "Create a new channel"
2. 選擇 "LINE Login"
3. 填寫必要資訊：
   - Channel name: `一鍵叫車`
   - Channel description: `一鍵叫車應用程式`
   - App types: 選擇 `Native app`

4. 創建完成後，記下以下資訊：
   - **Channel ID**: 您的頻道 ID
   - **Channel Secret**: 您的頻道密鑰

---

## 🤖 Android 配置

### 1. 修改 `android/app/build.gradle.kts`

```kotlin
android {
    defaultConfig {
        // ... 其他配置
        
        manifestPlaceholders["line_channel_id"] = "YOUR_CHANNEL_ID"
    }
}
```

### 2. 修改 `android/app/src/main/AndroidManifest.xml`

在 `<application>` 標籤內添加：

```xml
<activity
    android:name="com.linecorp.linesdk.auth.LineAuthenticationActivity"
    android:exported="true"
    android:launchMode="singleTask"
    android:theme="@android:style/Theme.Translucent.NoTitleBar">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="line"
            android:host="authorize" />
        <data android:scheme="line.${line_channel_id}" />
    </intent-filter>
</activity>
```

---

## 🍎 iOS 配置

### 1. 修改 `ios/Runner/Info.plist`

在 `<dict>` 標籤內添加：

```xml
<!-- LINE Login Configuration -->
<key>LineSDKConfig</key>
<dict>
    <key>ChannelID</key>
    <string>YOUR_CHANNEL_ID</string>
</dict>

<!-- URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>

<!-- LSApplicationQueriesSchemes -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>lineauth2</string>
</array>
```

### 2. 在 LINE Developers Console 設定

前往您的 LINE Login channel 設定頁面：

1. **iOS Bundle ID**: 輸入 `com.example.flutterOneBtnCallCar`
   （或您的實際 Bundle ID，可在 `ios/Runner.xcodeproj/project.pbxproj` 中找到）

2. **iOS Universal Link**: （可選）如果需要網頁登入回調

---

## 🔧 在 App 中初始化

### 修改 `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'services/auth_service.dart';
import 'services/line_login_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 LINE SDK
  await LineLoginService().initialize('YOUR_CHANNEL_ID');
  
  runApp(const MyApp());
}
```

---

## 📱 LINE Developers Console 設定

### 1. Callback URL（如果使用網頁登入）
```
https://your-domain.com/auth/line/callback
```

### 2. 測試用戶
在開發階段，需要將測試用戶添加到 Channel 的測試用戶列表中：
1. 進入 Channel 設定
2. 找到 "Roles" 或"Testing" 標籤
3. 添加測試用戶的 LINE ID

---

## 🧪 測試步驟

### 1. 安裝依賴
```bash
cd /Users/kolichung/CursorProjects/flutter_one_btn_call_car
flutter pub get
```

### 2. 確認 LINE App 已安裝
- 在測試設備上安裝 LINE App
- 確保已登入 LINE 帳號

### 3. 運行應用
```bash
flutter run
```

### 4. 測試登入流程
1. 點擊「LINE 登入」按鈕
2. 會跳轉到 LINE App 或網頁授權
3. 授權後自動返回 App
4. 顯示登入成功

---

## ⚠️ 常見問題

### Q1: LINE App 無法打開
**解決方案**: 
- 確認已安裝 LINE App
- 檢查 `AndroidManifest.xml` 和 `Info.plist` 的 URL Scheme 配置

### Q2: 授權後無法返回 App
**解決方案**:
- Android: 檢查 `manifestPlaceholders` 中的 Channel ID
- iOS: 檢查 `CFBundleURLSchemes` 配置

### Q3: 登入失敗 "Channel ID not found"
**解決方案**:
- 確認已在 `main.dart` 中初始化 LINE SDK
- 確認 Channel ID 正確

### Q4: iOS 編譯錯誤
**解決方案**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

---

## 📄 相關文件

- [LINE Login Documentation](https://developers.line.biz/en/docs/line-login/)
- [flutter_line_sdk Package](https://pub.dev/packages/flutter_line_sdk)
- [LINE Developers Console](https://developers.line.biz/console/)

---

## 🔑 重要提醒

1. **不要將 Channel Secret 提交到版本控制**
2. **Channel ID 可以公開，但 Channel Secret 必須保密**
3. **在正式發布前，記得在 LINE Console 中將 Channel 設為 Published 狀態**
4. **測試時確保測試用戶已添加到 Channel 的測試用戶列表**

---

## ✅ 配置檢查清單

- [ ] 已創建 LINE Login Channel
- [ ] 已獲取 Channel ID
- [ ] Android: 已配置 `build.gradle.kts`
- [ ] Android: 已配置 `AndroidManifest.xml`
- [ ] iOS: 已配置 `Info.plist`
- [ ] iOS: 已在 LINE Console 設定 Bundle ID
- [ ] 已在 `main.dart` 初始化 LINE SDK
- [ ] 已安裝 LINE App 並登入
- [ ] 已添加測試用戶（開發階段）

