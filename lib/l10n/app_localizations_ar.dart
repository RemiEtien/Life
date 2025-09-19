// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get register => 'التسجيل';

  @override
  String get createAccount => 'إنشاء حساب جديد';

  @override
  String get alreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get orSignInWith => 'أو سجل الدخول باستخدام';

  @override
  String get passwordTooShort => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get invalidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get consentWelcomeTitle => 'مرحباً بك في Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'قبل أن تبدأ، يرجى مراجعة شروطنا والموافقة عليها.';

  @override
  String get consentIAgreeTo => 'لقد قرأت ووافقت على ';

  @override
  String get consentTermsOfService => 'شروط الخدمة';

  @override
  String get consentAnd => ' و ';

  @override
  String get consentPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get consentContinue => 'متابعة';

  @override
  String consentErrorSaving(String error) {
    return 'خطأ في حفظ الإعدادات: $error';
  }

  @override
  String get splashMessageInitializing => 'جاري التهيئة...';

  @override
  String get splashMessageCheckingSettings => 'جاري التحقق من الإعدادات...';

  @override
  String get splashMessageAuthenticating => 'جاري المصادقة...';

  @override
  String get splashMessageSyncing => 'جاري مزامنة خطك الزمني...';

  @override
  String get authGateLoadingMemories => 'جاري تحميل الذكريات...';

  @override
  String get authGateAuthenticating => 'جاري المصادقة...';

  @override
  String get authGateSomethingWentWrong => 'حدث خطأ ما';

  @override
  String get authGateCouldNotLoad =>
      'لم نتمكن من تحميل بياناتك. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';

  @override
  String get authGateTryAgain => 'المحاولة مرة أخرى';

  @override
  String get authGateEmptyState =>
      'خط Lifeline الخاص بك جاهز.\nاضغط على زر + لإضافة ذاكرتك الأولى.';

  @override
  String get authGateUnsavedDraftTitle => 'ذاكرة غير محفوظة';

  @override
  String get authGateUnsavedDraftContent =>
      'لديك مسودة ذاكرة غير محفوظة. هل تريد متابعة تحريرها؟';

  @override
  String get authGateDiscard => 'تجاهل';

  @override
  String get authGateContinueEditing => 'متابعة التحرير';

  @override
  String get verifyEmailTitle => 'تأكيد البريد الإلكتروني';

  @override
  String get verifyEmailSentTo => 'تم إرسال بريد إلكتروني للتحقق إلى:';

  @override
  String get verifyEmailInstructions =>
      'الرجاء النقر على الرابط في البريد الإلكتروني لإكمال تسجيلك.';

  @override
  String get verifyEmailResendButton => 'إعادة إرسال البريد الإلكتروني';

  @override
  String get verifyEmailCancelButton => 'إلغاء';

  @override
  String get profileTitle => 'الملف الشخصي والإعدادات';

  @override
  String get profileSectionProfile => 'الملف الشخصي';

  @override
  String get profileChangeNameTitle => 'تغيير الاسم';

  @override
  String get profileEnterYourName => 'أدخل اسمك';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileCancel => 'إلغاء';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profileCountry => 'البلد';

  @override
  String get profileCountryNotSelected => 'لم يتم الاختيار';

  @override
  String get profileLanguage => 'لغة المحتوى';

  @override
  String get profileLanguageDefault => 'الإنجليزية (الافتراضية)';

  @override
  String get profileSelectLanguage => 'اختر اللغة';

  @override
  String get profileSectionSettings => 'الإعدادات';

  @override
  String get profileTheme => 'المظهر';

  @override
  String get profileThemeSystem => 'النظام';

  @override
  String get profileThemeLight => 'فاتح';

  @override
  String get profileThemeDark => 'داكن';

  @override
  String get profileReauthTitle => 'إعادة المصادقة مطلوبة';

  @override
  String get profileReauthContent =>
      'هذه عملية حساسة. يرجى تسجيل الدخول مرة أخرى قبل المتابعة.';

  @override
  String get profileReauthButton => 'تسجيل الدخول والحذف';

  @override
  String get profileReauthPasswordDialogTitle => 'تأكيد الإجراء';

  @override
  String get profileReauthPasswordDialogContent =>
      'لحذف حسابك، يرجى إدخال كلمة المرور الحالية.';

  @override
  String get profilePasswordCannotBeEmpty =>
      'لا يمكن أن تكون كلمة المرور فارغة';

  @override
  String get profileChangePasswordSuccess =>
      'تم تغيير كلمة المرور الرئيسية بنجاح!';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'كلمة المرور الرئيسية الحالية التي أدخلتها غير صحيحة.';

  @override
  String get profileOldPasswordHint => 'كلمة المرور القديمة';

  @override
  String get profileNewPasswordHint => 'كلمة المرور الجديدة';

  @override
  String get profileDeleteAccountConfirmContent =>
      'هذا الإجراء لا رجعة فيه. سيتم حذف حسابك بالكامل، بما في ذلك جميع الذكريات والإعدادات، بشكل دائم. للمتابعة، اضغط مع الاستمرار على زر الحذف لمدة 5 ثوانٍ.';

  @override
  String get profileChangePasswordCurrentPasswordHint =>
      'كلمة المرور الرئيسية الحالية';

  @override
  String get profileChangePasswordNewPasswordHint =>
      'كلمة المرور الرئيسية الجديدة';

  @override
  String get profileChangePasswordInfo =>
      'الرجاء إدخال كلمة المرور الرئيسية الحالية لتعيين كلمة مرور جديدة. سيؤدي هذا إلى إعادة تشفير مفتاحك السري.';

  @override
  String get profileGraphics => 'جودة الرسومات';

  @override
  String get profileGraphicsAuto => 'تلقائي';

  @override
  String get profileGraphicsLow => 'منخفضة';

  @override
  String get profileGraphicsMedium => 'متوسطة';

  @override
  String get profileGraphicsHigh => 'عالية';

  @override
  String get profileReminders => 'تذكيرات بالتأمل';

  @override
  String get profileRemindersSubtitle => 'تلقي إشعارات لخطط العمل الخاصة بك';

  @override
  String get profileSectionSecurity => 'الأمان';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور الرئيسية';

  @override
  String get profileEncryptionActive => 'التشفير من طرف إلى طرف نشط';

  @override
  String get profileEnableEncryption => 'تمكين التشفير من طرف إلى طرف';

  @override
  String get profileEnableEncryptionSubtitle =>
      'احمِ ذكرياتك الحساسة بكلمة مرور رئيسية.';

  @override
  String get profileCreateMasterPassword => 'إنشاء كلمة مرور رئيسية';

  @override
  String get profileMasterPasswordInfo =>
      'ستحمي كلمة المرور هذه ذكرياتك. لا يمكن استعادتها إذا نسيتها. يرجى تخزينها بأمان.';

  @override
  String get profileMasterPasswordHint => 'كلمة المرور الرئيسية';

  @override
  String get profileConfirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get profilePasswordMinLength =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get profilePasswordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get profileEnable => 'تمكين';

  @override
  String get profileSectionHelp => 'المساعدة';

  @override
  String get profileReplayTutorial => 'إعادة تشغيل البرنامج التعليمي';

  @override
  String get profileReplayTutorialConfirmTitle =>
      'إعادة تشغيل البرنامج التعليمي؟';

  @override
  String get profileReplayTutorialConfirmContent =>
      'هل أنت متأكد من أنك تريد إعادة تشغيل البرنامج التعليمي؟';

  @override
  String get profileRestart => 'إعادة التشغيل';

  @override
  String get profileSectionAccount => 'إدارة الحساب';

  @override
  String get profileSignOut => 'تسجيل الخروج';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileDeleteAccountConfirmTitle => 'حذف الحساب؟';

  @override
  String get profileDelete => 'حذف';

  @override
  String get profileDeletingAccount => 'جاري حذف حسابك...';

  @override
  String get profileErrorCouldNotFindProfile =>
      'تعذر العثور على ملف تعريف المستخدم.';

  @override
  String get memoryEditNewTitle => 'ذاكرة جديدة';

  @override
  String get memoryEditEditTitle => 'تحرير الذاكرة';

  @override
  String get memoryEditSave => 'حفظ';

  @override
  String get memoryEditTitleHint => 'العنوان';

  @override
  String get memoryEditTitleValidator => 'الرجاء إدخال عنوان';

  @override
  String get memoryEditDescriptionHint => 'الوصف';

  @override
  String get memoryEditDateLabel => 'التاريخ:';

  @override
  String get memoryEditSelectDateButton => 'اختيار التاريخ';

  @override
  String get memoryEditAmbientSoundLabel => 'الصوت المحيط:';

  @override
  String get memoryEditAmbientSoundDropdownHint => 'اختر صوتاً محيطاً';

  @override
  String get memoryEditMusicAnchorLabel => 'مرساة الموسيقى:';

  @override
  String get memoryEditAttachTrackButton => 'إرفاق مسار من Spotify';

  @override
  String get memoryEditPhotosLabel => 'الصور:';

  @override
  String get memoryEditNoPhotosSelected => 'لم يتم اختيار صور';

  @override
  String get memoryEditAddPhotosButton => 'إضافة صور';

  @override
  String get memoryEditVideosLabel => 'مقاطع الفيديو:';

  @override
  String get memoryEditNoVideosSelected => 'لم يتم اختيار مقاطع فيديو';

  @override
  String get memoryEditAddVideoButton => 'إضافة فيديو';

  @override
  String get memoryEditAudioNoteLabel => 'ملاحظة صوتية:';

  @override
  String get memoryEditAudioNoteSaved => 'تم حفظ الملاحظة الصوتية';

  @override
  String get memoryEditRecordButton => 'تسجيل';

  @override
  String get memoryEditStopRecordingButton => 'إيقاف التسجيل';

  @override
  String get memoryEditRecordingIndicator => 'جاري التسجيل...';

  @override
  String get memoryEditReflectionSectionTitle => 'تأمل';

  @override
  String get memoryEditEncryptLabel => 'تشفير';

  @override
  String get memoryEditEncryptionInfoTooltip => 'ما هو التشفير؟';

  @override
  String get memoryEditImpactPrompt => 'كيف أثر هذا الحدث علي؟';

  @override
  String get memoryEditLessonPrompt => 'ما الدرس الذي تعلمته؟';

  @override
  String get memoryEditEmotionsLabel => 'المشاعر:';

  @override
  String get emotionJoy => 'فرح';

  @override
  String get emotionNostalgia => 'حنين';

  @override
  String get emotionPride => 'فخر';

  @override
  String get emotionSadness => 'حزن';

  @override
  String get emotionGratitude => 'امتنان';

  @override
  String get emotionLove => 'حب';

  @override
  String get emotionFear => 'خوف';

  @override
  String get emotionAnger => 'غضب';

  @override
  String get memoryEditCbtHelperTitle => 'مساعد التأمل';

  @override
  String get memoryEditCbtStep1Title => 'ما هو أول فكرة أو اعتقاد؟';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'مثال: \'سأفشل\' أو \'فعلت كل شيء بشكل صحيح\'.';

  @override
  String get memoryEditCbtStep2Title => 'ما الذي يدعم هذه الفكرة؟';

  @override
  String get memoryEditCbtStep2Subtitle =>
      'ما هي الحقائق أو الأحداث التي تثبت صحة هذه الفكرة؟';

  @override
  String get memoryEditCbtStep3Title => 'ما هي وجهة النظر من الجانب الآخر؟';

  @override
  String get memoryEditCbtStep3Subtitle =>
      'ما هي الحقائق أو الأحداث التي قد تدحض أو تتحدى الفكرة الأولى؟';

  @override
  String get memoryEditCbtStep4Title =>
      'كيف يمكنني أن أنظر إلى هذا بشكل مختلف؟';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'بناءً على ما سبق، قم بصياغة منظور جديد أكثر توازناً.';

  @override
  String get memoryEditActionPlanTitle => 'خطة العمل';

  @override
  String get memoryEditActionPrompt =>
      'ما هي الخطوة الصغيرة التي يمكنني اتخاذها؟';

  @override
  String get memoryEditReminderLabel => 'تذكير:';

  @override
  String get memoryEditReminderNotSet => 'غير محدد';

  @override
  String get memoryEditSetReminderButton => 'تحديد التاريخ';

  @override
  String get memoryEditYourThoughtsHint => 'أفكارك هنا...';

  @override
  String get memoryEditDraftSavedMessage => 'تم حفظ المسودة';

  @override
  String get memoryEditErrorRepoUnavailable => 'خطأ: المستودع غير متوفر.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'خطأ في حفظ الذاكرة: $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'فتح للحفظ';

  @override
  String get memoryEditUnlockDialogContent =>
      'الرجاء إدخال كلمة المرور الرئيسية لحفظ هذه الذاكرة المشفرة.';

  @override
  String get memoryEditMasterPasswordHint => 'كلمة المرور الرئيسية';

  @override
  String get memoryEditUnlockButton => 'فتح';

  @override
  String get memoryEditEncryptionInfoDialogTitle => 'التشفير من طرف إلى طرف';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'عند تشفير ذاكرة، يتم تشويش حقلي الوصف والتأمل باستخدام مفتاح مشتق من كلمة المرور الرئيسية الخاصة بك.\n\nيتم تخزين البيانات بتنسيق غير قابل للقراءة في السحابة ولا يمكن فك تشفيرها إلا على أجهزتك باستخدام كلمة المرور الخاصة بك.\n\nهام: لا يمكننا استعادة كلمة المرور الرئيسية الخاصة بك. إذا نسيتها، فستفقد بياناتك المشفرة إلى الأبد.';

  @override
  String get memoryEditOkButton => 'موافق';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'تم رفض الإذن لـ $permissionName. يرجى تمكينه في الإعدادات.';
  }

  @override
  String get memoryEditSettingsButton => 'الإعدادات';

  @override
  String get memoryEditNoInternetSnackbar =>
      'مطلوب اتصال بالإنترنت للبحث عن الموسيقى.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'شدة \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'رجوع';

  @override
  String get memoryViewShareTooltip => 'مشاركة';

  @override
  String get memoryViewEditTooltip => 'تحرير';

  @override
  String get memoryViewDeleteTooltip => 'حذف';

  @override
  String get memoryViewTabMemory => 'الذاكرة';

  @override
  String get memoryViewTabInTheWorld => 'في العالم';

  @override
  String get memoryViewEncryptedTitle => 'ذاكرة مشفرة';

  @override
  String get memoryViewReflectionTitle => 'تأمل';

  @override
  String get memoryViewReflectionImpact => 'التأثير';

  @override
  String get memoryViewReflectionLesson => 'الدرس المستفاد';

  @override
  String get memoryViewCbtStep1Title => 'أول فكرة أو اعتقاد';

  @override
  String get memoryViewCbtStep2Title => 'دليل على هذه الفكرة';

  @override
  String get memoryViewCbtStep3Title => 'دليل ضد هذه الفكرة';

  @override
  String get memoryViewCbtStep4Title => 'منظور جديد ومتوازن (إعادة صياغة)';

  @override
  String memoryViewActionReminder(String date) {
    return 'تذكير: $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'وضع علامة كغير مكتمل';

  @override
  String get memoryViewMarkCompleteTooltip => 'وضع علامة كمكتمل';

  @override
  String get memoryViewUnlockDialogTitle => 'فتح الذاكرة';

  @override
  String get memoryViewUnlockDialogContent =>
      'أدخل كلمة المرور الرئيسية لعرض هذا المحتوى.';

  @override
  String get memoryViewIncorrectPassword => 'كلمة المرور غير صحيحة.';

  @override
  String get memoryViewUnlockButton => 'فتح';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'تعذر تحميل ملف التعريف الخاص بك لجلب البيانات التاريخية.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'تعذر تحميل البيانات التاريخية لهذا اليوم.';

  @override
  String get memoryViewNoHistoricalData =>
      'لا توجد بيانات تاريخية متاحة لهذا اليوم.';

  @override
  String get memoryViewErrorCouldNotLoadTrack => 'تعذر تحميل المسار';

  @override
  String get memoryViewTabNews => 'الأخبار';

  @override
  String get memoryViewTabMusic => 'الموسيقى';

  @override
  String get memoryViewNoDataForDay => 'لا توجد بيانات لهذا اليوم.';

  @override
  String get memoryViewNoNewsForDay => 'لا توجد أخبار تاريخية لهذا اليوم.';

  @override
  String memoryViewNewsSource(String source) {
    return 'المصدر: $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'تأكيد الحذف';

  @override
  String get memoryViewConfirmDeleteContent =>
      'هذا الإجراء لا رجعة فيه. للمتابعة، اضغط مع الاستمرار على زر الحذف لمدة 5 ثوان.';

  @override
  String get memoryViewDeleteButton => 'حذف';

  @override
  String get memoryViewErrorLoadingProfile =>
      'لم نتمكن من تحميل ملف التعريف الخاص بك. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';

  @override
  String get memoryViewErrorLocalDb =>
      'خطأ: تعذر الوصول إلى قاعدة البيانات المحلية.';

  @override
  String get memoryViewMemoryDeleted => 'تم حذف الذاكرة';

  @override
  String get memoryViewSharingNotImplemented =>
      'لم يتم تنفيذ وظيفة المشاركة بعد.';

  @override
  String get memoryViewActionCompleted => 'تم وضع علامة على الإجراء كمكتمل!';

  @override
  String get memoryViewActionIncomplete =>
      'تم وضع علامة على الإجراء كغير مكتمل.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'خطأ في تحديث الإجراء: $error';
  }

  @override
  String get memoryViewContentEncrypted => 'المحتوى مشفر';

  @override
  String get memoryViewReflectionEncrypted => 'التأمل مشفر';

  @override
  String get memoryViewMediaEncrypted => 'الوسائط مشفرة';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'الصوت المحيط: $sound';
  }

  @override
  String get memoryViewAudioNote => 'ملاحظة صوتية';

  @override
  String get spotifySearchTitle => 'البحث عن مسار Spotify';

  @override
  String get spotifySearchHint => 'عنوان الأغنية أو الفنان';

  @override
  String get documentErrorLoading => 'تعذر تحميل المستند.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'الذكريات: $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'الفترة: $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status ($jobs متبقية)';
  }

  @override
  String get lifelineCalculating => 'جاري الحساب...';

  @override
  String lifelineScaleValue(int scale) {
    return 'المقياس: $scale%';
  }

  @override
  String lifelineFpsValue(String fps) {
    return 'معدل الإطارات: $fps';
  }

  @override
  String lifelineFramePaintValue(int ms) {
    return 'رسم الإطار: $ms مللي ثانية';
  }

  @override
  String get lifelineShowFullTimelineTooltip => 'عرض الخط الزمني الكامل';

  @override
  String get lifelineVisualSettingsTooltip => 'الإعدادات المرئية';

  @override
  String get lifelineMenuProfile => 'الملف الشخصي';

  @override
  String get lifelineMenuDebugOn => 'تشغيل التصحيح';

  @override
  String get lifelineMenuDebugOff => 'إيقاف التصحيح';

  @override
  String get lifelineMenuSignOut => 'تسجيل الخروج';

  @override
  String get lifelineSearchHint => 'بحث...';

  @override
  String get lifelineMemoriesListTitle => 'الذكريات';

  @override
  String get lifelineVisualSettingsDialogTitle => 'الإعدادات المرئية';

  @override
  String get lifelineVisualSettingsSpeed => 'السرعة';

  @override
  String get lifelineVisualSettingsAmplitude => 'السعة';

  @override
  String get lifelineVisualSettingsYearLine => 'موضع خط السنة';

  @override
  String get lifelineVisualSettingsBranchDensity => 'كثافة الفروع';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'شدة الفروع';

  @override
  String get lifelineVisualSettingsAnimate => 'تحريك';

  @override
  String get lifelineVisualSettingsDoneButton => 'تم';

  @override
  String get onboardingWelcomeTitle => 'مرحباً بك في Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'رحلتك الشخصية، مصورة. لنأخذ جولة سريعة لنرى كيف يمكنك البدء في التقاط لحظاتك.';

  @override
  String get onboardingSkipButton => 'تخطي الآن';

  @override
  String get onboardingBeginTourButton => 'بدء الجولة';

  @override
  String get onboardingGesturesTitle => 'تنقل في خطك الزمني';

  @override
  String get onboardingGestureSwipe => 'اسحب';

  @override
  String get onboardingGesturePinch => 'اضغط للتكبير';

  @override
  String get onboardingGesturesSubtitle =>
      'سينمو خط Lifeline الخاص بك معك. اضغط للتصغير ورؤية الصورة الأكبر. اسحب لليسار واليمين للتنقل عبر الزمن.';

  @override
  String get onboardingContinueButton => 'متابعة';

  @override
  String get onboardingFinalTitle => 'أنت جاهز تماماً!';

  @override
  String get onboardingFinalSubtitle =>
      'رحلتك تبدأ الآن. ابدأ في التقاط اللحظات المهمة.';

  @override
  String get onboardingStartJourneyButton => 'بدء رحلتي';

  @override
  String get onboardingSkipTourButton => 'تخطي الجولة';

  @override
  String get onboardingLifelineIntroText =>
      'هذا هو خط Lifeline الخاص بك. كل ذاكرة تضيفها ستنشئ عقدة فريدة على هذا المسار، لتشكل خريطة جميلة لرحلة حياتك.';

  @override
  String get onboardingLifelineIntroButton => 'التالي';

  @override
  String get onboardingAddMemoryText =>
      'اضغط هنا لإضافة ذاكرة جديدة. ستظهر عقدة على خط Lifeline الخاص بك لكل لحظة تلتقطها.';

  @override
  String get onboardingNavGesturesText =>
      'عظيم! الآن، لنتعلم كيفية التنقل في خطك الزمني.';

  @override
  String get onboardingControlsPanelText =>
      'استخدم هذه الضوابط لإدارة عرضك. يمكنك إعادة توسيط الخط الزمني، وضبط التأثيرات المرئية، والوصول إلى ملفك الشخصي.';

  @override
  String get onboardingControlsPanelButton => 'فهمت';

  @override
  String get onboardingStatsCardText =>
      'تعرض هذه البطاقة ملخصاً لذكرياتك. اضغط عليها لفتح قائمة كاملة وقابلة للبحث لرحلتك بأكملها.';

  @override
  String get onboardingStatsCardButton => 'أوشكنا على الانتهاء!';

  @override
  String get audioPlayerPreviousTooltip => 'المسار السابق';

  @override
  String get audioPlayerPlayTooltip => 'تشغيل';

  @override
  String get audioPlayerPauseTooltip => 'إيقاف مؤقت';

  @override
  String get audioPlayerNextTooltip => 'المسار التالي';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'الخطوة $step: ';
  }

  @override
  String get premiumBannerTitle => 'افتح Lifeline Premium';

  @override
  String get premiumBannerSubtitle =>
      'وسائط غير محدودة، تأمل متقدم، سياق تاريخي، والمزيد!';

  @override
  String get premiumDialogTitle => 'الترقية إلى Premium';

  @override
  String premiumDialogContent(String feature) {
    return 'افتح القدرة على $feature واحصل على وصول إلى جميع ميزات Premium.';
  }

  @override
  String get premiumDialogGoPremium => 'اذهب إلى Premium';

  @override
  String get premiumFeaturePhotos => 'إضافة المزيد من الصور';

  @override
  String get premiumFeatureVideos => 'إضافة فيديو';

  @override
  String get premiumFeatureAudio => 'إضافة ملاحظة صوتية';

  @override
  String get premiumFeatureSpotify => 'إضافة مسار Spotify';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'أطلق العنان لإمكانياتك الكاملة';

  @override
  String get premiumScreenHeaderSubtitle =>
      'تجاوز الحدود مع Lifeline Premium واستفد إلى أقصى حد من رحلتك لاكتشاف الذات.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'صور وفيديوهات غير محدودة';

  @override
  String get premiumFeatureUnlimitedAudio => 'ملاحظات صوتية غير محدودة';

  @override
  String get premiumFeatureUnlimitedSpotify => 'مسارات Spotify غير محدودة';

  @override
  String get premiumFeatureAdvancedCbt => 'مساعد تأمل متقدم';

  @override
  String get premiumFeatureActionReminders => 'تذكيرات خطة العمل';

  @override
  String get premiumFeatureHistoricalContext => 'سياق تاريخي \'في العالم\'';

  @override
  String get premiumFeatureSoundLibrary => 'مكتبة أصوات محيطة كاملة';

  @override
  String get premiumScreenYearlyPopular => 'الأكثر شيوعًا وأفضل قيمة';

  @override
  String get premiumScreenRestore => 'استعادة المشتريات';

  @override
  String get premiumScreenTerms => 'شروط الخدمة';

  @override
  String get premiumScreenPrivacy => 'سياسة الخصوصية';

  @override
  String get premiumStatusTitle => 'عضو مميز';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'ينتهي في $date';
  }

  @override
  String get onboardingEncryptionTitle => 'ذكرياتك، آمنة';

  @override
  String get onboardingEncryptionSubtitle =>
      'يقدم Lifeline تشفيراً من طرف إلى طرف. هذا يعني أنك أنت فقط من يمكنه قراءة ذكرياتك الخاصة. لنقم بإعداد كلمة المرور الرئيسية الخاصة بك لحمايتها.';

  @override
  String get onboardingEncryptionSetupButton => 'الإعداد الآن';

  @override
  String get onboardingEncryptionLaterButton => 'ربما لاحقًا';

  @override
  String get onboardingEncryptionActiveTitle => 'التشفير نشط';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'ذكرياتك محمية بالفعل. يمكنك إدارة كلمة المرور الرئيسية في إعدادات الملف الشخصي.';

  @override
  String get onboardingEncryptionContinueButton => 'متابعة';

  @override
  String get memoryEditEncryptMemory => 'تشفير هذا الذاكرة';

  @override
  String get memoryEditSetupEncryptionTitle => 'تمكين التشفير؟';

  @override
  String get memoryEditSetupEncryptionContent =>
      'لحماية هذه الذاكرة، تحتاج أولاً إلى إنشاء كلمة مرور رئيسية. ستكون هذه مفتاحك الوحيد لجميع الإدخالات المشفرة.';

  @override
  String get memoryEditCreatePasswordButton => 'إنشاء كلمة مرور رئيسية';

  @override
  String get memoryViewExportPdf => 'مشاركة كملف PDF';
}
