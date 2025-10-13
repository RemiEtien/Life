// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get email => 'אימייל';

  @override
  String get password => 'סיסמה';

  @override
  String get signIn => 'התחבר';

  @override
  String get register => 'הירשם';

  @override
  String get createAccount => 'צור חשבון חדש';

  @override
  String get alreadyHaveAccount => 'יש לי כבר חשבון';

  @override
  String get orSignInWith => 'או התחבר באמצעות';

  @override
  String get passwordTooShort => 'הסיסמה חייבת להכיל לפחות 6 תווים';

  @override
  String get invalidEmail => 'נא להזין כתובת אימייל חוקית';

  @override
  String get consentWelcomeTitle => 'ברוכים הבאים ל-Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'לפני שתתחיל, אנא עיין בתנאים שלנו והסכם להם.';

  @override
  String get consentIAgreeTo => 'קראתי ואני מסכים/ה ל';

  @override
  String get consentTermsOfService => 'תנאי השירות';

  @override
  String get consentAnd => ' ו';

  @override
  String get consentPrivacyPolicy => 'מדיניות הפרטיות';

  @override
  String get consentContinue => 'המשך';

  @override
  String consentErrorSaving(String error) {
    return 'שגיאה בשמירת ההגדרות: $error';
  }

  @override
  String get splashMessageInitializing => 'מאתחל...';

  @override
  String get splashMessageCheckingSettings => 'בודק הגדרות...';

  @override
  String get splashMessageAuthenticating => 'מאמת...';

  @override
  String get splashMessageSyncing => 'מסנכרן את ציר הזמן שלך...';

  @override
  String get authGateLoadingMemories => 'טוען זיכרונות...';

  @override
  String get authGateAuthenticating => 'מאמת...';

  @override
  String get authGateSomethingWentWrong => 'משהו השתבש';

  @override
  String get authGateCouldNotLoad =>
      'לא הצלחנו לטעון את הנתונים שלך. אנא בדוק את החיבור ונסה שוב.';

  @override
  String get authGateTryAgain => 'נסה שוב';

  @override
  String get authGateEmptyState =>
      'ציר הזמן שלך מוכן.\nהקש על כפתור + כדי להוסיף את הזיכרון הראשון שלך.';

  @override
  String get authGateUnsavedDraftTitle => 'זיכרון שלא נשמר';

  @override
  String get authGateUnsavedDraftContent =>
      'יש לך טיוטת זיכרון שלא נשמרה. האם תרצה להמשיך לערוך אותה?';

  @override
  String get authGateDiscard => 'מחק';

  @override
  String get authGateContinueEditing => 'המשך עריכה';

  @override
  String get verifyEmailTitle => 'אימות אימייל';

  @override
  String get verifyEmailSentTo => 'נשלח אימייל אימות לכתובת:';

  @override
  String get verifyEmailInstructions =>
      'אנא לחץ על הקישור באימייל להשלמת ההרשמה.';

  @override
  String get verifyEmailResendButton => 'שלח שוב אימייל';

  @override
  String get verifyEmailCancelButton => 'ביטול';

  @override
  String get profileTitle => 'פרופיל והגדרות';

  @override
  String get profileSectionProfile => 'פרופיל';

  @override
  String get profileChangeNameTitle => 'שנה שם';

  @override
  String get profileEnterYourName => 'הזן את שמך';

  @override
  String get profileSave => 'שמור';

  @override
  String get profileCancel => 'ביטול';

  @override
  String get profileName => 'שם';

  @override
  String get profileEmail => 'אימייל';

  @override
  String get profileCountry => 'מדינה';

  @override
  String get profileCountryNotSelected => 'לא נבחר';

  @override
  String get profileLanguage => 'שפת התוכן';

  @override
  String get profileLanguageDefault => 'אנגלית (ברירת מחדל)';

  @override
  String get profileSelectLanguage => 'בחר שפה';

  @override
  String get profileSectionSettings => 'הגדרות';

  @override
  String get profileTheme => 'ערכת נושא';

  @override
  String get profileThemeSystem => 'מערכת';

  @override
  String get profileThemeLight => 'בהיר';

  @override
  String get profileThemeDark => 'כהה';

  @override
  String get profileReauthTitle => 'נדרש אימות מחדש';

  @override
  String get profileReauthContent =>
      'זוהי פעולה רגישה. אנא היכנס שוב לפני שתמשיך.';

  @override
  String get profileReauthButton => 'התחבר ומחק';

  @override
  String get profileReauthPasswordDialogTitle => 'אשר פעולה';

  @override
  String get profileReauthPasswordDialogContent =>
      'כדי למחוק את חשבונך, אנא הזן את סיסמתך הנוכחית.';

  @override
  String get profilePasswordCannotBeEmpty => 'סיסמה אינה יכולה להיות ריקה';

  @override
  String get profileChangePasswordSuccess => 'סיסמת המאסטר שונתה בהצלחה!';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'סיסמת המאסטר הנוכחית שהזנת שגויה.';

  @override
  String get profileOldPasswordHint => 'סיסמה ישנה';

  @override
  String get profileNewPasswordHint => 'סיסמה חדשה';

  @override
  String get profileDeleteAccountConfirmContent =>
      'פעולה זו אינה הפיכה. כל חשבונך, כולל כל הזיכרונות וההגדרות, יימחק לצמיתות. כדי להמשיך, לחץ והחזק את לחצן המחיקה למשך 5 שניות.';

  @override
  String get profileChangePasswordCurrentPasswordHint => 'סיסמת מאסטר נוכחית';

  @override
  String get profileChangePasswordNewPasswordHint => 'סיסמת מאסטר חדשה';

  @override
  String get profileChangePasswordInfo =>
      'אנא הזן את סיסמת המאסטר הנוכחית שלך כדי להגדיר סיסמה חדשה. פעולה זו תצפין מחדש את המפתח הסודי שלך.';

  @override
  String get profileGraphics => 'איכות גרפיקה';

  @override
  String get profileGraphicsAuto => 'אוטומטי';

  @override
  String get profileGraphicsLow => 'נמוכה';

  @override
  String get profileGraphicsMedium => 'בינונית';

  @override
  String get profileGraphicsHigh => 'גבוהה';

  @override
  String get profileReminders => 'תזכורות לרפלקציה';

  @override
  String get profileRemindersSubtitle => 'קבל התראות על תוכניות הפעולה שלך';

  @override
  String get profileSectionSecurity => 'אבטחה';

  @override
  String get profileChangePassword => 'שנה סיסמת מאסטר';

  @override
  String get profileEncryptionActive => 'הצפנה מקצה לקצה פעילה';

  @override
  String get profileEnableEncryption => 'הפעל הצפנה מקצה לקצה';

  @override
  String get profileEnableEncryptionSubtitle =>
      'הגן על הזיכרונות הרגישים שלך באמצעות סיסמת מאסטר.';

  @override
  String get profileCreateMasterPassword => 'צור סיסמת מאסטר';

  @override
  String get profileMasterPasswordInfo =>
      'סיסמה זו תגן על הזיכרונות שלך. לא ניתן לשחזר אותה אם תשכח אותה. אנא שמור אותה במקום בטוח.';

  @override
  String get profileMasterPasswordHint => 'סיסמת מאסטר';

  @override
  String get profileConfirmPasswordHint => 'אשר סיסמה';

  @override
  String get profilePasswordMinLength => 'הסיסמה חייבת להכיל לפחות 8 תווים';

  @override
  String get profilePasswordsDoNotMatch => 'הסיסמאות אינן תואמות';

  @override
  String get profileEnable => 'הפעל';

  @override
  String get profileSectionHelp => 'עזרה';

  @override
  String get profileReplayTutorial => 'הפעל שוב את המדריך';

  @override
  String get profileReplayTutorialConfirmTitle => 'להפעיל שוב את המדריך?';

  @override
  String get profileReplayTutorialConfirmContent =>
      'האם אתה בטוח שברצונך להפעיל מחדש את המדריך?';

  @override
  String get profileRestart => 'הפעל מחדש';

  @override
  String get profileSectionAccount => 'ניהול חשבון';

  @override
  String get profileSignOut => 'התנתק';

  @override
  String get profileDeleteAccount => 'מחק חשבון';

  @override
  String get profileDeleteAccountConfirmTitle => 'למחוק חשבון?';

  @override
  String get profileDelete => 'מחק';

  @override
  String get profileDeletingAccount => 'מוחק את חשבונך...';

  @override
  String get profileErrorCouldNotFindProfile =>
      'לא ניתן למצוא את פרופיל המשתמש.';

  @override
  String get memoryEditNewTitle => 'זיכרון חדש';

  @override
  String get memoryEditEditTitle => 'ערוך זיכרון';

  @override
  String get memoryEditSave => 'שמור';

  @override
  String get memoryEditTitleHint => 'כותרת';

  @override
  String get memoryEditTitleValidator => 'נא להזין כותרת';

  @override
  String get memoryEditDescriptionHint => 'תיאור';

  @override
  String get memoryEditDateLabel => 'תאריך:';

  @override
  String get memoryEditSelectDateButton => 'בחר תאריך';

  @override
  String get memoryEditAmbientSoundLabel => 'צליל רקע:';

  @override
  String get memoryEditAmbientSoundDropdownHint => 'בחר צליל רקע';

  @override
  String get memoryEditMusicAnchorLabel => 'עוגן מוזיקלי:';

  @override
  String get memoryEditAttachTrackButton => 'צרף רצועה מ-Spotify';

  @override
  String get memoryEditPhotosLabel => 'תמונות:';

  @override
  String get memoryEditNoPhotosSelected => 'לא נבחרו תמונות';

  @override
  String get memoryEditAddPhotosButton => 'הוסף תמונות';

  @override
  String get memoryEditVideosLabel => 'סרטונים:';

  @override
  String get memoryEditNoVideosSelected => 'לא נבחרו סרטונים';

  @override
  String get memoryEditAddVideoButton => 'הוסף סרטון';

  @override
  String get memoryEditAudioNoteLabel => 'הערה קולית:';

  @override
  String get memoryEditAudioNoteSaved => 'הערה קולית נשמרה';

  @override
  String get memoryEditRecordButton => 'הקלט';

  @override
  String get memoryEditStopRecordingButton => 'הפסק הקלטה';

  @override
  String get memoryEditRecordingIndicator => 'מקליט...';

  @override
  String get memoryEditReflectionSectionTitle => 'רפלקציה';

  @override
  String get memoryEditEncryptLabel => 'הצפן';

  @override
  String get memoryEditEncryptionInfoTooltip => 'מהי הצפנה?';

  @override
  String get memoryEditImpactPrompt => 'כיצד אירוע זה השפיע עליי?';

  @override
  String get memoryEditLessonPrompt => 'איזה לקח למדתי?';

  @override
  String get memoryEditEmotionsLabel => 'רגשות:';

  @override
  String get emotionJoy => 'שמחה';

  @override
  String get emotionNostalgia => 'נוסטלגיה';

  @override
  String get emotionPride => 'גאווה';

  @override
  String get emotionSadness => 'עצב';

  @override
  String get emotionGratitude => 'הכרת תודה';

  @override
  String get emotionLove => 'אהבה';

  @override
  String get emotionFear => 'פחד';

  @override
  String get emotionAnger => 'כעס';

  @override
  String get memoryEditCbtHelperTitle => 'עוזר רפלקציה';

  @override
  String get memoryEditCbtStep1Title => 'מה הייתה המחשבה או האמונה הראשונה?';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'לדוגמה, \'אני אכשל\' או \'עשיתי הכל נכון\'.';

  @override
  String get memoryEditCbtStep2Title => 'מה תומך במחשבה זו?';

  @override
  String get memoryEditCbtStep2Subtitle =>
      'אילו עובדות או אירועים מוכיחים שמחשבה זו נכונה?';

  @override
  String get memoryEditCbtStep3Title => 'מהי ההשקפה מהצד השני?';

  @override
  String get memoryEditCbtStep3Subtitle =>
      'אילו עובדות או אירועים עשויים להפריך או לאתגר את המחשבה הראשונה?';

  @override
  String get memoryEditCbtStep4Title => 'איך אני יכול להסתכל על זה אחרת?';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'בהתבסס על האמור לעיל, נסח נקודת מבט חדשה ומאוזנת יותר.';

  @override
  String get memoryEditActionPlanTitle => 'תוכנית פעולה';

  @override
  String get memoryEditActionPrompt => 'מהו צעד קטן אחד שאני יכול לעשות?';

  @override
  String get memoryEditReminderLabel => 'תזכורת:';

  @override
  String get memoryEditReminderNotSet => 'לא הוגדרה';

  @override
  String get memoryEditSetReminderButton => 'הגדר תאריך';

  @override
  String get memoryEditYourThoughtsHint => 'המחשבות שלך כאן...';

  @override
  String get memoryEditDraftSavedMessage => 'טיוטה נשמרה';

  @override
  String get memoryEditErrorRepoUnavailable => 'שגיאה: המאגר אינו זמין.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'שגיאה בשמירת הזיכרון: $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'בטל נעילה כדי לשמור';

  @override
  String get memoryEditUnlockDialogContent =>
      'נא להזין את סיסמת המאסטר שלך כדי לשמור את הזיכרון המוצפן הזה.';

  @override
  String get memoryEditMasterPasswordHint => 'סיסמת מאסטר';

  @override
  String get memoryEditUnlockButton => 'בטל נעילה';

  @override
  String get memoryEditEncryptionInfoDialogTitle => 'הצפנה מקצה לקצה';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'כאשר אתה מצפין זיכרון, שדות התיאור והרפלקציה שלו מוצפנים באמצעות מפתח הנגזר מסיסמת המאסטר שלך.\n\nהנתונים מאוחסנים בענן בפורמט לא קריא וניתן לפענח אותם רק במכשירים שלך באמצעות הסיסמה שלך.\n\nחשוב: איננו יכולים לשחזר את סיסמת המאסטר שלך. אם תשכח אותה, הנתונים המוצפנים שלך יאבדו לנצח.';

  @override
  String get memoryEditOkButton => 'אישור';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'ההרשאה עבור $permissionName נדחתה. אנא הפעל אותה בהגדרות.';
  }

  @override
  String get memoryEditSettingsButton => 'הגדרות';

  @override
  String get memoryEditNoInternetSnackbar =>
      'נדרש חיבור לאינטרנט כדי לחפש מוזיקה.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'עוצמה עבור \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'חזור';

  @override
  String get memoryViewShareTooltip => 'שתף';

  @override
  String get memoryViewEditTooltip => 'ערוך';

  @override
  String get memoryViewDeleteTooltip => 'מחק';

  @override
  String get memoryViewTabMemory => 'זיכרון';

  @override
  String get memoryViewTabInTheWorld => 'בעולם';

  @override
  String get memoryViewEncryptedTitle => 'זיכרון מוצפן';

  @override
  String get memoryViewReflectionTitle => 'רפלקציה';

  @override
  String get memoryViewReflectionImpact => 'השפעה';

  @override
  String get memoryViewReflectionLesson => 'לקח שנלמד';

  @override
  String get memoryViewCbtStep1Title => 'מחשבה או אמונה ראשונה';

  @override
  String get memoryViewCbtStep2Title => 'ראיות התומכות במחשבה זו';

  @override
  String get memoryViewCbtStep3Title => 'ראיות הסותרות מחשבה זו';

  @override
  String get memoryViewCbtStep4Title => 'פרספקטיבה חדשה ומאוזנת (מסגור מחדש)';

  @override
  String memoryViewActionReminder(String date) {
    return 'תזכורת: $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'סמן כלא הושלם';

  @override
  String get memoryViewMarkCompleteTooltip => 'סמן כהושלם';

  @override
  String get memoryViewUnlockDialogTitle => 'בטל נעילת זיכרון';

  @override
  String get memoryViewUnlockDialogContent =>
      'הזן את סיסמת המאסטר שלך כדי להציג תוכן זה.';

  @override
  String get memoryViewIncorrectPassword => 'סיסמה שגויה.';

  @override
  String get memoryViewUnlockButton => 'בטל נעילה';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'לא ניתן היה לטעון את הפרופיל שלך כדי להביא נתונים היסטוריים.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'לא ניתן היה לטעון נתונים היסטוריים עבור יום זה.';

  @override
  String get memoryViewNoHistoricalData =>
      'אין נתונים היסטוריים זמינים עבור יום זה.';

  @override
  String get memoryViewErrorCouldNotLoadTrack => 'לא ניתן היה לטעון את הרצועה';

  @override
  String get memoryViewTabNews => 'חדשות';

  @override
  String get memoryViewTabMusic => 'מוזיקה';

  @override
  String get memoryViewNoDataForDay => 'אין נתונים עבור יום זה.';

  @override
  String get memoryViewNoNewsForDay => 'אין חדשות היסטוריות עבור יום זה.';

  @override
  String memoryViewNewsSource(String source) {
    return 'מקור: $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'אשר מחיקה';

  @override
  String get memoryViewConfirmDeleteContent =>
      'פעולה זו אינה הפיכה. כדי להמשיך, לחץ והחזק את לחצן המחיקה למשך 5 שניות.';

  @override
  String get memoryViewDeleteButton => 'מחק';

  @override
  String get memoryViewErrorLoadingProfile =>
      'לא הצלחנו לטעון את הפרופיל שלך. אנא בדוק את החיבור ונסה שוב.';

  @override
  String get memoryViewErrorLocalDb =>
      'שגיאה: לא ניתן לגשת למסד הנתונים המקומי.';

  @override
  String get memoryViewMemoryDeleted => 'הזיכרון נמחק';

  @override
  String get memoryViewSharingNotImplemented =>
      'פונקציונליות השיתוף עדיין לא יושמה.';

  @override
  String get memoryViewActionCompleted => 'הפעולה סומנה כהושלמה!';

  @override
  String get memoryViewActionIncomplete => 'הפעולה סומנה כלא הושלמה.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'שגיאה בעדכון הפעולה: $error';
  }

  @override
  String get memoryViewContentEncrypted => 'התוכן מוצפן';

  @override
  String get memoryViewReflectionEncrypted => 'הרפלקציה מוצפנת';

  @override
  String get memoryViewMediaEncrypted => 'המדיה מוצפנת';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'צליל רקע: $sound';
  }

  @override
  String get memoryViewAudioNote => 'הערה קולית';

  @override
  String get spotifySearchTitle => 'חפש רצועה ב-Spotify';

  @override
  String get spotifySearchHint => 'שם שיר או אמן';

  @override
  String get documentErrorLoading => 'לא ניתן היה לטעון את המסמך.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'זיכרונות: $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'תקופה: $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status (נותרו $jobs)';
  }

  @override
  String get lifelineCalculating => 'מחשב...';

  @override
  String lifelineScaleValue(int scale) {
    return 'קנה מידה: $scale%';
  }

  @override
  String lifelineFpsValue(String fps) {
    return 'FPS: $fps';
  }

  @override
  String lifelineFramePaintValue(int ms) {
    return 'ציור פריים: $ms אלפיות השנייה';
  }

  @override
  String get lifelineShowFullTimelineTooltip => 'הצג ציר זמן מלא';

  @override
  String get lifelineVisualSettingsTooltip => 'הגדרות חזותיות';

  @override
  String get lifelineMenuProfile => 'פרופיל';

  @override
  String get lifelineMenuDebugOn => 'ניפוי באגים פועל';

  @override
  String get lifelineMenuDebugOff => 'ניפוי באגים כבוי';

  @override
  String get lifelineMenuSignOut => 'התנתק';

  @override
  String get lifelineSearchHint => 'חפש...';

  @override
  String get lifelineMemoriesListTitle => 'זיכרונות';

  @override
  String get lifelineVisualSettingsDialogTitle => 'הגדרות חזותיות';

  @override
  String get lifelineVisualSettingsSpeed => 'מהירות';

  @override
  String get lifelineVisualSettingsAmplitude => 'משרעת';

  @override
  String get lifelineVisualSettingsYearLine => 'מיקום קו השנה';

  @override
  String get lifelineVisualSettingsBranchDensity => 'צפיפות ענפים';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'עוצמת ענפים';

  @override
  String get lifelineVisualSettingsAnimate => 'הנפש';

  @override
  String get lifelineVisualSettingsDoneButton => 'סיום';

  @override
  String get onboardingWelcomeTitle => 'ברוכים הבאים ל-Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'המסע האישי שלך, בצורה חזותית. בוא נערוך סיור מהיר כדי לראות איך תוכל להתחיל לתעד את הרגעים שלך.';

  @override
  String get onboardingSkipButton => 'דלג לעת עתה';

  @override
  String get onboardingBeginTourButton => 'התחל סיור';

  @override
  String get onboardingGesturesTitle => 'נווט בציר הזמן שלך';

  @override
  String get onboardingGestureSwipe => 'החלקה';

  @override
  String get onboardingGesturePinch => 'צביטה לזום';

  @override
  String get onboardingGestureDoubleTap => 'הקשה כפולה';

  @override
  String get onboardingGesturesSubtitle =>
      'ציר הזמן שלך יגדל איתך. צבוט לזום, הקש פעמיים לזום מהיר. החלק שמאלה וימינה כדי לנווט בזמן.';

  @override
  String get onboardingContinueButton => 'המשך';

  @override
  String get onboardingFinalTitle => 'אתה מוכן!';

  @override
  String get onboardingFinalSubtitle =>
      'המסע שלך מתחיל עכשיו. התחל לתעד את הרגעים החשובים.';

  @override
  String get onboardingStartJourneyButton => 'התחל את המסע שלי';

  @override
  String get onboardingSkipTourButton => 'דלג על הסיור';

  @override
  String get onboardingLifelineIntroText =>
      'זהו ציר הזמן שלך. כל זיכרון שתוסיף ייצור צומת ייחודי בנתיב זה, וייצור מפה יפה של מסע חייך.';

  @override
  String get onboardingLifelineIntroButton => 'הבא';

  @override
  String get onboardingAddMemoryText =>
      'הקש כאן כדי להוסיף זיכרון חדש. צומת יופיע על ציר הזמן שלך עבור כל רגע שתתעד.';

  @override
  String get onboardingNavGesturesText =>
      'נהדר! עכשיו, בוא נלמד כיצד לנווט בציר הזמן שלך.';

  @override
  String get onboardingControlsPanelText =>
      'השתמש בפקדים אלה כדי לנהל את התצוגה שלך. באפשרותך למרכז מחדש את ציר הזמן, להתאים אפקטים חזותיים ולגשת לפרופיל שלך.';

  @override
  String get onboardingControlsPanelButton => 'הבנתי';

  @override
  String get onboardingStatsCardText =>
      'כרטיס זה מציג סיכום של הזיכרונות שלך. הקש עליו כדי לפתוח רשימה מלאה וניתנת לחיפוש של כל המסע שלך.';

  @override
  String get onboardingStatsCardButton => 'כמעט סיימנו!';

  @override
  String get audioPlayerPreviousTooltip => 'הרצועה הקודמת';

  @override
  String get audioPlayerPlayTooltip => 'נגן';

  @override
  String get audioPlayerPauseTooltip => 'השהה';

  @override
  String get audioPlayerNextTooltip => 'הרצועה הבאה';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'שלב $step: ';
  }

  @override
  String get premiumBannerTitle => 'פתח את Lifeline Premium';

  @override
  String get premiumBannerSubtitle =>
      'מדיה ללא הגבלה, רפלקציה מתקדמת, הקשר היסטורי ועוד!';

  @override
  String get premiumDialogTitle => 'שדרג ל-Premium';

  @override
  String premiumDialogContent(String feature) {
    return 'פתח את היכולת ל$feature וקבל גישה לכל תכונות הפרימיום.';
  }

  @override
  String get premiumDialogGoPremium => 'עבור ל-Premium';

  @override
  String get premiumFeaturePhotos => 'הוספת תמונות נוספות';

  @override
  String get premiumFeatureVideos => 'הוספת וידאו';

  @override
  String get premiumFeatureAudio => 'הוספת הערה קולית';

  @override
  String get premiumFeatureSpotify => 'הוספת רצועת Spotify';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'גלה את מלוא הפוטנציאל שלך';

  @override
  String get premiumScreenHeaderSubtitle =>
      'חצה את הגבולות עם Lifeline Premium והפק את המרב ממסע הגילוי העצמי שלך.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'תמונות וסרטונים ללא הגבלה';

  @override
  String get premiumFeatureUnlimitedAudio => 'הערות קוליות ללא הגבלה';

  @override
  String get premiumFeatureUnlimitedSpotify => 'רצועות Spotify ללא הגבלה';

  @override
  String get premiumFeatureAdvancedCbt => 'עוזר רפלקציה מתקדם';

  @override
  String get premiumFeatureActionReminders => 'תזכורות לתוכנית פעולה';

  @override
  String get premiumFeatureHistoricalContext => 'הקשר היסטורי \'בעולם\'';

  @override
  String get premiumFeatureSoundLibrary => 'ספריית צלילי אווירה מלאה';

  @override
  String get premiumScreenYearlyPopular => 'הפופולרי ביותר והתמורה הטובה ביותר';

  @override
  String get premiumScreenProcessingPurchase => 'מעבד רכישה...';

  @override
  String get premiumScreenRestore => 'שחזר רכישות';

  @override
  String get premiumScreenTerms => 'תנאי שירות';

  @override
  String get premiumScreenPrivacy => 'מדיניות פרטיות';

  @override
  String get premiumStatusTitle => 'חבר פרימיום';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'תוקף עד $date';
  }

  @override
  String get onboardingEncryptionTitle => 'הזיכרונות שלך, מאובטחים';

  @override
  String get onboardingEncryptionSubtitle =>
      'Lifeline מציעה הצפנה מקצה לקצה. זה אומר שרק אתה יכול לקרוא את הזיכרונות הפרטיים שלך. בוא נגדיר את סיסמת המאסטר שלך כדי להגן עליהם.';

  @override
  String get onboardingEncryptionSetupButton => 'הגדר עכשיו';

  @override
  String get onboardingEncryptionLaterButton => 'אולי אחר כך';

  @override
  String get onboardingEncryptionActiveTitle => 'ההצפנה פעילה';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'הזיכרונות שלך כבר מוגנים. תוכל לנהל את סיסמת המאסטר שלך בהגדרות הפרופיל.';

  @override
  String get onboardingEncryptionContinueButton => 'המשך';

  @override
  String get memoryEditEncryptMemory => 'הצפן את הזיכרון הזה';

  @override
  String get memoryEditSetupEncryptionTitle => 'להפעיל הצפנה?';

  @override
  String get memoryEditSetupEncryptionContent =>
      'כדי להגן על זיכרון זה, עליך ליצור תחילה סיסמת מאסטר. זה יהיה המפתח היחיד שלך לכל הערכים המוצפנים.';

  @override
  String get memoryEditCreatePasswordButton => 'צור סיסמת מאסטר';

  @override
  String get memoryViewExportPdf => 'שתף כ-PDF';

  @override
  String get shareActionTitle => 'הוסף ל-Lifeline';

  @override
  String get shareActionSubtitle => 'מה תרצה לעשות עם קבצים אלה?';

  @override
  String get shareCreateNewMemory => 'צור זיכרון חדש';

  @override
  String get shareAddToExisting => 'הוסף לזיכרון קיים';

  @override
  String get selectMemoryTitle => 'בחר זיכרון';

  @override
  String get selectMemorySearchHint => 'חפש לפי כותרת או תוכן...';

  @override
  String get selectMemoryEmpty => 'לא נמצאו זיכרונות';

  @override
  String get memoryUpdatedSuccess => 'הזיכרון עודכן בהצלחה!';

  @override
  String unlockFailedAttemptsRemaining(int count) {
    return 'הסיסמא שגויה. נותרו $count ניסיונות.';
  }

  @override
  String unlockTooManyAttempts(int seconds) {
    return 'מידי נסיונות. נסה שוב בעוד $seconds שניות.';
  }

  @override
  String get unlocking => 'פותח נעילה...';

  @override
  String get exportingPdf => 'מכין קובץ PDF...';

  @override
  String exportFailed(String error) {
    return 'הייצוא נכשל: $error';
  }

  @override
  String get profileEnableQuickUnlock => 'הפעל נעילה מהירה';

  @override
  String get profileQuickUnlockSubtitle =>
      'השתמש בטביעת אצבע, בזיהוי פנים או בקוד ה-PIN של המכשיר כדי לפתוח.';

  @override
  String get profileRequireBiometricsForMemoryTitle =>
      'דרוש אימות ביומטרי לכל זיכרון';

  @override
  String get profileRequireBiometricsForMemorySubtitle =>
      'כאשר האפשרות מופעלת, יידרש אימות כדי לפתוח או לערוך זיכרונות מוצפנים בודדים, גם כאשר האפליקציה פתוחה.';

  @override
  String get quickUnlockPrompt => 'אמת את זהותך כדי לפתוח את Lifeline';

  @override
  String get quickUnlockEnablePrompt => 'אמת את זהותך כדי להפעיל נעילה מהירה';

  @override
  String get masterPasswordRequiredTitle => 'נדרשת סיסמת-על';

  @override
  String get masterPasswordRequiredContent =>
      'הזן את סיסמת-העל שלך כדי להפעיל את התכונה.';

  @override
  String get unlockScreenTitle => 'פתח את Lifeline';

  @override
  String get unlockWithBiometrics => 'פתח באמצעות אימות ביומטרי';

  @override
  String get unlockEnterMasterPassword => 'הזן סיסמת-על';

  @override
  String get unlockForgotPassword => 'שכחת סיסמה?';

  @override
  String get unlockResetEncryptionTitle => 'אפס הצפנה';

  @override
  String get unlockResetEncryptionWarning => '⚠️ אזהרה: לא ניתן לבטל פעולה זו!';

  @override
  String get unlockResetEncryptionDescription =>
      'אם שכחת את סיסמת-העל, תוכל לאפס את ההצפנה. עם זאת, זה ימחק לצמיתות את כל הזיכרונות המוצפנים.';

  @override
  String get unlockResetEncryptionConsequences => 'מה יימחק:';

  @override
  String get unlockResetEncryptionConsequence1 =>
      'כל הזיכרונות המוצפנים (מקומיים ובענן)';

  @override
  String get unlockResetEncryptionConsequence2 => 'ההצפנה תבוטל';

  @override
  String get unlockResetEncryptionConsequence3 =>
      'תוכל להמשיך להשתמש באפליקציה ללא הצפנה';

  @override
  String get unlockResetEncryptionConfirm => 'מחק זיכרונות מוצפנים';

  @override
  String get unlockResetEncryptionSuccess =>
      'ההצפנה אופסה. כעת תוכל להשתמש באפליקציה ללא סיסמת-על.';

  @override
  String get unlockResetEncryptionError => 'איפוס ההצפנה נכשל';

  @override
  String get draftBannerSingleTitle => 'יש לך זיכרון לא גמור';

  @override
  String draftBannerSingleSubtitle(String timeAgo) {
    return 'עריכה אחרונה: $timeAgo';
  }

  @override
  String draftBannerMultipleTitle(int count) {
    return 'יש לך $count זיכרונות לא גמורים';
  }

  @override
  String get draftBannerMultipleSubtitle => 'הקש לצפייה בהכל';

  @override
  String get draftBannerResume => 'המשך';

  @override
  String get draftBannerDelete => 'מחק';

  @override
  String get draftResumedSuccess => 'הטיוטה חודשה בהצלחה';

  @override
  String get draftDeleteDialogTitle => 'למחוק טיוטה?';

  @override
  String get draftDeleteDialogMessage =>
      'טיוטה זו תימחק לצמיתות. לא ניתן לבטל פעולה זו.';

  @override
  String get draftDeleteCancel => 'ביטול';

  @override
  String get draftDeleteConfirm => 'מחק';

  @override
  String get draftDeletedSuccess => 'הטיוטה נמחקה בהצלחה';

  @override
  String get draftDeletedError => 'מחיקת הטיוטה נכשלה';

  @override
  String draftListDialogTitle(int count) {
    return 'יש לך $count טיוטות';
  }

  @override
  String get draftListItemNoTitle => 'זיכרון ללא כותרת';

  @override
  String get draftListItemNoContent => 'אין תוכן';

  @override
  String draftListItemLastModified(String timeAgo) {
    return 'שינוי אחרון: $timeAgo';
  }

  @override
  String get timeAgoJustNow => 'ממש עכשיו';

  @override
  String timeAgoMinutes(int count) {
    return 'לפני $count דקות';
  }

  @override
  String timeAgoHours(int count) {
    return 'לפני $count שעות';
  }

  @override
  String timeAgoDays(int count) {
    return 'לפני $count ימים';
  }

  @override
  String timeAgoWeeks(int count) {
    return 'לפני $count שבועות';
  }

  @override
  String get fileSizeTooLargeImage =>
      'קובץ התמונה גדול מדי. הגודל המרבי הוא 10 מגה-בייט.';

  @override
  String get fileSizeTooLargeVideo =>
      'קובץ הווידאו גדול מדי. הגודל המרבי הוא 100 מגה-בייט.';

  @override
  String get fileSizeTooLargeAudio =>
      'קובץ האודיו גדול מדי. הגודל המרבי הוא 25 מגה-בייט.';

  @override
  String get biometricUnlockFailedMessage =>
      'יש ליצור מחדש מפתחות אבטחה לאחר התקנה מחדש של האפליקציה. אנא הזן את הסיסמה הראשית שלך כדי להמשיך.';

  @override
  String get quickUnlockAutoEnabledMessage =>
      '✓ נעילה ביומטרית הופעלה עבורך באופן אוטומטי!';

  @override
  String lifelineInsightStreakDays(int count) {
    return '🔥 רצף של $count ימים';
  }

  @override
  String lifelineInsightMemoriesThisMonth(int count) {
    return '📝 $count זיכרונות החודש';
  }

  @override
  String lifelineInsightMemoriesThisWeek(int count) {
    return '✨ $count חדשים השבוע';
  }

  @override
  String lifelineInsightReflectionsCount(int count) {
    return '⭐ $count הרהורים';
  }

  @override
  String lifelineInsightPhotosCount(int count) {
    return '📸 $count תמונות';
  }

  @override
  String lifelineInsightAudioCount(int count) {
    return '🎵 $count הערות אודיו';
  }

  @override
  String lifelineInsightSpanningYears(int years) {
    return '📅 משתרע על פני $years שנים';
  }

  @override
  String lifelineInsightTotalMemories(int count) {
    return '📖 $count רגעים שנשמרו';
  }

  @override
  String get lifelineInsightPositiveVibes => '😊 רגשות חיוביים בעיקר';

  @override
  String get lifelineInsightGrowthJourney => '🌱 מסע צמיחה';

  @override
  String get lifelineInsightBalancedEmotions => '⚖️ רגשות מאוזנים';

  @override
  String get lifelineInsightStartJourney => '✍️ התחל את המסע שלך';

  @override
  String get lifelineInsightBuildStreak => '💪 בנה את הרצף שלך';

  @override
  String get purchaseSuccessMessage => 'הרכישה הצליחה! ברוכים הבאים ל-Premium!';

  @override
  String get graphicsQualityTitle => 'איכות גרפיקה';

  @override
  String get graphicsQualityAuto => 'אוטומטי';

  @override
  String get graphicsQualityLow => 'נמוכה';

  @override
  String get graphicsQualityMedium => 'בינונית';

  @override
  String get graphicsQualityHigh => 'גבוהה';

  @override
  String get graphicsQualityAutoSubtitle => 'זיהוי אוטומטי של ביצועי המכשיר';

  @override
  String get graphicsQualityLowSubtitle =>
      'חיי סוללה מירביים, אפקטים מינימליים';

  @override
  String get graphicsQualityMediumSubtitle => 'איזון בין ביצועים לגרפיקה';

  @override
  String get graphicsQualityHighSubtitle => 'גרפיקה מיטבית, צריכת סוללה מוגברת';

  @override
  String graphicsQualityAutoDetected(String performance) {
    return 'אוטומטי ($performance)';
  }

  @override
  String get notificationAnniversaryTitle => 'תזכורות יום השנה';

  @override
  String get notificationAnniversarySubtitle => 'להזכיר רגעים משמעותיים מהעבר';

  @override
  String get notificationMotivationalTitle => 'מוטיבציות מדי פעם';

  @override
  String get notificationMotivationalSubtitle =>
      'תזכורות עדינות לתעד רגעים חשובים';

  @override
  String get notificationInsightTitle => 'תובנות רגשיות';

  @override
  String get notificationInsightSubtitle => 'הרהורים על המסע הרגשי שלך';

  @override
  String get emotionVisualizationTitle => '🎨 Emotion Visualization';

  @override
  String get emotionVisualizationSubtitle => 'Customize emotion display';

  @override
  String get emotionVisualizationTimelineSection => 'On the lifeline:';

  @override
  String get emotionVisualizationLevel1Title => 'Level 1: Yearly Gradient';

  @override
  String get emotionVisualizationLevel1Subtitle =>
      'Overall emotion glow (zoom < 250%)';

  @override
  String get emotionVisualizationLevel2Title => 'Level 2: Monthly Clusters';

  @override
  String get emotionVisualizationLevel2Subtitle =>
      'Emotions by month (zoom 250%-460%)';

  @override
  String get emotionVisualizationLevel3Title => 'Level 3: Node Aura';

  @override
  String get emotionVisualizationLevel3Subtitle =>
      'Glow around nodes (zoom > 460%)';

  @override
  String get emotionVisualizationEnable => 'Enable';

  @override
  String get emotionVisualizationIntensity => 'Intensity';

  @override
  String get emotionVisualizationRadius => 'Radius';

  @override
  String get emotionVisualizationRadiusMultiplier => 'Radius (multiplier)';

  @override
  String get emotionVisualizationBlur => 'Blur';

  @override
  String get emotionVisualizationBlurMultiplier => 'Blur (multiplier)';

  @override
  String get emotionVisualizationSaturation => 'Saturation';

  @override
  String get emotionVisualizationMemoryViewSection => 'When viewing memory:';

  @override
  String get emotionVisualizationMemoryGradientTitle => 'Emotion gradient';

  @override
  String get emotionVisualizationMemoryGradientSubtitle =>
      'Colored background based on emotions';

  @override
  String get emotionVisualizationMemoryParticlesTitle => 'Emotion particles';

  @override
  String get emotionVisualizationMemoryParticlesSubtitle =>
      'Animated particles (Premium)';

  @override
  String get emotionVisualizationPhotoColorGradingTitle =>
      'Photo color grading';

  @override
  String get emotionVisualizationPhotoColorGradingSubtitle =>
      'Adjust photos to emotions (Premium)';
}
