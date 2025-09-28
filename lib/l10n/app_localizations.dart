import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign in with'**
  String get orSignInWith;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @consentWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Lifeline'**
  String get consentWelcomeTitle;

  /// No description provided for @consentWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Before you begin, please review and agree to our terms.'**
  String get consentWelcomeSubtitle;

  /// No description provided for @consentIAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get consentIAgreeTo;

  /// No description provided for @consentTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get consentTermsOfService;

  /// No description provided for @consentAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get consentAnd;

  /// No description provided for @consentPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get consentPrivacyPolicy;

  /// No description provided for @consentContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get consentContinue;

  /// No description provided for @consentErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings: {error}'**
  String consentErrorSaving(String error);

  /// No description provided for @splashMessageInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get splashMessageInitializing;

  /// No description provided for @splashMessageCheckingSettings.
  ///
  /// In en, this message translates to:
  /// **'Checking settings...'**
  String get splashMessageCheckingSettings;

  /// No description provided for @splashMessageAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get splashMessageAuthenticating;

  /// No description provided for @splashMessageSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing your timeline...'**
  String get splashMessageSyncing;

  /// No description provided for @authGateLoadingMemories.
  ///
  /// In en, this message translates to:
  /// **'Loading memories...'**
  String get authGateLoadingMemories;

  /// No description provided for @authGateAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get authGateAuthenticating;

  /// No description provided for @authGateSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get authGateSomethingWentWrong;

  /// No description provided for @authGateCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your data. Please check your connection and try again.'**
  String get authGateCouldNotLoad;

  /// No description provided for @authGateTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get authGateTryAgain;

  /// No description provided for @authGateEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Your Lifeline is ready.\nTap the + button to add your first memory.'**
  String get authGateEmptyState;

  /// No description provided for @authGateUnsavedDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Memory'**
  String get authGateUnsavedDraftTitle;

  /// No description provided for @authGateUnsavedDraftContent.
  ///
  /// In en, this message translates to:
  /// **'You have an unsaved memory draft. Do you want to continue editing it?'**
  String get authGateUnsavedDraftContent;

  /// No description provided for @authGateDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get authGateDiscard;

  /// No description provided for @authGateContinueEditing.
  ///
  /// In en, this message translates to:
  /// **'Continue Editing'**
  String get authGateContinueEditing;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to:'**
  String get verifyEmailSentTo;

  /// No description provided for @verifyEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please click the link in the email to complete your registration.'**
  String get verifyEmailInstructions;

  /// No description provided for @verifyEmailResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get verifyEmailResendButton;

  /// No description provided for @verifyEmailCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get verifyEmailCancelButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileTitle;

  /// No description provided for @profileSectionProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileSectionProfile;

  /// No description provided for @profileChangeNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get profileChangeNameTitle;

  /// No description provided for @profileEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profileEnterYourName;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profileCountry;

  /// No description provided for @profileCountryNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get profileCountryNotSelected;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Content Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageDefault.
  ///
  /// In en, this message translates to:
  /// **'English (Default)'**
  String get profileLanguageDefault;

  /// No description provided for @profileSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get profileSelectLanguage;

  /// No description provided for @profileSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get profileSectionSettings;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileTheme;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileReauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication Required'**
  String get profileReauthTitle;

  /// No description provided for @profileReauthContent.
  ///
  /// In en, this message translates to:
  /// **'This is a sensitive operation. Please sign in again before proceeding.'**
  String get profileReauthContent;

  /// No description provided for @profileReauthButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In & Delete'**
  String get profileReauthButton;

  /// No description provided for @profileReauthPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get profileReauthPasswordDialogTitle;

  /// No description provided for @profileReauthPasswordDialogContent.
  ///
  /// In en, this message translates to:
  /// **'To delete your account, please enter your current password.'**
  String get profileReauthPasswordDialogContent;

  /// No description provided for @profilePasswordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get profilePasswordCannotBeEmpty;

  /// No description provided for @profileChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Master password changed successfully!'**
  String get profileChangePasswordSuccess;

  /// No description provided for @profileChangePasswordErrorIncorrect.
  ///
  /// In en, this message translates to:
  /// **'The current password you entered is incorrect.'**
  String get profileChangePasswordErrorIncorrect;

  /// No description provided for @profileOldPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get profileOldPasswordHint;

  /// No description provided for @profileNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get profileNewPasswordHint;

  /// No description provided for @profileDeleteAccountConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. Your entire account, including all memories and settings, will be permanently deleted. To proceed, press and hold the delete button for 5 seconds.'**
  String get profileDeleteAccountConfirmContent;

  /// No description provided for @profileChangePasswordCurrentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Current Master Password'**
  String get profileChangePasswordCurrentPasswordHint;

  /// No description provided for @profileChangePasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New Master Password'**
  String get profileChangePasswordNewPasswordHint;

  /// No description provided for @profileChangePasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current master password to set a new one. This will re-encrypt your secret key.'**
  String get profileChangePasswordInfo;

  /// No description provided for @profileGraphics.
  ///
  /// In en, this message translates to:
  /// **'Graphics Quality'**
  String get profileGraphics;

  /// No description provided for @profileGraphicsAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get profileGraphicsAuto;

  /// No description provided for @profileGraphicsLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get profileGraphicsLow;

  /// No description provided for @profileGraphicsMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get profileGraphicsMedium;

  /// No description provided for @profileGraphicsHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get profileGraphicsHigh;

  /// No description provided for @profileReminders.
  ///
  /// In en, this message translates to:
  /// **'Reflection Reminders'**
  String get profileReminders;

  /// No description provided for @profileRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for your action plans'**
  String get profileRemindersSubtitle;

  /// No description provided for @profileSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get profileSectionSecurity;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Master Password'**
  String get profileChangePassword;

  /// No description provided for @profileEncryptionActive.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption is active'**
  String get profileEncryptionActive;

  /// No description provided for @profileEnableEncryption.
  ///
  /// In en, this message translates to:
  /// **'Enable End-to-End Encryption'**
  String get profileEnableEncryption;

  /// No description provided for @profileEnableEncryptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your sensitive memories with a master password.'**
  String get profileEnableEncryptionSubtitle;

  /// No description provided for @profileCreateMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Master Password'**
  String get profileCreateMasterPassword;

  /// No description provided for @profileMasterPasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'This password will protect your memories. It cannot be recovered if you forget it. Please store it safely.'**
  String get profileMasterPasswordInfo;

  /// No description provided for @profileMasterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get profileMasterPasswordHint;

  /// No description provided for @profileConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get profileConfirmPasswordHint;

  /// No description provided for @profilePasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get profilePasswordMinLength;

  /// No description provided for @profilePasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get profilePasswordsDoNotMatch;

  /// No description provided for @profileEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get profileEnable;

  /// No description provided for @profileSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'HELP'**
  String get profileSectionHelp;

  /// No description provided for @profileReplayTutorial.
  ///
  /// In en, this message translates to:
  /// **'Replay Tutorial'**
  String get profileReplayTutorial;

  /// No description provided for @profileReplayTutorialConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay Tutorial?'**
  String get profileReplayTutorialConfirmTitle;

  /// No description provided for @profileReplayTutorialConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart the tutorial?'**
  String get profileReplayTutorialConfirmContent;

  /// No description provided for @profileRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get profileRestart;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT MANAGEMENT'**
  String get profileSectionAccount;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get profileDeleteAccountConfirmTitle;

  /// No description provided for @profileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDelete;

  /// No description provided for @profileDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account...'**
  String get profileDeletingAccount;

  /// No description provided for @profileErrorCouldNotFindProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not find user profile.'**
  String get profileErrorCouldNotFindProfile;

  /// No description provided for @memoryEditNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Memory'**
  String get memoryEditNewTitle;

  /// No description provided for @memoryEditEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Memory'**
  String get memoryEditEditTitle;

  /// No description provided for @memoryEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get memoryEditSave;

  /// No description provided for @memoryEditTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get memoryEditTitleHint;

  /// No description provided for @memoryEditTitleValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get memoryEditTitleValidator;

  /// No description provided for @memoryEditDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get memoryEditDescriptionHint;

  /// No description provided for @memoryEditDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get memoryEditDateLabel;

  /// No description provided for @memoryEditSelectDateButton.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get memoryEditSelectDateButton;

  /// No description provided for @memoryEditAmbientSoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Ambient Sound:'**
  String get memoryEditAmbientSoundLabel;

  /// No description provided for @memoryEditAmbientSoundDropdownHint.
  ///
  /// In en, this message translates to:
  /// **'Select an ambient sound'**
  String get memoryEditAmbientSoundDropdownHint;

  /// No description provided for @memoryEditMusicAnchorLabel.
  ///
  /// In en, this message translates to:
  /// **'Music Anchor:'**
  String get memoryEditMusicAnchorLabel;

  /// No description provided for @memoryEditAttachTrackButton.
  ///
  /// In en, this message translates to:
  /// **'Attach track from Spotify'**
  String get memoryEditAttachTrackButton;

  /// No description provided for @memoryEditPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos:'**
  String get memoryEditPhotosLabel;

  /// No description provided for @memoryEditNoPhotosSelected.
  ///
  /// In en, this message translates to:
  /// **'No photos selected'**
  String get memoryEditNoPhotosSelected;

  /// No description provided for @memoryEditAddPhotosButton.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get memoryEditAddPhotosButton;

  /// No description provided for @memoryEditVideosLabel.
  ///
  /// In en, this message translates to:
  /// **'Videos:'**
  String get memoryEditVideosLabel;

  /// No description provided for @memoryEditNoVideosSelected.
  ///
  /// In en, this message translates to:
  /// **'No videos selected'**
  String get memoryEditNoVideosSelected;

  /// No description provided for @memoryEditAddVideoButton.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get memoryEditAddVideoButton;

  /// No description provided for @memoryEditAudioNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio Note:'**
  String get memoryEditAudioNoteLabel;

  /// No description provided for @memoryEditAudioNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Audio note saved'**
  String get memoryEditAudioNoteSaved;

  /// No description provided for @memoryEditRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get memoryEditRecordButton;

  /// No description provided for @memoryEditStopRecordingButton.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get memoryEditStopRecordingButton;

  /// No description provided for @memoryEditRecordingIndicator.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get memoryEditRecordingIndicator;

  /// No description provided for @memoryEditReflectionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get memoryEditReflectionSectionTitle;

  /// No description provided for @memoryEditEncryptLabel.
  ///
  /// In en, this message translates to:
  /// **'Encrypt'**
  String get memoryEditEncryptLabel;

  /// No description provided for @memoryEditEncryptionInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'What is encryption?'**
  String get memoryEditEncryptionInfoTooltip;

  /// No description provided for @memoryEditImpactPrompt.
  ///
  /// In en, this message translates to:
  /// **'How did this event impact me?'**
  String get memoryEditImpactPrompt;

  /// No description provided for @memoryEditLessonPrompt.
  ///
  /// In en, this message translates to:
  /// **'What lesson did I learn?'**
  String get memoryEditLessonPrompt;

  /// No description provided for @memoryEditEmotionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotions:'**
  String get memoryEditEmotionsLabel;

  /// No description provided for @emotionJoy.
  ///
  /// In en, this message translates to:
  /// **'Joy'**
  String get emotionJoy;

  /// No description provided for @emotionNostalgia.
  ///
  /// In en, this message translates to:
  /// **'Nostalgia'**
  String get emotionNostalgia;

  /// No description provided for @emotionPride.
  ///
  /// In en, this message translates to:
  /// **'Pride'**
  String get emotionPride;

  /// No description provided for @emotionSadness.
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get emotionSadness;

  /// No description provided for @emotionGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get emotionGratitude;

  /// No description provided for @emotionLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get emotionLove;

  /// No description provided for @emotionFear.
  ///
  /// In en, this message translates to:
  /// **'Fear'**
  String get emotionFear;

  /// No description provided for @emotionAnger.
  ///
  /// In en, this message translates to:
  /// **'Anger'**
  String get emotionAnger;

  /// No description provided for @memoryEditCbtHelperTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection Helper'**
  String get memoryEditCbtHelperTitle;

  /// No description provided for @memoryEditCbtStep1Title.
  ///
  /// In en, this message translates to:
  /// **'What was the first thought or belief?'**
  String get memoryEditCbtStep1Title;

  /// No description provided for @memoryEditCbtStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'e.g., \'I will fail\' or \'I did everything right\'.'**
  String get memoryEditCbtStep1Subtitle;

  /// No description provided for @memoryEditCbtStep2Title.
  ///
  /// In en, this message translates to:
  /// **'What supports this thought?'**
  String get memoryEditCbtStep2Title;

  /// No description provided for @memoryEditCbtStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'What facts or events prove this thought to be true?'**
  String get memoryEditCbtStep2Subtitle;

  /// No description provided for @memoryEditCbtStep3Title.
  ///
  /// In en, this message translates to:
  /// **'What is the view from the other side?'**
  String get memoryEditCbtStep3Title;

  /// No description provided for @memoryEditCbtStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'What facts or events might disprove or challenge the first thought?'**
  String get memoryEditCbtStep3Subtitle;

  /// No description provided for @memoryEditCbtStep4Title.
  ///
  /// In en, this message translates to:
  /// **'How can I look at this differently?'**
  String get memoryEditCbtStep4Title;

  /// No description provided for @memoryEditCbtStep4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on the above, formulate a new, more balanced perspective.'**
  String get memoryEditCbtStep4Subtitle;

  /// No description provided for @memoryEditActionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Action Plan'**
  String get memoryEditActionPlanTitle;

  /// No description provided for @memoryEditActionPrompt.
  ///
  /// In en, this message translates to:
  /// **'What is one small step I can take?'**
  String get memoryEditActionPrompt;

  /// No description provided for @memoryEditReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder:'**
  String get memoryEditReminderLabel;

  /// No description provided for @memoryEditReminderNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get memoryEditReminderNotSet;

  /// No description provided for @memoryEditSetReminderButton.
  ///
  /// In en, this message translates to:
  /// **'Set Date'**
  String get memoryEditSetReminderButton;

  /// No description provided for @memoryEditYourThoughtsHint.
  ///
  /// In en, this message translates to:
  /// **'Your thoughts here...'**
  String get memoryEditYourThoughtsHint;

  /// No description provided for @memoryEditDraftSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get memoryEditDraftSavedMessage;

  /// No description provided for @memoryEditErrorRepoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Error: Repository not available.'**
  String get memoryEditErrorRepoUnavailable;

  /// No description provided for @memoryEditErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving memory: {error}'**
  String memoryEditErrorSaving(String error);

  /// No description provided for @memoryEditUnlockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock to Save'**
  String get memoryEditUnlockDialogTitle;

  /// No description provided for @memoryEditUnlockDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Master Password to save this encrypted memory.'**
  String get memoryEditUnlockDialogContent;

  /// No description provided for @memoryEditMasterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get memoryEditMasterPasswordHint;

  /// No description provided for @memoryEditUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get memoryEditUnlockButton;

  /// No description provided for @memoryEditEncryptionInfoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'End-to-End Encryption'**
  String get memoryEditEncryptionInfoDialogTitle;

  /// No description provided for @memoryEditEncryptionInfoDialogContent.
  ///
  /// In en, this message translates to:
  /// **'When you encrypt a memory, its description and reflection fields are scrambled using a key derived from your Master Password.\n\nThe data is stored in an unreadable format in the cloud and can only be decrypted on your devices with your password.\n\nIMPORTANT: We cannot recover your Master Password. If you forget it, your encrypted data will be lost forever.'**
  String get memoryEditEncryptionInfoDialogContent;

  /// No description provided for @memoryEditOkButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get memoryEditOkButton;

  /// No description provided for @memoryEditPermissionDeniedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Permission for {permissionName} was denied. Please enable it in settings.'**
  String memoryEditPermissionDeniedSnackbar(String permissionName);

  /// No description provided for @memoryEditSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get memoryEditSettingsButton;

  /// No description provided for @memoryEditNoInternetSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Internet connection is required to search for music.'**
  String get memoryEditNoInternetSnackbar;

  /// No description provided for @memoryEditEmotionIntensityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensity for \'{emotion}\''**
  String memoryEditEmotionIntensityDialogTitle(String emotion);

  /// No description provided for @memoryViewBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get memoryViewBackTooltip;

  /// No description provided for @memoryViewShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get memoryViewShareTooltip;

  /// No description provided for @memoryViewEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get memoryViewEditTooltip;

  /// No description provided for @memoryViewDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get memoryViewDeleteTooltip;

  /// No description provided for @memoryViewTabMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memoryViewTabMemory;

  /// No description provided for @memoryViewTabInTheWorld.
  ///
  /// In en, this message translates to:
  /// **'In the World'**
  String get memoryViewTabInTheWorld;

  /// No description provided for @memoryViewEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Memory'**
  String get memoryViewEncryptedTitle;

  /// No description provided for @memoryViewReflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get memoryViewReflectionTitle;

  /// No description provided for @memoryViewReflectionImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get memoryViewReflectionImpact;

  /// No description provided for @memoryViewReflectionLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson Learned'**
  String get memoryViewReflectionLesson;

  /// No description provided for @memoryViewCbtStep1Title.
  ///
  /// In en, this message translates to:
  /// **'First Thought or Belief'**
  String get memoryViewCbtStep1Title;

  /// No description provided for @memoryViewCbtStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Evidence For This Thought'**
  String get memoryViewCbtStep2Title;

  /// No description provided for @memoryViewCbtStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Evidence Against This Thought'**
  String get memoryViewCbtStep3Title;

  /// No description provided for @memoryViewCbtStep4Title.
  ///
  /// In en, this message translates to:
  /// **'New, Balanced Perspective (Reframe)'**
  String get memoryViewCbtStep4Title;

  /// No description provided for @memoryViewActionReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {date}'**
  String memoryViewActionReminder(String date);

  /// No description provided for @memoryViewMarkIncompleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark as incomplete'**
  String get memoryViewMarkIncompleteTooltip;

  /// No description provided for @memoryViewMarkCompleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get memoryViewMarkCompleteTooltip;

  /// No description provided for @memoryViewUnlockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Memory'**
  String get memoryViewUnlockDialogTitle;

  /// No description provided for @memoryViewUnlockDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your Master Password to view this content.'**
  String get memoryViewUnlockDialogContent;

  /// No description provided for @memoryViewIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get memoryViewIncorrectPassword;

  /// No description provided for @memoryViewUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get memoryViewUnlockButton;

  /// No description provided for @memoryViewErrorCouldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile to fetch historical data.'**
  String get memoryViewErrorCouldNotLoadProfile;

  /// No description provided for @memoryViewErrorCouldNotLoadHistoricalData.
  ///
  /// In en, this message translates to:
  /// **'Could not load historical data for this day.'**
  String get memoryViewErrorCouldNotLoadHistoricalData;

  /// No description provided for @memoryViewNoHistoricalData.
  ///
  /// In en, this message translates to:
  /// **'No historical data available for this day.'**
  String get memoryViewNoHistoricalData;

  /// No description provided for @memoryViewErrorCouldNotLoadTrack.
  ///
  /// In en, this message translates to:
  /// **'Could not load track'**
  String get memoryViewErrorCouldNotLoadTrack;

  /// No description provided for @memoryViewTabNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get memoryViewTabNews;

  /// No description provided for @memoryViewTabMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get memoryViewTabMusic;

  /// No description provided for @memoryViewNoDataForDay.
  ///
  /// In en, this message translates to:
  /// **'No data for this day.'**
  String get memoryViewNoDataForDay;

  /// No description provided for @memoryViewNoNewsForDay.
  ///
  /// In en, this message translates to:
  /// **'No historical news for this day.'**
  String get memoryViewNoNewsForDay;

  /// No description provided for @memoryViewNewsSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String memoryViewNewsSource(String source);

  /// No description provided for @memoryViewConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get memoryViewConfirmDeleteTitle;

  /// No description provided for @memoryViewConfirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. To proceed, press and hold the delete button for 5 seconds.'**
  String get memoryViewConfirmDeleteContent;

  /// No description provided for @memoryViewDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get memoryViewDeleteButton;

  /// No description provided for @memoryViewErrorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your profile. Please check your connection and try again.'**
  String get memoryViewErrorLoadingProfile;

  /// No description provided for @memoryViewErrorLocalDb.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not access local database.'**
  String get memoryViewErrorLocalDb;

  /// No description provided for @memoryViewMemoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Memory deleted'**
  String get memoryViewMemoryDeleted;

  /// No description provided for @memoryViewSharingNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Sharing functionality not yet implemented.'**
  String get memoryViewSharingNotImplemented;

  /// No description provided for @memoryViewActionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Action marked as complete!'**
  String get memoryViewActionCompleted;

  /// No description provided for @memoryViewActionIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Action marked as incomplete.'**
  String get memoryViewActionIncomplete;

  /// No description provided for @memoryViewErrorUpdatingAction.
  ///
  /// In en, this message translates to:
  /// **'Error updating action: {error}'**
  String memoryViewErrorUpdatingAction(String error);

  /// No description provided for @memoryViewContentEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Content is Encrypted'**
  String get memoryViewContentEncrypted;

  /// No description provided for @memoryViewReflectionEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Reflection is Encrypted'**
  String get memoryViewReflectionEncrypted;

  /// No description provided for @memoryViewMediaEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Media is Encrypted'**
  String get memoryViewMediaEncrypted;

  /// No description provided for @memoryViewAmbientSound.
  ///
  /// In en, this message translates to:
  /// **'Ambient Sound: {sound}'**
  String memoryViewAmbientSound(String sound);

  /// No description provided for @memoryViewAudioNote.
  ///
  /// In en, this message translates to:
  /// **'Audio Note'**
  String get memoryViewAudioNote;

  /// No description provided for @spotifySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Spotify Track'**
  String get spotifySearchTitle;

  /// No description provided for @spotifySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Song title or artist'**
  String get spotifySearchHint;

  /// No description provided for @documentErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Could not load document.'**
  String get documentErrorLoading;

  /// No description provided for @lifelineMemoriesCount.
  ///
  /// In en, this message translates to:
  /// **'Memories: {count}'**
  String lifelineMemoriesCount(int count);

  /// No description provided for @lifelinePeriodRange.
  ///
  /// In en, this message translates to:
  /// **'Period: {startYear} - {endYear}'**
  String lifelinePeriodRange(int startYear, int endYear);

  /// No description provided for @lifelineSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'{status} ({jobs} left)'**
  String lifelineSyncStatus(String status, int jobs);

  /// No description provided for @lifelineCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get lifelineCalculating;

  /// No description provided for @lifelineScaleValue.
  ///
  /// In en, this message translates to:
  /// **'Scale: {scale}%'**
  String lifelineScaleValue(int scale);

  /// No description provided for @lifelineFpsValue.
  ///
  /// In en, this message translates to:
  /// **'FPS: {fps}'**
  String lifelineFpsValue(String fps);

  /// No description provided for @lifelineFramePaintValue.
  ///
  /// In en, this message translates to:
  /// **'Frame Paint: {ms} ms'**
  String lifelineFramePaintValue(int ms);

  /// No description provided for @lifelineShowFullTimelineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show full timeline'**
  String get lifelineShowFullTimelineTooltip;

  /// No description provided for @lifelineVisualSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Visual settings'**
  String get lifelineVisualSettingsTooltip;

  /// No description provided for @lifelineMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get lifelineMenuProfile;

  /// No description provided for @lifelineMenuDebugOn.
  ///
  /// In en, this message translates to:
  /// **'Debug On'**
  String get lifelineMenuDebugOn;

  /// No description provided for @lifelineMenuDebugOff.
  ///
  /// In en, this message translates to:
  /// **'Debug Off'**
  String get lifelineMenuDebugOff;

  /// No description provided for @lifelineMenuSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get lifelineMenuSignOut;

  /// No description provided for @lifelineSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get lifelineSearchHint;

  /// No description provided for @lifelineMemoriesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get lifelineMemoriesListTitle;

  /// No description provided for @lifelineVisualSettingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Settings'**
  String get lifelineVisualSettingsDialogTitle;

  /// No description provided for @lifelineVisualSettingsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get lifelineVisualSettingsSpeed;

  /// No description provided for @lifelineVisualSettingsAmplitude.
  ///
  /// In en, this message translates to:
  /// **'Amplitude'**
  String get lifelineVisualSettingsAmplitude;

  /// No description provided for @lifelineVisualSettingsYearLine.
  ///
  /// In en, this message translates to:
  /// **'Year Line Position'**
  String get lifelineVisualSettingsYearLine;

  /// No description provided for @lifelineVisualSettingsBranchDensity.
  ///
  /// In en, this message translates to:
  /// **'Branch Density'**
  String get lifelineVisualSettingsBranchDensity;

  /// No description provided for @lifelineVisualSettingsBranchIntensity.
  ///
  /// In en, this message translates to:
  /// **'Branch Intensity'**
  String get lifelineVisualSettingsBranchIntensity;

  /// No description provided for @lifelineVisualSettingsAnimate.
  ///
  /// In en, this message translates to:
  /// **'Animate'**
  String get lifelineVisualSettingsAnimate;

  /// No description provided for @lifelineVisualSettingsDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get lifelineVisualSettingsDoneButton;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Lifeline'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal journey, visualized. Let\'s take a quick tour to see how you can begin capturing your moments.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingBeginTourButton.
  ///
  /// In en, this message translates to:
  /// **'Begin Tour'**
  String get onboardingBeginTourButton;

  /// No description provided for @onboardingGesturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigate Your Timeline'**
  String get onboardingGesturesTitle;

  /// No description provided for @onboardingGestureSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get onboardingGestureSwipe;

  /// No description provided for @onboardingGesturePinch.
  ///
  /// In en, this message translates to:
  /// **'Pinch to Zoom'**
  String get onboardingGesturePinch;

  /// No description provided for @onboardingGesturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Lifeline will grow with you. Pinch to zoom out and see the bigger picture. Swipe left and right to navigate through time.'**
  String get onboardingGesturesSubtitle;

  /// No description provided for @onboardingContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinueButton;

  /// No description provided for @onboardingFinalTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingFinalTitle;

  /// No description provided for @onboardingFinalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey begins now. Start capturing the moments that matter.'**
  String get onboardingFinalSubtitle;

  /// No description provided for @onboardingStartJourneyButton.
  ///
  /// In en, this message translates to:
  /// **'Start My Journey'**
  String get onboardingStartJourneyButton;

  /// No description provided for @onboardingSkipTourButton.
  ///
  /// In en, this message translates to:
  /// **'Skip Tour'**
  String get onboardingSkipTourButton;

  /// No description provided for @onboardingLifelineIntroText.
  ///
  /// In en, this message translates to:
  /// **'This is your Lifeline. Every memory you add will create a unique node on this path, forming a beautiful map of your life\'s journey.'**
  String get onboardingLifelineIntroText;

  /// No description provided for @onboardingLifelineIntroButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingLifelineIntroButton;

  /// No description provided for @onboardingAddMemoryText.
  ///
  /// In en, this message translates to:
  /// **'Tap here to add a new memory. A node will appear on your Lifeline for each moment you capture.'**
  String get onboardingAddMemoryText;

  /// No description provided for @onboardingNavGesturesText.
  ///
  /// In en, this message translates to:
  /// **'Great! Now, let\'s learn how to navigate your timeline.'**
  String get onboardingNavGesturesText;

  /// No description provided for @onboardingControlsPanelText.
  ///
  /// In en, this message translates to:
  /// **'Use these controls to manage your view. You can recenter the timeline, adjust visual effects, and access your profile.'**
  String get onboardingControlsPanelText;

  /// No description provided for @onboardingControlsPanelButton.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get onboardingControlsPanelButton;

  /// No description provided for @onboardingStatsCardText.
  ///
  /// In en, this message translates to:
  /// **'This card shows a summary of your memories. Tap it to open a full, searchable list of your entire journey.'**
  String get onboardingStatsCardText;

  /// No description provided for @onboardingStatsCardButton.
  ///
  /// In en, this message translates to:
  /// **'Almost Done!'**
  String get onboardingStatsCardButton;

  /// No description provided for @audioPlayerPreviousTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous Track'**
  String get audioPlayerPreviousTooltip;

  /// No description provided for @audioPlayerPlayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get audioPlayerPlayTooltip;

  /// No description provided for @audioPlayerPauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get audioPlayerPauseTooltip;

  /// No description provided for @audioPlayerNextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next Track'**
  String get audioPlayerNextTooltip;

  /// Label for a step in the CBT reflection helper
  ///
  /// In en, this message translates to:
  /// **'Step {step}: '**
  String memoryEditCbtStepLabel(int step);

  /// No description provided for @premiumBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Lifeline Premium'**
  String get premiumBannerTitle;

  /// No description provided for @premiumBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited media, advanced reflection, historical context, and more!'**
  String get premiumBannerSubtitle;

  /// No description provided for @premiumDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get premiumDialogTitle;

  /// No description provided for @premiumDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Unlock the ability to {feature} and get access to all premium features.'**
  String premiumDialogContent(String feature);

  /// No description provided for @premiumDialogGoPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get premiumDialogGoPremium;

  /// No description provided for @premiumFeaturePhotos.
  ///
  /// In en, this message translates to:
  /// **'add more photos'**
  String get premiumFeaturePhotos;

  /// No description provided for @premiumFeatureVideos.
  ///
  /// In en, this message translates to:
  /// **'add a video'**
  String get premiumFeatureVideos;

  /// No description provided for @premiumFeatureAudio.
  ///
  /// In en, this message translates to:
  /// **'add an audio note'**
  String get premiumFeatureAudio;

  /// No description provided for @premiumFeatureSpotify.
  ///
  /// In en, this message translates to:
  /// **'add a Spotify track'**
  String get premiumFeatureSpotify;

  /// No description provided for @premiumScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifeline Premium'**
  String get premiumScreenTitle;

  /// No description provided for @premiumScreenHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Full Potential'**
  String get premiumScreenHeaderTitle;

  /// No description provided for @premiumScreenHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go beyond the limits with Lifeline Premium and get the most out of your journey of self-discovery.'**
  String get premiumScreenHeaderSubtitle;

  /// No description provided for @premiumFeatureUnlimitedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Photos & Videos'**
  String get premiumFeatureUnlimitedPhotos;

  /// No description provided for @premiumFeatureUnlimitedAudio.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Audio Notes'**
  String get premiumFeatureUnlimitedAudio;

  /// No description provided for @premiumFeatureUnlimitedSpotify.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Spotify Tracks'**
  String get premiumFeatureUnlimitedSpotify;

  /// No description provided for @premiumFeatureAdvancedCbt.
  ///
  /// In en, this message translates to:
  /// **'Advanced Reflection Helper'**
  String get premiumFeatureAdvancedCbt;

  /// No description provided for @premiumFeatureActionReminders.
  ///
  /// In en, this message translates to:
  /// **'Action Plan Reminders'**
  String get premiumFeatureActionReminders;

  /// No description provided for @premiumFeatureHistoricalContext.
  ///
  /// In en, this message translates to:
  /// **'Historical \'In the World\' Context'**
  String get premiumFeatureHistoricalContext;

  /// No description provided for @premiumFeatureSoundLibrary.
  ///
  /// In en, this message translates to:
  /// **'Full Ambient Sound Library'**
  String get premiumFeatureSoundLibrary;

  /// No description provided for @premiumScreenYearlyPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular & Best Value'**
  String get premiumScreenYearlyPopular;

  /// No description provided for @premiumScreenRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get premiumScreenRestore;

  /// No description provided for @premiumScreenTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get premiumScreenTerms;

  /// No description provided for @premiumScreenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get premiumScreenPrivacy;

  /// No description provided for @premiumStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get premiumStatusTitle;

  /// No description provided for @premiumStatusExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String premiumStatusExpiresOn(String date);

  /// No description provided for @onboardingEncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Memories, Secured'**
  String get onboardingEncryptionTitle;

  /// No description provided for @onboardingEncryptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lifeline offers end-to-end encryption. This means only you can read your private memories. Let\'s set up your Master Password to protect them.'**
  String get onboardingEncryptionSubtitle;

  /// No description provided for @onboardingEncryptionSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Set Up Now'**
  String get onboardingEncryptionSetupButton;

  /// No description provided for @onboardingEncryptionLaterButton.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get onboardingEncryptionLaterButton;

  /// No description provided for @onboardingEncryptionActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Encryption is Active'**
  String get onboardingEncryptionActiveTitle;

  /// No description provided for @onboardingEncryptionActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your memories are already protected. You can manage your master password in the profile settings.'**
  String get onboardingEncryptionActiveSubtitle;

  /// No description provided for @onboardingEncryptionContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingEncryptionContinueButton;

  /// No description provided for @memoryEditEncryptMemory.
  ///
  /// In en, this message translates to:
  /// **'Encrypt this memory'**
  String get memoryEditEncryptMemory;

  /// No description provided for @memoryEditSetupEncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Encryption?'**
  String get memoryEditSetupEncryptionTitle;

  /// No description provided for @memoryEditSetupEncryptionContent.
  ///
  /// In en, this message translates to:
  /// **'To protect this memory, you first need to create a Master Password. This will be your single key to all encrypted entries.'**
  String get memoryEditSetupEncryptionContent;

  /// No description provided for @memoryEditCreatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Create Master Password'**
  String get memoryEditCreatePasswordButton;

  /// No description provided for @memoryViewExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Share as PDF'**
  String get memoryViewExportPdf;

  /// No description provided for @shareActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Lifeline'**
  String get shareActionTitle;

  /// No description provided for @shareActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do with these files?'**
  String get shareActionSubtitle;

  /// No description provided for @shareCreateNewMemory.
  ///
  /// In en, this message translates to:
  /// **'Create a New Memory'**
  String get shareCreateNewMemory;

  /// No description provided for @shareAddToExisting.
  ///
  /// In en, this message translates to:
  /// **'Add to Existing Memory'**
  String get shareAddToExisting;

  /// No description provided for @selectMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Memory'**
  String get selectMemoryTitle;

  /// No description provided for @selectMemorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or content...'**
  String get selectMemorySearchHint;

  /// No description provided for @selectMemoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No memories found'**
  String get selectMemoryEmpty;

  /// No description provided for @memoryUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Memory successfully updated!'**
  String get memoryUpdatedSuccess;

  /// No description provided for @unlockFailedAttemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. {count} attempts remaining.'**
  String unlockFailedAttemptsRemaining(int count);

  /// No description provided for @unlockTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again in {seconds} seconds.'**
  String unlockTooManyAttempts(int seconds);

  /// No description provided for @unlocking.
  ///
  /// In en, this message translates to:
  /// **'Unlocking...'**
  String get unlocking;

  /// No description provided for @exportingPdf.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF...'**
  String get exportingPdf;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'he',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
