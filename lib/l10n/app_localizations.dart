import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('az'),
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DriverCheck'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login. Please check your email and password.'**
  String get loginError;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @viewActivity.
  ///
  /// In en, this message translates to:
  /// **'View Activity History'**
  String get viewActivity;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePhone.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhone;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeWelcome;

  /// No description provided for @taxiCompany.
  ///
  /// In en, this message translates to:
  /// **'Taxi company'**
  String get taxiCompany;

  /// No description provided for @searchDriver.
  ///
  /// In en, this message translates to:
  /// **'Search driver'**
  String get searchDriver;

  /// No description provided for @addDriver.
  ///
  /// In en, this message translates to:
  /// **'Add new driver'**
  String get addDriver;

  /// No description provided for @driverList.
  ///
  /// In en, this message translates to:
  /// **'Driver list'**
  String get driverList;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile / Settings'**
  String get profileSettings;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Driver'**
  String get searchTitle;

  /// No description provided for @searchByPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get searchByPhone;

  /// No description provided for @searchByLicense.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get searchByLicense;

  /// No description provided for @searchByFin.
  ///
  /// In en, this message translates to:
  /// **'FIN code'**
  String get searchByFin;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @enterLicense.
  ///
  /// In en, this message translates to:
  /// **'Enter license number'**
  String get enterLicense;

  /// No description provided for @enterFin.
  ///
  /// In en, this message translates to:
  /// **'Enter FIN code'**
  String get enterFin;

  /// No description provided for @enterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get enterValue;

  /// No description provided for @searchType.
  ///
  /// In en, this message translates to:
  /// **'Search type'**
  String get searchType;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @driverInfo.
  ///
  /// In en, this message translates to:
  /// **'Driver Information'**
  String get driverInfo;

  /// No description provided for @workplaces.
  ///
  /// In en, this message translates to:
  /// **'Workplaces'**
  String get workplaces;

  /// No description provided for @ownerInfo.
  ///
  /// In en, this message translates to:
  /// **'Owner Information'**
  String get ownerInfo;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @fin.
  ///
  /// In en, this message translates to:
  /// **'FIN'**
  String get fin;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusProblem.
  ///
  /// In en, this message translates to:
  /// **'Problematic (has debt)'**
  String get statusProblem;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @fleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get fleet;

  /// No description provided for @addedDate.
  ///
  /// In en, this message translates to:
  /// **'Added on'**
  String get addedDate;

  /// No description provided for @someKey.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get someKey;

  /// No description provided for @addDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'New Problematic Driver'**
  String get addDriverTitle;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @addDriverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Driver added successfully'**
  String get addDriverSuccess;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload or take photo'**
  String get uploadPhoto;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get fromGallery;

  /// No description provided for @fromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get fromCamera;

  /// No description provided for @problematic.
  ///
  /// In en, this message translates to:
  /// **'Problematic'**
  String get problematic;

  /// No description provided for @notProblematic.
  ///
  /// In en, this message translates to:
  /// **'Not problematic'**
  String get notProblematic;

  /// No description provided for @reasonDebt.
  ///
  /// In en, this message translates to:
  /// **'Has debt'**
  String get reasonDebt;

  /// No description provided for @reasonAccident.
  ///
  /// In en, this message translates to:
  /// **'Crashed the car'**
  String get reasonAccident;

  /// No description provided for @reasonPenalty.
  ///
  /// In en, this message translates to:
  /// **'Left fines'**
  String get reasonPenalty;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @driverListTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver List'**
  String get driverListTitle;

  /// No description provided for @nameSurname.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameSurname;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @driverDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Details'**
  String get driverDetailTitle;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License No.'**
  String get license;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @personalSettings.
  ///
  /// In en, this message translates to:
  /// **'Personal Settings'**
  String get personalSettings;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Appearance and Language'**
  String get appearanceAndLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeOn.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode enabled'**
  String get darkModeOn;

  /// No description provided for @darkModeOff.
  ///
  /// In en, this message translates to:
  /// **'Light Mode enabled'**
  String get darkModeOff;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @helpAndContact.
  ///
  /// In en, this message translates to:
  /// **'Help and Contact'**
  String get helpAndContact;

  /// No description provided for @contactNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Contact feature is not available yet.'**
  String get contactNotAvailable;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @parkName.
  ///
  /// In en, this message translates to:
  /// **'Park / Fleet Name'**
  String get parkName;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @driverAdded.
  ///
  /// In en, this message translates to:
  /// **'New driver added: {name}'**
  String driverAdded(Object name);

  /// No description provided for @statusChanged.
  ///
  /// In en, this message translates to:
  /// **'Driver status changed: {name}'**
  String statusChanged(Object name);

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out of the app'**
  String get loggedOut;

  /// No description provided for @loggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged in'**
  String get loggedIn;

  /// No description provided for @currentPhone.
  ///
  /// In en, this message translates to:
  /// **'Current phone'**
  String get currentPhone;

  /// No description provided for @newPhone.
  ///
  /// In en, this message translates to:
  /// **'New phone'**
  String get newPhone;

  /// No description provided for @confirmNewPhone.
  ///
  /// In en, this message translates to:
  /// **'Confirm new phone'**
  String get confirmNewPhone;

  /// No description provided for @phoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated'**
  String get phoneUpdated;

  /// No description provided for @phoneMismatch.
  ///
  /// In en, this message translates to:
  /// **'New phone numbers do not match'**
  String get phoneMismatch;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @uploadIdCard.
  ///
  /// In en, this message translates to:
  /// **'Upload your ID card photo'**
  String get uploadIdCard;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Registration complete'**
  String get registrationComplete;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get enterPhoneNumber;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent to number'**
  String get codeSent;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get fillRequiredFields;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email has been sent.'**
  String get verificationEmailSent;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorOccurred;

  /// No description provided for @forgotPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to reset your password.'**
  String get forgotPasswordInstruction;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to your email.'**
  String get passwordResetSent;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @uploadProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload profile photo'**
  String get uploadProfilePhoto;

  /// No description provided for @noActivityFound.
  ///
  /// In en, this message translates to:
  /// **'No activity found'**
  String get noActivityFound;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s name'**
  String get fatherName;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @activityPlaces.
  ///
  /// In en, this message translates to:
  /// **'Activity Places'**
  String get activityPlaces;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for the edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Message shown when editing is not yet available
  ///
  /// In en, this message translates to:
  /// **'Editing functionality is not implemented yet.'**
  String get editingNotImplemented;

  /// Title for the edit driver screen
  ///
  /// In en, this message translates to:
  /// **'Edit Driver'**
  String get editDriver;

  /// Shown when status is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a status.'**
  String get statusRequired;

  /// Shown when reason is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a reason.'**
  String get reasonRequired;

  /// Shown when no driver matches the search
  ///
  /// In en, this message translates to:
  /// **'No drivers found'**
  String get noDriversFound;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the chat page!'**
  String get chatWelcome;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['az', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'az': return AppLocalizationsAz();
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
