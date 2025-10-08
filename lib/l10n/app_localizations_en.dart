// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create a new account';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get orSignInWith => 'Or sign in with';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get consentWelcomeTitle => 'Welcome to Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'Before you begin, please review and agree to our terms.';

  @override
  String get consentIAgreeTo => 'I have read and agree to the ';

  @override
  String get consentTermsOfService => 'Terms of Service';

  @override
  String get consentAnd => ' and ';

  @override
  String get consentPrivacyPolicy => 'Privacy Policy';

  @override
  String get consentContinue => 'Continue';

  @override
  String consentErrorSaving(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get splashMessageInitializing => 'Initializing...';

  @override
  String get splashMessageCheckingSettings => 'Checking settings...';

  @override
  String get splashMessageAuthenticating => 'Authenticating...';

  @override
  String get splashMessageSyncing => 'Syncing your timeline...';

  @override
  String get authGateLoadingMemories => 'Loading memories...';

  @override
  String get authGateAuthenticating => 'Authenticating...';

  @override
  String get authGateSomethingWentWrong => 'Something went wrong';

  @override
  String get authGateCouldNotLoad =>
      'We couldn\'t load your data. Please check your connection and try again.';

  @override
  String get authGateTryAgain => 'Try Again';

  @override
  String get authGateEmptyState =>
      'Your Lifeline is ready.\nTap the + button to add your first memory.';

  @override
  String get authGateUnsavedDraftTitle => 'Unsaved Memory';

  @override
  String get authGateUnsavedDraftContent =>
      'You have an unsaved memory draft. Do you want to continue editing it?';

  @override
  String get authGateDiscard => 'Discard';

  @override
  String get authGateContinueEditing => 'Continue Editing';

  @override
  String get verifyEmailTitle => 'Email Verification';

  @override
  String get verifyEmailSentTo => 'A verification email has been sent to:';

  @override
  String get verifyEmailInstructions =>
      'Please click the link in the email to complete your registration.';

  @override
  String get verifyEmailResendButton => 'Resend Email';

  @override
  String get verifyEmailCancelButton => 'Cancel';

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get profileSectionProfile => 'PROFILE';

  @override
  String get profileChangeNameTitle => 'Change Name';

  @override
  String get profileEnterYourName => 'Enter your name';

  @override
  String get profileSave => 'Save';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileCountry => 'Country';

  @override
  String get profileCountryNotSelected => 'Not selected';

  @override
  String get profileLanguage => 'Content Language';

  @override
  String get profileLanguageDefault => 'English (Default)';

  @override
  String get profileSelectLanguage => 'Select Language';

  @override
  String get profileSectionSettings => 'SETTINGS';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileReauthTitle => 'Re-authentication Required';

  @override
  String get profileReauthContent =>
      'This is a sensitive operation. Please sign in again before proceeding.';

  @override
  String get profileReauthButton => 'Sign In & Delete';

  @override
  String get profileReauthPasswordDialogTitle => 'Confirm Action';

  @override
  String get profileReauthPasswordDialogContent =>
      'To delete your account, please enter your current password.';

  @override
  String get profilePasswordCannotBeEmpty => 'Password cannot be empty';

  @override
  String get profileChangePasswordSuccess =>
      'Master password changed successfully!';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'The current password you entered is incorrect.';

  @override
  String get profileOldPasswordHint => 'Old Password';

  @override
  String get profileNewPasswordHint => 'New Password';

  @override
  String get profileDeleteAccountConfirmContent =>
      'This action is irreversible. Your entire account, including all memories and settings, will be permanently deleted. To proceed, press and hold the delete button for 5 seconds.';

  @override
  String get profileChangePasswordCurrentPasswordHint =>
      'Current Master Password';

  @override
  String get profileChangePasswordNewPasswordHint => 'New Master Password';

  @override
  String get profileChangePasswordInfo =>
      'Please enter your current master password to set a new one. This will re-encrypt your secret key.';

  @override
  String get profileGraphics => 'Graphics Quality';

  @override
  String get profileGraphicsAuto => 'Automatic';

  @override
  String get profileGraphicsLow => 'Low';

  @override
  String get profileGraphicsMedium => 'Medium';

  @override
  String get profileGraphicsHigh => 'High';

  @override
  String get profileReminders => 'Reflection Reminders';

  @override
  String get profileRemindersSubtitle =>
      'Receive notifications for your action plans';

  @override
  String get profileSectionSecurity => 'SECURITY';

  @override
  String get profileChangePassword => 'Change Master Password';

  @override
  String get profileEncryptionActive => 'End-to-end encryption is active';

  @override
  String get profileEnableEncryption => 'Enable End-to-End Encryption';

  @override
  String get profileEnableEncryptionSubtitle =>
      'Protect your sensitive memories with a master password.';

  @override
  String get profileCreateMasterPassword => 'Create Master Password';

  @override
  String get profileMasterPasswordInfo =>
      'This password will protect your memories. It cannot be recovered if you forget it. Please store it safely.';

  @override
  String get profileMasterPasswordHint => 'Master Password';

  @override
  String get profileConfirmPasswordHint => 'Confirm Password';

  @override
  String get profilePasswordMinLength =>
      'Password must be at least 8 characters';

  @override
  String get profilePasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get profileEnable => 'Enable';

  @override
  String get profileSectionHelp => 'HELP';

  @override
  String get profileReplayTutorial => 'Replay Tutorial';

  @override
  String get profileReplayTutorialConfirmTitle => 'Replay Tutorial?';

  @override
  String get profileReplayTutorialConfirmContent =>
      'Are you sure you want to restart the tutorial?';

  @override
  String get profileRestart => 'Restart';

  @override
  String get profileSectionAccount => 'ACCOUNT MANAGEMENT';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteAccountConfirmTitle => 'Delete Account?';

  @override
  String get profileDelete => 'Delete';

  @override
  String get profileDeletingAccount => 'Deleting your account...';

  @override
  String get profileErrorCouldNotFindProfile => 'Could not find user profile.';

  @override
  String get memoryEditNewTitle => 'New Memory';

  @override
  String get memoryEditEditTitle => 'Edit Memory';

  @override
  String get memoryEditSave => 'Save';

  @override
  String get memoryEditTitleHint => 'Title';

  @override
  String get memoryEditTitleValidator => 'Please enter a title';

  @override
  String get memoryEditDescriptionHint => 'Description';

  @override
  String get memoryEditDateLabel => 'Date:';

  @override
  String get memoryEditSelectDateButton => 'Select Date';

  @override
  String get memoryEditAmbientSoundLabel => 'Ambient Sound:';

  @override
  String get memoryEditAmbientSoundDropdownHint => 'Select an ambient sound';

  @override
  String get memoryEditMusicAnchorLabel => 'Music Anchor:';

  @override
  String get memoryEditAttachTrackButton => 'Attach track from Spotify';

  @override
  String get memoryEditPhotosLabel => 'Photos:';

  @override
  String get memoryEditNoPhotosSelected => 'No photos selected';

  @override
  String get memoryEditAddPhotosButton => 'Add Photos';

  @override
  String get memoryEditVideosLabel => 'Videos:';

  @override
  String get memoryEditNoVideosSelected => 'No videos selected';

  @override
  String get memoryEditAddVideoButton => 'Add Video';

  @override
  String get memoryEditAudioNoteLabel => 'Audio Note:';

  @override
  String get memoryEditAudioNoteSaved => 'Audio note saved';

  @override
  String get memoryEditRecordButton => 'Record';

  @override
  String get memoryEditStopRecordingButton => 'Stop Recording';

  @override
  String get memoryEditRecordingIndicator => 'Recording...';

  @override
  String get memoryEditReflectionSectionTitle => 'Reflection';

  @override
  String get memoryEditEncryptLabel => 'Encrypt';

  @override
  String get memoryEditEncryptionInfoTooltip => 'What is encryption?';

  @override
  String get memoryEditImpactPrompt => 'How did this event impact me?';

  @override
  String get memoryEditLessonPrompt => 'What lesson did I learn?';

  @override
  String get memoryEditEmotionsLabel => 'Emotions:';

  @override
  String get emotionJoy => 'Joy';

  @override
  String get emotionNostalgia => 'Nostalgia';

  @override
  String get emotionPride => 'Pride';

  @override
  String get emotionSadness => 'Sadness';

  @override
  String get emotionGratitude => 'Gratitude';

  @override
  String get emotionLove => 'Love';

  @override
  String get emotionFear => 'Fear';

  @override
  String get emotionAnger => 'Anger';

  @override
  String get memoryEditCbtHelperTitle => 'Reflection Helper';

  @override
  String get memoryEditCbtStep1Title => 'What was the first thought or belief?';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'e.g., \'I will fail\' or \'I did everything right\'.';

  @override
  String get memoryEditCbtStep2Title => 'What supports this thought?';

  @override
  String get memoryEditCbtStep2Subtitle =>
      'What facts or events prove this thought to be true?';

  @override
  String get memoryEditCbtStep3Title => 'What is the view from the other side?';

  @override
  String get memoryEditCbtStep3Subtitle =>
      'What facts or events might disprove or challenge the first thought?';

  @override
  String get memoryEditCbtStep4Title => 'How can I look at this differently?';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'Based on the above, formulate a new, more balanced perspective.';

  @override
  String get memoryEditActionPlanTitle => 'Action Plan';

  @override
  String get memoryEditActionPrompt => 'What is one small step I can take?';

  @override
  String get memoryEditReminderLabel => 'Reminder:';

  @override
  String get memoryEditReminderNotSet => 'Not set';

  @override
  String get memoryEditSetReminderButton => 'Set Date';

  @override
  String get memoryEditYourThoughtsHint => 'Your thoughts here...';

  @override
  String get memoryEditDraftSavedMessage => 'Draft saved';

  @override
  String get memoryEditErrorRepoUnavailable =>
      'Error: Repository not available.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'Error saving memory: $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'Unlock to Save';

  @override
  String get memoryEditUnlockDialogContent =>
      'Please enter your Master Password to save this encrypted memory.';

  @override
  String get memoryEditMasterPasswordHint => 'Master Password';

  @override
  String get memoryEditUnlockButton => 'Unlock';

  @override
  String get memoryEditEncryptionInfoDialogTitle => 'End-to-End Encryption';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'When you encrypt a memory, its description and reflection fields are scrambled using a key derived from your Master Password.\n\nThe data is stored in an unreadable format in the cloud and can only be decrypted on your devices with your password.\n\nIMPORTANT: We cannot recover your Master Password. If you forget it, your encrypted data will be lost forever.';

  @override
  String get memoryEditOkButton => 'OK';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'Permission for $permissionName was denied. Please enable it in settings.';
  }

  @override
  String get memoryEditSettingsButton => 'Settings';

  @override
  String get memoryEditNoInternetSnackbar =>
      'Internet connection is required to search for music.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'Intensity for \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'Back';

  @override
  String get memoryViewShareTooltip => 'Share';

  @override
  String get memoryViewEditTooltip => 'Edit';

  @override
  String get memoryViewDeleteTooltip => 'Delete';

  @override
  String get memoryViewTabMemory => 'Memory';

  @override
  String get memoryViewTabInTheWorld => 'In the World';

  @override
  String get memoryViewEncryptedTitle => 'Encrypted Memory';

  @override
  String get memoryViewReflectionTitle => 'Reflection';

  @override
  String get memoryViewReflectionImpact => 'Impact';

  @override
  String get memoryViewReflectionLesson => 'Lesson Learned';

  @override
  String get memoryViewCbtStep1Title => 'First Thought or Belief';

  @override
  String get memoryViewCbtStep2Title => 'Evidence For This Thought';

  @override
  String get memoryViewCbtStep3Title => 'Evidence Against This Thought';

  @override
  String get memoryViewCbtStep4Title => 'New, Balanced Perspective (Reframe)';

  @override
  String memoryViewActionReminder(String date) {
    return 'Reminder: $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'Mark as incomplete';

  @override
  String get memoryViewMarkCompleteTooltip => 'Mark as complete';

  @override
  String get memoryViewUnlockDialogTitle => 'Unlock Memory';

  @override
  String get memoryViewUnlockDialogContent =>
      'Enter your Master Password to view this content.';

  @override
  String get memoryViewIncorrectPassword => 'Incorrect password.';

  @override
  String get memoryViewUnlockButton => 'Unlock';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'Could not load your profile to fetch historical data.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'Could not load historical data for this day.';

  @override
  String get memoryViewNoHistoricalData =>
      'No historical data available for this day.';

  @override
  String get memoryViewErrorCouldNotLoadTrack => 'Could not load track';

  @override
  String get memoryViewTabNews => 'News';

  @override
  String get memoryViewTabMusic => 'Music';

  @override
  String get memoryViewNoDataForDay => 'No data for this day.';

  @override
  String get memoryViewNoNewsForDay => 'No historical news for this day.';

  @override
  String memoryViewNewsSource(String source) {
    return 'Source: $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'Confirm Deletion';

  @override
  String get memoryViewConfirmDeleteContent =>
      'This action is irreversible. To proceed, press and hold the delete button for 5 seconds.';

  @override
  String get memoryViewDeleteButton => 'DELETE';

  @override
  String get memoryViewErrorLoadingProfile =>
      'We couldn\'t load your profile. Please check your connection and try again.';

  @override
  String get memoryViewErrorLocalDb =>
      'Error: Could not access local database.';

  @override
  String get memoryViewMemoryDeleted => 'Memory deleted';

  @override
  String get memoryViewSharingNotImplemented =>
      'Sharing functionality not yet implemented.';

  @override
  String get memoryViewActionCompleted => 'Action marked as complete!';

  @override
  String get memoryViewActionIncomplete => 'Action marked as incomplete.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'Error updating action: $error';
  }

  @override
  String get memoryViewContentEncrypted => 'Content is Encrypted';

  @override
  String get memoryViewReflectionEncrypted => 'Reflection is Encrypted';

  @override
  String get memoryViewMediaEncrypted => 'Media is Encrypted';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'Ambient Sound: $sound';
  }

  @override
  String get memoryViewAudioNote => 'Audio Note';

  @override
  String get spotifySearchTitle => 'Search Spotify Track';

  @override
  String get spotifySearchHint => 'Song title or artist';

  @override
  String get documentErrorLoading => 'Could not load document.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'Memories: $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'Period: $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status ($jobs left)';
  }

  @override
  String get lifelineCalculating => 'Calculating...';

  @override
  String lifelineScaleValue(int scale) {
    return 'Scale: $scale%';
  }

  @override
  String lifelineFpsValue(String fps) {
    return 'FPS: $fps';
  }

  @override
  String lifelineFramePaintValue(int ms) {
    return 'Frame Paint: $ms ms';
  }

  @override
  String get lifelineShowFullTimelineTooltip => 'Show full timeline';

  @override
  String get lifelineVisualSettingsTooltip => 'Visual settings';

  @override
  String get lifelineMenuProfile => 'Profile';

  @override
  String get lifelineMenuDebugOn => 'Debug On';

  @override
  String get lifelineMenuDebugOff => 'Debug Off';

  @override
  String get lifelineMenuSignOut => 'Sign Out';

  @override
  String get lifelineSearchHint => 'Search...';

  @override
  String get lifelineMemoriesListTitle => 'Memories';

  @override
  String get lifelineVisualSettingsDialogTitle => 'Visual Settings';

  @override
  String get lifelineVisualSettingsSpeed => 'Speed';

  @override
  String get lifelineVisualSettingsAmplitude => 'Amplitude';

  @override
  String get lifelineVisualSettingsYearLine => 'Year Line Position';

  @override
  String get lifelineVisualSettingsBranchDensity => 'Branch Density';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'Branch Intensity';

  @override
  String get lifelineVisualSettingsAnimate => 'Animate';

  @override
  String get lifelineVisualSettingsDoneButton => 'Done';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'Your personal journey, visualized. Let\'s take a quick tour to see how you can begin capturing your moments.';

  @override
  String get onboardingSkipButton => 'Skip for now';

  @override
  String get onboardingBeginTourButton => 'Begin Tour';

  @override
  String get onboardingGesturesTitle => 'Navigate Your Timeline';

  @override
  String get onboardingGestureSwipe => 'Swipe';

  @override
  String get onboardingGesturePinch => 'Pinch to Zoom';

  @override
  String get onboardingGestureDoubleTap => 'Double Tap';

  @override
  String get onboardingGesturesSubtitle =>
      'Your Lifeline will grow with you. Pinch to zoom, double tap to quickly zoom in. Swipe left and right to navigate through time.';

  @override
  String get onboardingContinueButton => 'Continue';

  @override
  String get onboardingFinalTitle => 'You\'re All Set!';

  @override
  String get onboardingFinalSubtitle =>
      'Your journey begins now. Start capturing the moments that matter.';

  @override
  String get onboardingStartJourneyButton => 'Start My Journey';

  @override
  String get onboardingSkipTourButton => 'Skip Tour';

  @override
  String get onboardingLifelineIntroText =>
      'This is your Lifeline. Every memory you add will create a unique node on this path, forming a beautiful map of your life\'s journey.';

  @override
  String get onboardingLifelineIntroButton => 'Next';

  @override
  String get onboardingAddMemoryText =>
      'Tap here to add a new memory. A node will appear on your Lifeline for each moment you capture.';

  @override
  String get onboardingNavGesturesText =>
      'Great! Now, let\'s learn how to navigate your timeline.';

  @override
  String get onboardingControlsPanelText =>
      'Use these controls to manage your view. You can recenter the timeline, adjust visual effects, and access your profile.';

  @override
  String get onboardingControlsPanelButton => 'Got It';

  @override
  String get onboardingStatsCardText =>
      'This card shows a summary of your memories. Tap it to open a full, searchable list of your entire journey.';

  @override
  String get onboardingStatsCardButton => 'Almost Done!';

  @override
  String get audioPlayerPreviousTooltip => 'Previous Track';

  @override
  String get audioPlayerPlayTooltip => 'Play';

  @override
  String get audioPlayerPauseTooltip => 'Pause';

  @override
  String get audioPlayerNextTooltip => 'Next Track';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'Step $step: ';
  }

  @override
  String get premiumBannerTitle => 'Unlock Lifeline Premium';

  @override
  String get premiumBannerSubtitle =>
      'Unlimited media, advanced reflection, historical context, and more!';

  @override
  String get premiumDialogTitle => 'Upgrade to Premium';

  @override
  String premiumDialogContent(String feature) {
    return 'Unlock the ability to $feature and get access to all premium features.';
  }

  @override
  String get premiumDialogGoPremium => 'Go Premium';

  @override
  String get premiumFeaturePhotos => 'add more photos';

  @override
  String get premiumFeatureVideos => 'add a video';

  @override
  String get premiumFeatureAudio => 'add an audio note';

  @override
  String get premiumFeatureSpotify => 'add a Spotify track';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'Unlock Your Full Potential';

  @override
  String get premiumScreenHeaderSubtitle =>
      'Go beyond the limits with Lifeline Premium and get the most out of your journey of self-discovery.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'Unlimited Photos & Videos';

  @override
  String get premiumFeatureUnlimitedAudio => 'Unlimited Audio Notes';

  @override
  String get premiumFeatureUnlimitedSpotify => 'Unlimited Spotify Tracks';

  @override
  String get premiumFeatureAdvancedCbt => 'Advanced Reflection Helper';

  @override
  String get premiumFeatureActionReminders => 'Action Plan Reminders';

  @override
  String get premiumFeatureHistoricalContext =>
      'Historical \'In the World\' Context';

  @override
  String get premiumFeatureSoundLibrary => 'Full Ambient Sound Library';

  @override
  String get premiumScreenYearlyPopular => 'Most Popular & Best Value';

  @override
  String get premiumScreenProcessingPurchase => 'Processing purchase...';

  @override
  String get premiumScreenRestore => 'Restore Purchases';

  @override
  String get premiumScreenTerms => 'Terms of Service';

  @override
  String get premiumScreenPrivacy => 'Privacy Policy';

  @override
  String get premiumStatusTitle => 'Premium Member';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get onboardingEncryptionTitle => 'Your Memories, Secured';

  @override
  String get onboardingEncryptionSubtitle =>
      'Lifeline offers end-to-end encryption. This means only you can read your private memories. Let\'s set up your Master Password to protect them.';

  @override
  String get onboardingEncryptionSetupButton => 'Set Up Now';

  @override
  String get onboardingEncryptionLaterButton => 'Maybe Later';

  @override
  String get onboardingEncryptionActiveTitle => 'Encryption is Active';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'Your memories are already protected. You can manage your master password in the profile settings.';

  @override
  String get onboardingEncryptionContinueButton => 'Continue';

  @override
  String get memoryEditEncryptMemory => 'Encrypt this memory';

  @override
  String get memoryEditSetupEncryptionTitle => 'Enable Encryption?';

  @override
  String get memoryEditSetupEncryptionContent =>
      'To protect this memory, you first need to create a Master Password. This will be your single key to all encrypted entries.';

  @override
  String get memoryEditCreatePasswordButton => 'Create Master Password';

  @override
  String get memoryViewExportPdf => 'Share as PDF';

  @override
  String get shareActionTitle => 'Add to Lifeline';

  @override
  String get shareActionSubtitle =>
      'What would you like to do with these files?';

  @override
  String get shareCreateNewMemory => 'Create a New Memory';

  @override
  String get shareAddToExisting => 'Add to Existing Memory';

  @override
  String get selectMemoryTitle => 'Select a Memory';

  @override
  String get selectMemorySearchHint => 'Search by title or content...';

  @override
  String get selectMemoryEmpty => 'No memories found';

  @override
  String get memoryUpdatedSuccess => 'Memory successfully updated!';

  @override
  String unlockFailedAttemptsRemaining(int count) {
    return 'Incorrect password. $count attempts remaining.';
  }

  @override
  String unlockTooManyAttempts(int seconds) {
    return 'Too many attempts. Please try again in $seconds seconds.';
  }

  @override
  String get unlocking => 'Unlocking...';

  @override
  String get exportingPdf => 'Preparing PDF...';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get profileEnableQuickUnlock => 'Enable Quick Unlock';

  @override
  String get profileQuickUnlockSubtitle =>
      'Use your fingerprint, face, or device PIN to unlock.';

  @override
  String get profileRequireBiometricsForMemoryTitle =>
      'Require Biometrics for Each Memory';

  @override
  String get profileRequireBiometricsForMemorySubtitle =>
      'If enabled, require authentication to open or edit individual encrypted memories, even when the app is unlocked.';

  @override
  String get quickUnlockPrompt => 'Authenticate to unlock Lifeline';

  @override
  String get quickUnlockEnablePrompt => 'Authenticate to enable Quick Unlock';

  @override
  String get masterPasswordRequiredTitle => 'Master Password Required';

  @override
  String get masterPasswordRequiredContent =>
      'Please enter your Master Password to enable this feature.';

  @override
  String get unlockScreenTitle => 'Unlock Lifeline';

  @override
  String get unlockWithBiometrics => 'Unlock with Biometrics';

  @override
  String get unlockEnterMasterPassword => 'Enter Master Password';

  @override
  String get unlockForgotPassword => 'Forgot Password?';

  @override
  String get unlockResetEncryptionTitle => 'Reset Encryption';

  @override
  String get unlockResetEncryptionWarning =>
      '⚠️ WARNING: This action cannot be undone!';

  @override
  String get unlockResetEncryptionDescription =>
      'If you\'ve forgotten your master password, you can reset encryption. However, this will permanently delete all encrypted memories.';

  @override
  String get unlockResetEncryptionConsequences => 'What will be deleted:';

  @override
  String get unlockResetEncryptionConsequence1 =>
      'All encrypted memories (local and cloud)';

  @override
  String get unlockResetEncryptionConsequence2 => 'Encryption will be disabled';

  @override
  String get unlockResetEncryptionConsequence3 =>
      'You can continue using the app with unencrypted memories';

  @override
  String get unlockResetEncryptionConfirm => 'Delete Encrypted Memories';

  @override
  String get unlockResetEncryptionSuccess =>
      'Encryption has been reset. You can now use the app without a master password.';

  @override
  String get unlockResetEncryptionError => 'Failed to reset encryption';

  @override
  String get draftBannerSingleTitle => 'You have an unfinished memory';

  @override
  String draftBannerSingleSubtitle(String timeAgo) {
    return 'Last edited: $timeAgo';
  }

  @override
  String draftBannerMultipleTitle(int count) {
    return 'You have $count unfinished memories';
  }

  @override
  String get draftBannerMultipleSubtitle => 'Tap to view all';

  @override
  String get draftBannerResume => 'Resume';

  @override
  String get draftBannerDelete => 'Delete';

  @override
  String get draftResumedSuccess => 'Draft resumed successfully';

  @override
  String get draftDeleteDialogTitle => 'Delete Draft?';

  @override
  String get draftDeleteDialogMessage =>
      'This draft will be permanently deleted. This action cannot be undone.';

  @override
  String get draftDeleteCancel => 'Cancel';

  @override
  String get draftDeleteConfirm => 'Delete';

  @override
  String get draftDeletedSuccess => 'Draft deleted successfully';

  @override
  String get draftDeletedError => 'Failed to delete draft';

  @override
  String draftListDialogTitle(int count) {
    return 'You have $count drafts';
  }

  @override
  String get draftListItemNoTitle => 'Untitled memory';

  @override
  String get draftListItemNoContent => 'No content';

  @override
  String draftListItemLastModified(String timeAgo) {
    return 'Last modified: $timeAgo';
  }

  @override
  String get timeAgoJustNow => 'just now';

  @override
  String timeAgoMinutes(int count) {
    return '$count minutes ago';
  }

  @override
  String timeAgoHours(int count) {
    return '$count hours ago';
  }

  @override
  String timeAgoDays(int count) {
    return '$count days ago';
  }

  @override
  String timeAgoWeeks(int count) {
    return '$count weeks ago';
  }

  @override
  String get fileSizeTooLargeImage =>
      'Image file is too large. Maximum size is 10 MB.';

  @override
  String get fileSizeTooLargeVideo =>
      'Video file is too large. Maximum size is 100 MB.';

  @override
  String get fileSizeTooLargeAudio =>
      'Audio file is too large. Maximum size is 25 MB.';

  @override
  String get biometricUnlockFailedMessage =>
      'Security keys need to be recreated after reinstalling the app. Please enter your master password to continue.';

  @override
  String lifelineInsightStreakDays(int count) {
    return '🔥 $count day streak';
  }

  @override
  String lifelineInsightMemoriesThisMonth(int count) {
    return '📝 $count memories this month';
  }

  @override
  String lifelineInsightMemoriesThisWeek(int count) {
    return '✨ $count new this week';
  }

  @override
  String lifelineInsightReflectionsCount(int count) {
    return '⭐ $count reflections';
  }

  @override
  String lifelineInsightPhotosCount(int count) {
    return '📸 $count photos';
  }

  @override
  String lifelineInsightAudioCount(int count) {
    return '🎵 $count audio notes';
  }

  @override
  String lifelineInsightSpanningYears(int years) {
    return '📅 Spanning $years years';
  }

  @override
  String lifelineInsightTotalMemories(int count) {
    return '📖 $count moments captured';
  }

  @override
  String get lifelineInsightPositiveVibes => '😊 Mostly positive vibes';

  @override
  String get lifelineInsightGrowthJourney => '🌱 Growth journey';

  @override
  String get lifelineInsightBalancedEmotions => '⚖️ Balanced emotions';

  @override
  String get lifelineInsightStartJourney => '✍️ Start your journey';

  @override
  String get lifelineInsightBuildStreak => '💪 Build your streak';

  @override
  String get purchaseSuccessMessage =>
      'Purchase successful! Welcome to Premium!';

  @override
  String get graphicsQualityTitle => 'Graphics Quality';

  @override
  String get graphicsQualityAuto => 'Auto';

  @override
  String get graphicsQualityLow => 'Low';

  @override
  String get graphicsQualityMedium => 'Medium';

  @override
  String get graphicsQualityHigh => 'High';

  @override
  String get graphicsQualityAutoSubtitle =>
      'Automatically detect device performance';

  @override
  String get graphicsQualityLowSubtitle => 'Best battery life, minimal effects';

  @override
  String get graphicsQualityMediumSubtitle =>
      'Balanced performance and visuals';

  @override
  String get graphicsQualityHighSubtitle => 'Best visuals, more battery usage';

  @override
  String graphicsQualityAutoDetected(String performance) {
    return 'Auto ($performance)';
  }

  @override
  String get notificationAnniversaryTitle => 'Anniversary reminders';

  @override
  String get notificationAnniversarySubtitle =>
      'Remind me of meaningful moments from the past';

  @override
  String get notificationMotivationalTitle => 'Occasional motivations';

  @override
  String get notificationMotivationalSubtitle =>
      'Gentle reminders to capture important moments';

  @override
  String get notificationInsightTitle => 'Emotional insights';

  @override
  String get notificationInsightSubtitle =>
      'Reflections on your emotional journey';
}
