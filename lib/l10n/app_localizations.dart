import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Tap Ride'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Fast, Convenient, Safe'**
  String get appSlogan;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneHint;

  /// No description provided for @phoneError.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get phoneError;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid phone number'**
  String get phoneInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordHint;

  /// No description provided for @passwordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get passwordError;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLength;

  /// No description provided for @phoneLogin.
  ///
  /// In en, this message translates to:
  /// **'Phone Login'**
  String get phoneLogin;

  /// No description provided for @lineLogin.
  ///
  /// In en, this message translates to:
  /// **'LINE Login'**
  String get lineLogin;

  /// No description provided for @appleLogin.
  ///
  /// In en, this message translates to:
  /// **'Apple Login'**
  String get appleLogin;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @phoneRegister.
  ///
  /// In en, this message translates to:
  /// **'Phone Registration'**
  String get phoneRegister;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @lineLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'LINE login failed'**
  String get lineLoginFailed;

  /// No description provided for @appleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple login failed'**
  String get appleLoginFailed;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerSlogan.
  ///
  /// In en, this message translates to:
  /// **'Join Tap Ride'**
  String get registerSlogan;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get nicknameHint;

  /// No description provided for @nicknameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter nickname'**
  String get nicknameError;

  /// No description provided for @confirmRegister.
  ///
  /// In en, this message translates to:
  /// **'Confirm Registration'**
  String get confirmRegister;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Back to login'**
  String get backToLogin;

  /// No description provided for @callCarPage.
  ///
  /// In en, this message translates to:
  /// **'Call Car'**
  String get callCarPage;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location'**
  String get locationFailed;

  /// No description provided for @oneClickCallCar.
  ///
  /// In en, this message translates to:
  /// **'One-Click Call'**
  String get oneClickCallCar;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get calling;

  /// No description provided for @findingDriver.
  ///
  /// In en, this message translates to:
  /// **'Finding driver...'**
  String get findingDriver;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order No:'**
  String get orderNumber;

  /// No description provided for @cancelCallCar.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelCallCar;

  /// No description provided for @driverOnWay.
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get driverOnWay;

  /// No description provided for @driverOnWayMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way, please wait'**
  String get driverOnWayMessage;

  /// No description provided for @driverArrived.
  ///
  /// In en, this message translates to:
  /// **'Waiting for pickup'**
  String get driverArrived;

  /// No description provided for @driverArrivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived, please board as soon as possible'**
  String get driverArrivedMessage;

  /// No description provided for @onBoard.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get onBoard;

  /// No description provided for @onBoardMessage.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your ride'**
  String get onBoardMessage;

  /// No description provided for @driverLocation.
  ///
  /// In en, this message translates to:
  /// **'Driver Location'**
  String get driverLocation;

  /// No description provided for @callCarFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to call car'**
  String get callCarFailed;

  /// No description provided for @tripFinished.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed'**
  String get tripFinished;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using our service'**
  String get thankYou;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare:'**
  String get fare;

  /// No description provided for @blacklist.
  ///
  /// In en, this message translates to:
  /// **'Blacklist'**
  String get blacklist;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel'**
  String get confirmCancel;

  /// No description provided for @confirmCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel?'**
  String get confirmCancelMessage;

  /// No description provided for @thinkAgain.
  ///
  /// In en, this message translates to:
  /// **'Think again'**
  String get thinkAgain;

  /// No description provided for @confirmCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel'**
  String get confirmCancelButton;

  /// No description provided for @orderCanceled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCanceled;

  /// No description provided for @orderCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get orderCancelSuccess;

  /// No description provided for @orderCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel order'**
  String get orderCancelFailed;

  /// No description provided for @confirmBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Confirm Blacklist'**
  String get confirmBlacklist;

  /// No description provided for @confirmBlacklistMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to blacklist this driver?'**
  String get confirmBlacklistMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @blacklistSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added to blacklist'**
  String get blacklistSuccess;

  /// No description provided for @blacklistFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to blacklist'**
  String get blacklistFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @loginMethod.
  ///
  /// In en, this message translates to:
  /// **'Login Method'**
  String get loginMethod;

  /// No description provided for @phoneLoginMethod.
  ///
  /// In en, this message translates to:
  /// **'Phone Login ({phone})'**
  String phoneLoginMethod(String phone);

  /// No description provided for @lineLoginMethod.
  ///
  /// In en, this message translates to:
  /// **'LINE Login'**
  String get lineLoginMethod;

  /// No description provided for @appleLoginMethod.
  ///
  /// In en, this message translates to:
  /// **'Apple Login'**
  String get appleLoginMethod;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// No description provided for @rideHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your ride history'**
  String get rideHistorySubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogoutMessage;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadUserFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user data'**
  String get loadUserFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Cannot be recovered after deletion'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountInfo1.
  ///
  /// In en, this message translates to:
  /// **'• Your personal data will be permanently deleted'**
  String get deleteAccountInfo1;

  /// No description provided for @deleteAccountInfo2.
  ///
  /// In en, this message translates to:
  /// **'• Historical orders will be retained but no longer linked to your account'**
  String get deleteAccountInfo2;

  /// No description provided for @deleteAccountInfo3.
  ///
  /// In en, this message translates to:
  /// **'• This action cannot be undone'**
  String get deleteAccountInfo3;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @lastConfirm.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get lastConfirm;

  /// No description provided for @lastConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone!\n\nAre you sure you want to permanently delete your account?'**
  String get lastConfirmMessage;

  /// No description provided for @confirmDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Confirm, Delete Forever'**
  String get confirmDeleteForever;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted;

  /// No description provided for @accountDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get accountDeleteFailed;

  /// No description provided for @rideHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistoryTitle;

  /// No description provided for @noRideHistory.
  ///
  /// In en, this message translates to:
  /// **'No ride history'**
  String get noRideHistory;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start conversation'**
  String get startConversation;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messageHint;

  /// No description provided for @messageMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing order ID'**
  String get messageMissing;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get pleaseLogin;

  /// No description provided for @chatInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize chat'**
  String get chatInitFailed;

  /// No description provided for @loadMessagesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get loadMessagesFailed;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send'**
  String get sendFailed;

  /// No description provided for @cannotSwitchWithActiveCase.
  ///
  /// In en, this message translates to:
  /// **'Cannot switch tabs while a trip is in progress'**
  String get cannotSwitchWithActiveCase;

  /// No description provided for @driverExpectedArrival.
  ///
  /// In en, this message translates to:
  /// **'Driver expected to arrive in {timeRange}'**
  String driverExpectedArrival(String timeRange);

  /// No description provided for @driverExpectedArrivalNote.
  ///
  /// In en, this message translates to:
  /// **'(Note: This is the initial time, please pay close attention to the driver\'s location)'**
  String get driverExpectedArrivalNote;

  /// No description provided for @orderCanceledByDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver waited more than 3 minutes, order has been canceled'**
  String get orderCanceledByDriver;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
