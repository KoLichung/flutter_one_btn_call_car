import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfileDetailPage extends StatefulWidget {
  final Customer customer;

  const ProfileDetailPage({super.key, required this.customer});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  final AuthService _authService = AuthService();
  bool _isDeleting = false;

  String _getLoginMethodText(BuildContext context) {
    switch (widget.customer.loginMethod) {
      case 'phone':
        return AppLocalizations.of(context)!.phoneLoginMethod(widget.customer.phone ?? '');
      case 'line':
        return AppLocalizations.of(context)!.lineLoginMethod;
      case 'apple':
        return AppLocalizations.of(context)!.appleLoginMethod;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }

  IconData _getLoginMethodIcon() {
    switch (widget.customer.loginMethod) {
      case 'phone':
        return Icons.phone_android;
      case 'line':
        return Icons.chat_bubble;
      case 'apple':
        return Icons.apple;
      default:
        return Icons.person;
    }
  }

  Color _getLoginMethodColor() {
    switch (widget.customer.loginMethod) {
      case 'phone':
        return Colors.blue;
      case 'line':
        return const Color(0xFF00B900);
      case 'apple':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleDeleteAccount() async {
    // 第一次確認
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.deleteAccountTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.deleteAccountConfirm,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.deleteAccountWarning,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.deleteAccountInfo1),
            Text(AppLocalizations.of(context)!.deleteAccountInfo2),
            Text(AppLocalizations.of(context)!.deleteAccountInfo3),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.confirmDelete),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    // 第二次確認（更嚴重的警告）
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.lastConfirm),
        content: Text(
          AppLocalizations.of(context)!.lastConfirmMessage,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.confirmDeleteForever),
          ),
        ],
      ),
    );

    if (secondConfirm != true || !mounted) return;

    // 執行刪除
    setState(() {
      _isDeleting = true;
    });

    final result = await _authService.deleteAccount();

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.accountDeleted),
          backgroundColor: Colors.green,
        ),
      );

      // 導航到登入頁面
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? AppLocalizations.of(context)!.accountDeleteFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.accountDetails),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Display Name
                  Text(
                    widget.customer.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Account Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Login Method Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getLoginMethodColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getLoginMethodIcon(),
                              color: _getLoginMethodColor(),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.loginMethod,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getLoginMethodText(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Danger Zone
                  Text(
                    AppLocalizations.of(context)!.dangerZone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Delete Account Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 1),
                    ),
                    child: InkWell(
                      onTap: _isDeleting ? null : _handleDeleteAccount,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isDeleting
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.deleteAccount,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.deleteAccountSubtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

