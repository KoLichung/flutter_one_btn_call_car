import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'call_car_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  // 使用 GlobalKey 来访问 CallCarPage 的状态
  final GlobalKey<State<CallCarPage>> _callCarPageKey = GlobalKey<State<CallCarPage>>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CallCarPage(key: _callCarPageKey),
      const ProfilePage(),
    ];
  }

  // 检查是否有案件正在进行中
  bool _hasActiveCase() {
    return CallCarPage.hasActiveCase(_callCarPageKey);
  }

  void _handleTabTap(int index) {
    // 如果要切换到 profile tab (index 1) 且当前在 call car tab (index 0)
    if (index == 1 && _currentIndex == 0) {
      if (_hasActiveCase()) {
        // 有案件进行中，阻止切换并显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotSwitchWithActiveCase),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }
    
    // 允许切换
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleTabTap,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_taxi),
            label: AppLocalizations.of(context)!.callCarPage,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}

