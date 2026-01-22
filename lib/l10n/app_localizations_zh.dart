// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '一鍵叫車';

  @override
  String get appSlogan => '快速、便捷、安全';

  @override
  String get loginTitle => '登入';

  @override
  String get phone => '手機';

  @override
  String get phoneHint => '請輸入手機號碼';

  @override
  String get phoneError => '請輸入手機號碼';

  @override
  String get phoneInvalid => '請輸入有效的手機號碼';

  @override
  String get password => '密碼';

  @override
  String get passwordHint => '請輸入密碼';

  @override
  String get passwordError => '請輸入密碼';

  @override
  String get passwordLength => '密碼至少需要 6 個字元';

  @override
  String get phoneLogin => '手機登入';

  @override
  String get lineLogin => 'LINE 登入';

  @override
  String get appleLogin => 'Apple 登入';

  @override
  String get or => '或';

  @override
  String get phoneRegister => '手機註冊';

  @override
  String get loginFailed => '登入失敗';

  @override
  String get lineLoginFailed => 'LINE 登入失敗';

  @override
  String get appleLoginFailed => 'Apple 登入失敗';

  @override
  String get registerTitle => '註冊帳號';

  @override
  String get registerSlogan => '加入一鍵叫車';

  @override
  String get nickname => '暱稱';

  @override
  String get nicknameHint => '請輸入暱稱';

  @override
  String get nicknameError => '請輸入暱稱';

  @override
  String get confirmRegister => '確認註冊';

  @override
  String get registerFailed => '註冊失敗';

  @override
  String get backToLogin => '已有帳號？返回登入';

  @override
  String get callCarPage => '叫車主頁';

  @override
  String get profile => '個人資料';

  @override
  String get gettingLocation => '獲取位置中...';

  @override
  String get locationFailed => '獲取位置失敗';

  @override
  String get oneClickCallCar => '一鍵叫車';

  @override
  String get calling => '正在叫車...';

  @override
  String get findingDriver => '正在尋找司機...';

  @override
  String get orderNumber => '訂單號:';

  @override
  String get cancelCallCar => '取消叫車';

  @override
  String get driverOnWay => '前往中';

  @override
  String get driverOnWayMessage => '司機正前往您的位置，請耐心等待';

  @override
  String get driverArrived => '等待接客';

  @override
  String get driverArrivedMessage => '司機已到達，請儘快上車';

  @override
  String get onBoard => '旅程中';

  @override
  String get onBoardMessage => '行程進行中，祝您旅途愉快';

  @override
  String get driverLocation => '司機位置';

  @override
  String get callCarFailed => '叫車失敗';

  @override
  String get tripFinished => '行程結束';

  @override
  String get thankYou => '感謝您的使用';

  @override
  String get fare => '本次車資：';

  @override
  String get blacklist => '黑名單';

  @override
  String get confirm => '確定';

  @override
  String get confirmCancel => '確認取消';

  @override
  String get confirmCancelMessage => '確認要取消叫車嗎？';

  @override
  String get thinkAgain => '我再想想';

  @override
  String get confirmCancelButton => '確認取消';

  @override
  String get orderCanceled => '訂單已取消(可能暫時附近無司機)';

  @override
  String get orderCancelSuccess => '訂單已成功取消';

  @override
  String get orderCancelFailed => '取消訂單失敗';

  @override
  String get confirmBlacklist => '確認加入黑名單';

  @override
  String get confirmBlacklistMessage => '確定要將此司機加入黑名單嗎？';

  @override
  String get cancel => '取消';

  @override
  String get blacklistSuccess => '已加入黑名單';

  @override
  String get blacklistFailed => '加入黑名單失敗';

  @override
  String get profileTitle => '個人資料';

  @override
  String get loginMethod => '登入方式';

  @override
  String phoneLoginMethod(String phone) {
    return '手機登入 ($phone)';
  }

  @override
  String get lineLoginMethod => 'LINE 登入';

  @override
  String get appleLoginMethod => 'Apple 登入';

  @override
  String get unknown => '未知';

  @override
  String get rideHistory => '叫車紀錄';

  @override
  String get rideHistorySubtitle => '查看您的搭乘紀錄';

  @override
  String get logout => '登出';

  @override
  String get confirmLogout => '確認登出';

  @override
  String get confirmLogoutMessage => '確定要登出嗎？';

  @override
  String get loading => '載入中...';

  @override
  String get loadUserFailed => '無法加載用戶資料';

  @override
  String get retry => '重試';

  @override
  String get accountDetails => '帳號詳情';

  @override
  String get dangerZone => '危險區域';

  @override
  String get deleteAccount => '刪除帳號';

  @override
  String get deleteAccountSubtitle => '永久刪除您的帳號和所有資料';

  @override
  String get deleteAccountTitle => '刪除帳號';

  @override
  String get deleteAccountConfirm => '您確定要刪除帳號嗎？';

  @override
  String get deleteAccountWarning => '⚠️ 刪除後將無法恢復';

  @override
  String get deleteAccountInfo1 => '• 您的個人資料將被永久刪除';

  @override
  String get deleteAccountInfo2 => '• 歷史訂單記錄將保留但不再關聯您的帳號';

  @override
  String get deleteAccountInfo3 => '• 此操作無法撤銷';

  @override
  String get confirmDelete => '確定刪除';

  @override
  String get lastConfirm => '最後確認';

  @override
  String get lastConfirmMessage => '此操作無法恢復！\n\n確定要永久刪除您的帳號嗎？';

  @override
  String get confirmDeleteForever => '確定，永久刪除';

  @override
  String get accountDeleted => '帳號已成功刪除';

  @override
  String get accountDeleteFailed => '刪除帳號失敗';

  @override
  String get rideHistoryTitle => '叫車紀錄';

  @override
  String get noRideHistory => '尚無叫車紀錄';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String daysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get chatTitle => '對話';

  @override
  String get startConversation => '開始對話';

  @override
  String get messageHint => '輸入訊息...';

  @override
  String get messageMissing => '缺少訂單ID';

  @override
  String get pleaseLogin => '請先登入';

  @override
  String get chatInitFailed => '初始化對話失敗';

  @override
  String get loadMessagesFailed => '加載消息失敗';

  @override
  String get sendFailed => '發送失敗';

  @override
  String get cannotSwitchWithActiveCase => '案件進行中無法切換頁面';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appName => '一键叫车';

  @override
  String get appSlogan => '快速、便捷、安全';

  @override
  String get loginTitle => '登录';

  @override
  String get phone => '手机';

  @override
  String get phoneHint => '请输入手机号码';

  @override
  String get phoneError => '请输入手机号码';

  @override
  String get phoneInvalid => '请输入有效的手机号码';

  @override
  String get password => '密码';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get passwordError => '请输入密码';

  @override
  String get passwordLength => '密码至少需要 6 个字符';

  @override
  String get phoneLogin => '手机登录';

  @override
  String get lineLogin => 'LINE 登录';

  @override
  String get appleLogin => 'Apple 登录';

  @override
  String get or => '或';

  @override
  String get phoneRegister => '手机注册';

  @override
  String get loginFailed => '登录失败';

  @override
  String get lineLoginFailed => 'LINE 登录失败';

  @override
  String get appleLoginFailed => 'Apple 登录失败';

  @override
  String get registerTitle => '注册账号';

  @override
  String get registerSlogan => '加入一键叫车';

  @override
  String get nickname => '昵称';

  @override
  String get nicknameHint => '请输入昵称';

  @override
  String get nicknameError => '请输入昵称';

  @override
  String get confirmRegister => '确认注册';

  @override
  String get registerFailed => '注册失败';

  @override
  String get backToLogin => '已有账号？返回登录';

  @override
  String get callCarPage => '叫车主页';

  @override
  String get profile => '个人资料';

  @override
  String get gettingLocation => '获取位置中...';

  @override
  String get locationFailed => '获取位置失败';

  @override
  String get oneClickCallCar => '一键叫车';

  @override
  String get calling => '正在叫车...';

  @override
  String get findingDriver => '正在寻找司机...';

  @override
  String get orderNumber => '订单号:';

  @override
  String get cancelCallCar => '取消叫车';

  @override
  String get driverOnWay => '前往中';

  @override
  String get driverOnWayMessage => '司机正前往您的位置，请耐心等待';

  @override
  String get driverArrived => '等待接客';

  @override
  String get driverArrivedMessage => '司机已到达，请尽快上车';

  @override
  String get onBoard => '旅程中';

  @override
  String get onBoardMessage => '行程进行中，祝您旅途愉快';

  @override
  String get driverLocation => '司机位置';

  @override
  String get callCarFailed => '叫车失败';

  @override
  String get tripFinished => '行程结束';

  @override
  String get thankYou => '感谢您的使用';

  @override
  String get fare => '本次车资：';

  @override
  String get blacklist => '黑名单';

  @override
  String get confirm => '确定';

  @override
  String get confirmCancel => '确认取消';

  @override
  String get confirmCancelMessage => '确认要取消叫车吗？';

  @override
  String get thinkAgain => '我再想想';

  @override
  String get confirmCancelButton => '确认取消';

  @override
  String get orderCanceled => '订单已取消(可能暂时附近无司机)';

  @override
  String get orderCancelSuccess => '订单已成功取消';

  @override
  String get orderCancelFailed => '取消订单失败';

  @override
  String get confirmBlacklist => '确认加入黑名单';

  @override
  String get confirmBlacklistMessage => '确定要将此司机加入黑名单吗？';

  @override
  String get cancel => '取消';

  @override
  String get blacklistSuccess => '已加入黑名单';

  @override
  String get blacklistFailed => '加入黑名单失败';

  @override
  String get profileTitle => '个人资料';

  @override
  String get loginMethod => '登录方式';

  @override
  String phoneLoginMethod(String phone) {
    return '手机登录 ($phone)';
  }

  @override
  String get lineLoginMethod => 'LINE 登录';

  @override
  String get appleLoginMethod => 'Apple 登录';

  @override
  String get unknown => '未知';

  @override
  String get rideHistory => '叫车记录';

  @override
  String get rideHistorySubtitle => '查看您的搭乘记录';

  @override
  String get logout => '登出';

  @override
  String get confirmLogout => '确认登出';

  @override
  String get confirmLogoutMessage => '确定要登出吗？';

  @override
  String get loading => '载入中...';

  @override
  String get loadUserFailed => '无法加载用户资料';

  @override
  String get retry => '重试';

  @override
  String get accountDetails => '账号详情';

  @override
  String get dangerZone => '危险区域';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountSubtitle => '永久删除您的账号和所有资料';

  @override
  String get deleteAccountTitle => '删除账号';

  @override
  String get deleteAccountConfirm => '您确定要删除账号吗？';

  @override
  String get deleteAccountWarning => '⚠️ 删除后将无法恢复';

  @override
  String get deleteAccountInfo1 => '• 您的个人资料将被永久删除';

  @override
  String get deleteAccountInfo2 => '• 历史订单记录将保留但不再关联您的账号';

  @override
  String get deleteAccountInfo3 => '• 此操作无法撤销';

  @override
  String get confirmDelete => '确定删除';

  @override
  String get lastConfirm => '最后确认';

  @override
  String get lastConfirmMessage => '此操作无法恢复！\n\n确定要永久删除您的账号吗？';

  @override
  String get confirmDeleteForever => '确定，永久删除';

  @override
  String get accountDeleted => '账号已成功删除';

  @override
  String get accountDeleteFailed => '删除账号失败';

  @override
  String get rideHistoryTitle => '叫车记录';

  @override
  String get noRideHistory => '尚无叫车记录';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String daysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get chatTitle => '对话';

  @override
  String get startConversation => '开始对话';

  @override
  String get messageHint => '输入讯息...';

  @override
  String get messageMissing => '缺少订单ID';

  @override
  String get pleaseLogin => '请先登录';

  @override
  String get chatInitFailed => '初始化对话失败';

  @override
  String get loadMessagesFailed => '加载消息失败';

  @override
  String get sendFailed => '发送失败';

  @override
  String get cannotSwitchWithActiveCase => '案件进行中无法切换页面';
}
