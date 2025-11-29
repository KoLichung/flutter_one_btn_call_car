import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyCustomer = 'customer';
  static const String _keyCustomerId = 'customer_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // 保存用户信息
  Future<void> saveCustomer(Customer customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomer, jsonEncode(customer.toJson()));
    await prefs.setInt(_keyCustomerId, customer.id);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // 获取用户信息
  Future<Customer?> getCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final customerJson = prefs.getString(_keyCustomer);
    if (customerJson != null) {
      return Customer.fromJson(jsonDecode(customerJson));
    }
    return null;
  }

  // 保存用户 ID
  Future<void> saveCustomerId(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCustomerId, customerId);
  }

  // 获取用户 ID
  Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCustomerId);
  }

  // 检查是否登录
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // 清除用户信息（登出）
  Future<void> clearCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomer);
    await prefs.remove(_keyCustomerId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // 清除所有数据
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

