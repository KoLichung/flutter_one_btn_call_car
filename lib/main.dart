import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'services/auth_service.dart';
import 'services/line_login_service.dart';
import 'services/fcm_service.dart';

/// 全局的后台消息处理函数（必须在 main 之外）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 确保 Firebase 已初始化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔔 背景通知: ${message.notification?.title}');
  print('📨 背景訊息: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 设置后台消息处理器
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // 初始化 LINE SDK
  await LineLoginService().initialize('2008591636');
  
  // 初始化 FCM（请求权限并获取 Token）
  await FcmService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh'), // Chinese (Traditional)
        Locale('zh', 'Hans'), // Chinese (Simplified)
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        print('🌍 [Locale] 設備語言: $locale');
        print('🌍 [Locale] 語言代碼: ${locale?.languageCode}');
        print('🌍 [Locale] 國家代碼: ${locale?.countryCode}');
        print('🌍 [Locale] Script 代碼: ${locale?.scriptCode}');
        print('🌍 [Locale] 支持的語言: $supportedLocales');
        
        if (locale == null) {
          print('🌍 [Locale] 設備語言為 null，使用英文');
          return const Locale('en');
        }
        
        // 如果是英文，直接返回英文
        if (locale.languageCode == 'en') {
          print('🌍 [Locale] ✅ 選擇英文');
          return const Locale('en');
        }
        
        // 如果是中文，根據 script 或 country code 選擇簡體或繁體
        if (locale.languageCode == 'zh') {
          print('🌍 [Locale] 檢測到中文');
          
          // 檢查 script code
          if (locale.scriptCode != null) {
            print('🌍 [Locale] Script 代碼: ${locale.scriptCode}');
            if (locale.scriptCode == 'Hans') {
              print('🌍 [Locale] ✅ 選擇簡體中文（Hans script）');
              return const Locale('zh', 'Hans');
            } else if (locale.scriptCode == 'Hant') {
              print('🌍 [Locale] ✅ 選擇繁體中文（Hant script）');
              return const Locale('zh');
            }
          }
          
          // 檢查 country code
          if (locale.countryCode != null) {
            print('🌍 [Locale] 國家代碼: ${locale.countryCode}');
            if (locale.countryCode == 'CN' || locale.countryCode == 'SG') {
              print('🌍 [Locale] ✅ 選擇簡體中文（CN/SG）');
              return const Locale('zh', 'Hans');
            } else {
              print('🌍 [Locale] ✅ 選擇繁體中文（TW/HK/MO等）');
              return const Locale('zh');
            }
          }
          
          // 默認繁體中文
          print('🌍 [Locale] ✅ 選擇繁體中文（默認）');
          return const Locale('zh');
        }
        
        // 其他語言，使用英文
        print('🌍 [Locale] ✅ 不支持的語言 ${locale.languageCode}，使用英文');
        return const Locale('en');
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// 启动页 - 检查登录状态
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 延迟一小段时间显示启动页
    await Future.delayed(const Duration(milliseconds: 500));

    final isLoggedIn = await _authService.isLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        // 已登录，跳转到主页
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // 未登录，跳转到登录页
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
                  const SizedBox(height: 30),
                  Text(
                    AppLocalizations.of(context)!.appName,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

