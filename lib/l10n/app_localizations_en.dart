// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Easy Ride';

  @override
  String get appSlogan => 'Fast, Convenient, Safe';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get phone => 'Phone';

  @override
  String get phoneHint => 'Enter phone number';

  @override
  String get phoneError => 'Please enter phone number';

  @override
  String get phoneInvalid => 'Please enter valid phone number';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get passwordError => 'Please enter password';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get phoneLogin => 'Phone Login';

  @override
  String get lineLogin => 'LINE Login';

  @override
  String get appleLogin => 'Apple Login';

  @override
  String get or => 'OR';

  @override
  String get phoneRegister => 'Phone Registration';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get lineLoginFailed => 'LINE login failed';

  @override
  String get appleLoginFailed => 'Apple login failed';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSlogan => 'Join Easy Ride';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHint => 'Enter nickname';

  @override
  String get nicknameError => 'Please enter nickname';

  @override
  String get confirmRegister => 'Confirm Registration';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get backToLogin => 'Already have an account? Back to login';

  @override
  String get callCarPage => 'Call Car';

  @override
  String get profile => 'Profile';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get locationFailed => 'Failed to get location';

  @override
  String get oneClickCallCar => 'One-Click Call';

  @override
  String get calling => 'Calling...';

  @override
  String get findingDriver => 'Finding driver...';

  @override
  String get orderNumber => 'Order No:';

  @override
  String get cancelCallCar => 'Cancel';

  @override
  String get driverOnWay => 'Driver on the way';

  @override
  String get driverOnWayMessage => 'Driver is on the way, please wait';

  @override
  String get driverArrived => 'Waiting for pickup';

  @override
  String get driverArrivedMessage =>
      'Driver has arrived, please board as soon as possible';

  @override
  String get onBoard => 'In progress';

  @override
  String get onBoardMessage => 'Enjoy your ride';

  @override
  String get driverLocation => 'Driver Location';

  @override
  String get callCarFailed => 'Failed to call car';

  @override
  String get tripFinished => 'Trip Completed';

  @override
  String get thankYou => 'Thank you for using our service';

  @override
  String get fare => 'Fare:';

  @override
  String get blacklist => 'Blacklist';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmCancel => 'Confirm Cancel';

  @override
  String get confirmCancelMessage => 'Are you sure you want to cancel?';

  @override
  String get thinkAgain => 'Think again';

  @override
  String get confirmCancelButton => 'Confirm Cancel';

  @override
  String get orderCanceled => 'Order cancelled (no nearby drivers available)';

  @override
  String get orderCancelSuccess => 'Order cancelled successfully';

  @override
  String get orderCancelFailed => 'Failed to cancel order';

  @override
  String get confirmBlacklist => 'Confirm Blacklist';

  @override
  String get confirmBlacklistMessage =>
      'Are you sure you want to blacklist this driver?';

  @override
  String get cancel => 'Cancel';

  @override
  String get blacklistSuccess => 'Added to blacklist';

  @override
  String get blacklistFailed => 'Failed to add to blacklist';

  @override
  String get profileTitle => 'Profile';

  @override
  String get loginMethod => 'Login Method';

  @override
  String phoneLoginMethod(String phone) {
    return 'Phone Login ($phone)';
  }

  @override
  String get lineLoginMethod => 'LINE Login';

  @override
  String get appleLoginMethod => 'Apple Login';

  @override
  String get unknown => 'Unknown';

  @override
  String get rideHistory => 'Ride History';

  @override
  String get rideHistorySubtitle => 'View your ride history';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to logout?';

  @override
  String get loading => 'Loading...';

  @override
  String get loadUserFailed => 'Failed to load user data';

  @override
  String get retry => 'Retry';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently delete your account and all data';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountWarning => '⚠️ Cannot be recovered after deletion';

  @override
  String get deleteAccountInfo1 =>
      '• Your personal data will be permanently deleted';

  @override
  String get deleteAccountInfo2 =>
      '• Historical orders will be retained but no longer linked to your account';

  @override
  String get deleteAccountInfo3 => '• This action cannot be undone';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get lastConfirm => 'Final Confirmation';

  @override
  String get lastConfirmMessage =>
      'This action cannot be undone!\n\nAre you sure you want to permanently delete your account?';

  @override
  String get confirmDeleteForever => 'Confirm, Delete Forever';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get accountDeleteFailed => 'Failed to delete account';

  @override
  String get rideHistoryTitle => 'Ride History';

  @override
  String get noRideHistory => 'No ride history';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get chatTitle => 'Chat';

  @override
  String get startConversation => 'Start conversation';

  @override
  String get messageHint => 'Type a message...';

  @override
  String get messageMissing => 'Missing order ID';

  @override
  String get pleaseLogin => 'Please login first';

  @override
  String get chatInitFailed => 'Failed to initialize chat';

  @override
  String get loadMessagesFailed => 'Failed to load messages';

  @override
  String get sendFailed => 'Failed to send';
}
