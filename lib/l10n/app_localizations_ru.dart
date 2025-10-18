// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get createAccount => 'Создать новый аккаунт';

  @override
  String get alreadyHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get orSignInWith => 'Или войдите с помощью';

  @override
  String get passwordTooShort => 'Пароль должен содержать не менее 6 символов';

  @override
  String get invalidEmail =>
      'Пожалуйста, введите действительный адрес электронной почты';

  @override
  String get consentWelcomeTitle => 'Добро пожаловать в Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'Прежде чем начать, пожалуйста, ознакомьтесь и согласитесь с нашими условиями.';

  @override
  String get consentIAgreeTo => 'Я прочитал(а) и согласен(на) с ';

  @override
  String get consentTermsOfService => 'Условиями обслуживания';

  @override
  String get consentAnd => ' и ';

  @override
  String get consentPrivacyPolicy => 'Политикой конфиденциальности';

  @override
  String get consentContinue => 'Продолжить';

  @override
  String consentErrorSaving(String error) {
    return 'Ошибка сохранения настроек: $error';
  }

  @override
  String get splashMessageInitializing => 'Инициализация...';

  @override
  String get splashMessageCheckingSettings => 'Проверка настроек...';

  @override
  String get splashMessageAuthenticating => 'Аутентификация...';

  @override
  String get splashMessageSyncing => 'Синхронизация вашей линии жизни...';

  @override
  String get authGateLoadingMemories => 'Загрузка воспоминаний...';

  @override
  String get authGateAuthenticating => 'Аутентификация...';

  @override
  String get authGateSomethingWentWrong => 'Что-то пошло не так';

  @override
  String get authGateCouldNotLoad =>
      'Не удалось загрузить ваши данные. Пожалуйста, проверьте соединение и попробуйте снова.';

  @override
  String get authGateTryAgain => 'Попробовать снова';

  @override
  String get authGateEmptyState =>
      'Ваша линия жизни готова.\nНажмите кнопку +, чтобы добавить первое воспоминание.';

  @override
  String get authGateUnsavedDraftTitle => 'Несохраненное воспоминание';

  @override
  String get authGateUnsavedDraftContent =>
      'У вас есть несохраненный черновик воспоминания. Хотите продолжить редактирование?';

  @override
  String get authGateDiscard => 'Удалить';

  @override
  String get authGateContinueEditing => 'Продолжить';

  @override
  String get verifyEmailTitle => 'Подтверждение почты';

  @override
  String get verifyEmailSentTo =>
      'Письмо с подтверждением было отправлено на адрес:';

  @override
  String get verifyEmailInstructions =>
      'Пожалуйста, перейдите по ссылке в письме, чтобы завершить регистрацию.';

  @override
  String get verifyEmailResendButton => 'Отправить письмо еще раз';

  @override
  String get verifyEmailCancelButton => 'Отмена';

  @override
  String get profileTitle => 'Профиль и настройки';

  @override
  String get profileSectionProfile => 'ПРОФИЛЬ';

  @override
  String get profileChangeNameTitle => 'Изменить имя';

  @override
  String get profileEnterYourName => 'Введите ваше имя';

  @override
  String get profileSave => 'Сохранить';

  @override
  String get profileCancel => 'Отмена';

  @override
  String get profileName => 'Имя';

  @override
  String get profileEmail => 'Электронная почта';

  @override
  String get profileCountry => 'Страна';

  @override
  String get profileCountryNotSelected => 'Не выбрана';

  @override
  String get profileLanguage => 'Язык контента';

  @override
  String get profileLanguageDefault => 'Английский (по умолчанию)';

  @override
  String get profileSelectLanguage => 'Выберите язык';

  @override
  String get profileSectionSettings => 'НАСТРОЙКИ';

  @override
  String get profileTheme => 'Тема';

  @override
  String get profileThemeSystem => 'Системная';

  @override
  String get profileThemeLight => 'Светлая';

  @override
  String get profileThemeDark => 'Темная';

  @override
  String get profileReauthTitle => 'Требуется повторная аутентификация';

  @override
  String get profileReauthContent =>
      'Это конфиденциальная операция. Пожалуйста, войдите в аккаунт еще раз, прежде чем продолжить.';

  @override
  String get profileReauthButton => 'Войти и удалить';

  @override
  String get profileReauthPasswordDialogTitle => 'Подтвердите действие';

  @override
  String get profileReauthPasswordDialogContent =>
      'Чтобы удалить аккаунт, пожалуйста, введите ваш текущий пароль.';

  @override
  String get profilePasswordCannotBeEmpty => 'Пароль не может быть пустым';

  @override
  String get profileChangePasswordSuccess => 'Мастер-пароль успешно изменен!';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'Введенный текущий пароль неверен.';

  @override
  String get profileOldPasswordHint => 'Старый пароль';

  @override
  String get profileNewPasswordHint => 'Новый пароль';

  @override
  String get profileDeleteAccountConfirmContent =>
      'Это действие необратимо. Весь ваш аккаунт, включая все воспоминания и настройки, будет удален навсегда. Чтобы продолжить, нажмите и удерживайте кнопку удаления в течение 5 секунд.';

  @override
  String get profileChangePasswordCurrentPasswordHint =>
      'Текущий мастер-пароль';

  @override
  String get profileChangePasswordNewPasswordHint => 'Новый мастер-пароль';

  @override
  String get profileChangePasswordInfo =>
      'Пожалуйста, введите ваш текущий мастер-пароль, чтобы установить новый. Это перешифрует ваш секретный ключ.';

  @override
  String get profileGraphics => 'Качество графики';

  @override
  String get profileGraphicsAuto => 'Автоматически';

  @override
  String get profileGraphicsLow => 'Низкое';

  @override
  String get profileGraphicsMedium => 'Среднее';

  @override
  String get profileGraphicsHigh => 'Высокое';

  @override
  String get profileReminders => 'Напоминания о рефлексии';

  @override
  String get profileRemindersSubtitle =>
      'Получайте уведомления о ваших планах действий';

  @override
  String get profileSectionSecurity => 'БЕЗОПАСНОСТЬ';

  @override
  String get profileChangePassword => 'Изменить мастер-пароль';

  @override
  String get profileEncryptionActive => 'Сквозное шифрование активно';

  @override
  String get profileEnableEncryption => 'Включить сквозное шифрование';

  @override
  String get profileEnableEncryptionSubtitle =>
      'Защитите свои личные воспоминания мастер-паролем.';

  @override
  String get profileCreateMasterPassword => 'Создать мастер-пароль';

  @override
  String get profileMasterPasswordInfo =>
      'Этот пароль защитит ваши воспоминания. Его невозможно восстановить, если вы его забудете. Пожалуйста, храните его в безопасном месте.';

  @override
  String get profileMasterPasswordHint => 'Мастер-пароль';

  @override
  String get profileConfirmPasswordHint => 'Подтвердите пароль';

  @override
  String get profilePasswordMinLength =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get profilePasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get profileEnable => 'Включить';

  @override
  String get profileSectionHelp => 'ПОМОЩЬ';

  @override
  String get profileReplayTutorial => 'Повторить обучение';

  @override
  String get profileReplayTutorialConfirmTitle => 'Повторить обучение?';

  @override
  String get profileReplayTutorialConfirmContent =>
      'Вы уверены, что хотите перезапустить обучение?';

  @override
  String get profileRestart => 'Перезапустить';

  @override
  String get profileSectionAccount => 'УПРАВЛЕНИЕ АККАУНТОМ';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileDeleteAccount => 'Удалить аккаунт';

  @override
  String get profileDeleteAccountConfirmTitle => 'Удалить аккаунт?';

  @override
  String get profileDelete => 'Удалить';

  @override
  String get profileDeletingAccount => 'Удаление вашего аккаунта...';

  @override
  String get profileErrorCouldNotFindProfile =>
      'Не удалось найти профиль пользователя.';

  @override
  String get memoryEditNewTitle => 'Новое воспоминание';

  @override
  String get memoryEditEditTitle => 'Редактировать воспоминание';

  @override
  String get memoryEditSave => 'Сохранить';

  @override
  String get memoryEditTitleHint => 'Название';

  @override
  String get memoryEditTitleValidator => 'Пожалуйста, введите название';

  @override
  String get memoryEditDescriptionHint => 'Описание';

  @override
  String get memoryEditDateLabel => 'Дата:';

  @override
  String get memoryEditSelectDateButton => 'Выбрать дату';

  @override
  String get memoryEditAmbientSoundLabel => 'Фоновый звук:';

  @override
  String get memoryEditAmbientSoundDropdownHint => 'Выберите фоновый звук';

  @override
  String get memoryEditMusicAnchorLabel => 'Музыкальный якорь:';

  @override
  String get memoryEditAttachTrackButton => 'Прикрепить трек из Spotify';

  @override
  String get memoryEditPhotosLabel => 'Фотографии:';

  @override
  String get memoryEditNoPhotosSelected => 'Фото не выбраны';

  @override
  String get memoryEditAddPhotosButton => 'Добавить фото';

  @override
  String get memoryEditVideosLabel => 'Видео:';

  @override
  String get memoryEditNoVideosSelected => 'Видео не выбраны';

  @override
  String get memoryEditAddVideoButton => 'Добавить видео';

  @override
  String get memoryEditAudioNoteLabel => 'Аудиозаметка:';

  @override
  String get memoryEditAudioNoteSaved => 'Аудиозаметка сохранена';

  @override
  String get memoryEditRecordButton => 'Запись';

  @override
  String get memoryEditStopRecordingButton => 'Остановить запись';

  @override
  String get memoryEditRecordingIndicator => 'Запись...';

  @override
  String get memoryEditReflectionSectionTitle => 'Рефлексия';

  @override
  String get memoryEditEncryptLabel => 'Зашифровать';

  @override
  String get memoryEditEncryptionInfoTooltip => 'Что такое шифрование?';

  @override
  String get memoryEditImpactPrompt => 'Как это событие повлияло на меня?';

  @override
  String get memoryEditLessonPrompt => 'Какой урок я извлек(ла)?';

  @override
  String get memoryEditEmotionsLabel => 'Эмоции:';

  @override
  String get emotionJoy => 'Радость';

  @override
  String get emotionNostalgia => 'Ностальгия';

  @override
  String get emotionPride => 'Гордость';

  @override
  String get emotionSadness => 'Грусть';

  @override
  String get emotionGratitude => 'Благодарность';

  @override
  String get emotionLove => 'Любовь';

  @override
  String get emotionFear => 'Страх';

  @override
  String get emotionAnger => 'Злость';

  @override
  String get emotionSurprise => 'Удивление';

  @override
  String get emotionDisgust => 'Отвращение';

  @override
  String get memoryEditCbtHelperTitle => 'Помощник по рефлексии';

  @override
  String get memoryEditCbtStep1Title =>
      'Какой была первая мысль или убеждение?';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'например, \'У меня ничего не получится\' или \'Я все сделал(а) правильно\'.';

  @override
  String get memoryEditCbtStep2Title => 'Что подтверждает эту мысль?';

  @override
  String get memoryEditCbtStep2Subtitle =>
      'Какие факты или события доказывают, что эта мысль верна?';

  @override
  String get memoryEditCbtStep3Title => 'Каков взгляд с другой стороны?';

  @override
  String get memoryEditCbtStep3Subtitle =>
      'Какие факты или события могут опровергнуть или оспорить первую мысль?';

  @override
  String get memoryEditCbtStep4Title => 'Как я могу посмотреть на это иначе?';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'Основываясь на вышесказанном, сформулируйте новую, более сбалансированную точку зрения.';

  @override
  String get memoryEditActionPlanTitle => 'План действий';

  @override
  String get memoryEditActionPrompt =>
      'Какой один маленький шаг я могу предпринять?';

  @override
  String get memoryEditReminderLabel => 'Напоминание:';

  @override
  String get memoryEditReminderNotSet => 'Не установлено';

  @override
  String get memoryEditSetReminderButton => 'Установить дату';

  @override
  String get memoryEditYourThoughtsHint => 'Ваши мысли здесь...';

  @override
  String get memoryEditDraftSavedMessage => 'Черновик сохранен';

  @override
  String get memoryEditErrorRepoUnavailable => 'Ошибка: Хранилище недоступно.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'Ошибка сохранения воспоминания: $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'Разблокировать для сохранения';

  @override
  String get memoryEditUnlockDialogContent =>
      'Пожалуйста, введите ваш мастер-пароль, чтобы сохранить это зашифрованное воспоминание.';

  @override
  String get memoryEditMasterPasswordHint => 'Мастер-пароль';

  @override
  String get memoryEditUnlockButton => 'Разблокировать';

  @override
  String get memoryEditEncryptionInfoDialogTitle => 'Сквозное шифрование';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'Когда вы шифруете воспоминание, его описание и поля рефлексии кодируются с помощью ключа, полученного из вашего мастер-пароля.\n\nДанные хранятся в облаке в нечитаемом формате и могут быть расшифрованы только на ваших устройствах с помощью вашего пароля.\n\nВАЖНО: Мы не можем восстановить ваш мастер-пароль. Если вы его забудете, ваши зашифрованные данные будут утеряны навсегда.';

  @override
  String get memoryEditOkButton => 'OK';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'Разрешение на $permissionName было отклонено. Пожалуйста, включите его в настройках.';
  }

  @override
  String get memoryEditSettingsButton => 'Настройки';

  @override
  String get memoryEditNoInternetSnackbar =>
      'Для поиска музыки требуется подключение к Интернету.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'Интенсивность для \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'Назад';

  @override
  String get memoryViewShareTooltip => 'Поделиться';

  @override
  String get memoryViewEditTooltip => 'Редактировать';

  @override
  String get memoryViewDeleteTooltip => 'Удалить';

  @override
  String get memoryViewTabMemory => 'Воспоминание';

  @override
  String get memoryViewTabInTheWorld => 'В мире';

  @override
  String get memoryViewEncryptedTitle => 'Зашифрованное воспоминание';

  @override
  String get memoryViewReflectionTitle => 'Рефлексия';

  @override
  String get memoryViewReflectionImpact => 'Влияние';

  @override
  String get memoryViewReflectionLesson => 'Извлеченный урок';

  @override
  String get memoryViewCbtStep1Title => 'Первая мысль или убеждение';

  @override
  String get memoryViewCbtStep2Title => 'Доказательства в пользу этой мысли';

  @override
  String get memoryViewCbtStep3Title => 'Доказательства против этой мысли';

  @override
  String get memoryViewCbtStep4Title =>
      'Новый, сбалансированный взгляд (переосмысление)';

  @override
  String memoryViewActionReminder(String date) {
    return 'Напоминание: $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'Отметить как невыполненное';

  @override
  String get memoryViewMarkCompleteTooltip => 'Отметить как выполненное';

  @override
  String get memoryViewUnlockDialogTitle => 'Разблокировать воспоминание';

  @override
  String get memoryViewUnlockDialogContent =>
      'Введите ваш мастер-пароль для просмотра этого контента.';

  @override
  String get memoryViewIncorrectPassword => 'Неверный пароль.';

  @override
  String get memoryViewUnlockButton => 'Разблокировать';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'Не удалось загрузить ваш профиль для получения исторических данных.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'Не удалось загрузить исторические данные за этот день.';

  @override
  String get memoryViewNoHistoricalData =>
      'Нет доступных исторических данных за этот день.';

  @override
  String get memoryViewErrorCouldNotLoadTrack => 'Не удалось загрузить трек';

  @override
  String get memoryViewTabNews => 'Новости';

  @override
  String get memoryViewTabMusic => 'Музыка';

  @override
  String get memoryViewNoDataForDay => 'Нет данных за этот день.';

  @override
  String get memoryViewNoNewsForDay =>
      'Нет исторических новостей за этот день.';

  @override
  String memoryViewNewsSource(String source) {
    return 'Источник: $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'Подтвердите удаление';

  @override
  String get memoryViewConfirmDeleteContent =>
      'Это действие необратимо. Чтобы продолжить, нажмите и удерживайте кнопку удаления в течение 5 секунд.';

  @override
  String get memoryViewDeleteButton => 'УДАЛИТЬ';

  @override
  String get memoryViewErrorLoadingProfile =>
      'Не удалось загрузить ваш профиль. Пожалуйста, проверьте соединение и попробуйте снова.';

  @override
  String get memoryViewErrorLocalDb =>
      'Ошибка: не удалось получить доступ к локальной базе данных.';

  @override
  String get memoryViewMemoryDeleted => 'Воспоминание удалено';

  @override
  String get memoryViewSharingNotImplemented =>
      'Функция «Поделиться» еще не реализована.';

  @override
  String get memoryViewActionCompleted => 'Действие отмечено как выполненное!';

  @override
  String get memoryViewActionIncomplete =>
      'Действие отмечено как невыполненное.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'Ошибка обновления действия: $error';
  }

  @override
  String get memoryViewContentEncrypted => 'Содержимое зашифровано';

  @override
  String get memoryViewReflectionEncrypted => 'Рефлексия зашифрована';

  @override
  String get memoryViewMediaEncrypted => 'Медиа зашифрованы';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'Фоновый звук: $sound';
  }

  @override
  String get memoryViewAudioNote => 'Аудиозаметка';

  @override
  String get spotifySearchTitle => 'Найти трек в Spotify';

  @override
  String get spotifySearchHint => 'Название песни или исполнитель';

  @override
  String get documentErrorLoading => 'Не удалось загрузить документ.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'Воспоминаний: $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'Период: $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status (осталось $jobs)';
  }

  @override
  String get lifelineCalculating => 'Вычисление...';

  @override
  String lifelineScaleValue(int scale) {
    return 'Масштаб: $scale%';
  }

  @override
  String lifelineFpsValue(String fps) {
    return 'FPS: $fps';
  }

  @override
  String lifelineFramePaintValue(int ms) {
    return 'Рендер кадра: $ms мс';
  }

  @override
  String get lifelineShowFullTimelineTooltip => 'Показать всю линию жизни';

  @override
  String get lifelineVisualSettingsTooltip => 'Визуальные настройки';

  @override
  String get lifelineMenuProfile => 'Профиль';

  @override
  String get lifelineMenuDebugOn => 'Отладка вкл.';

  @override
  String get lifelineMenuDebugOff => 'Отладка выкл.';

  @override
  String get lifelineMenuSignOut => 'Выйти';

  @override
  String get lifelineSearchHint => 'Поиск...';

  @override
  String get lifelineMemoriesListTitle => 'Воспоминания';

  @override
  String get lifelineVisualSettingsDialogTitle => 'Визуальные настройки';

  @override
  String get lifelineVisualSettingsSpeed => 'Скорость';

  @override
  String get lifelineVisualSettingsAmplitude => 'Амплитуда';

  @override
  String get lifelineVisualSettingsYearLine => 'Положение линии года';

  @override
  String get lifelineVisualSettingsBranchDensity => 'Плотность ветвей';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'Интенсивность ветвей';

  @override
  String get lifelineVisualSettingsAnimate => 'Анимация';

  @override
  String get lifelineVisualSettingsDoneButton => 'Готово';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'Ваше личное путешествие, визуализированное. Давайте проведем небольшой тур, чтобы вы узнали, как начать.';

  @override
  String get onboardingSkipButton => 'Пропустить';

  @override
  String get onboardingBeginTourButton => 'Начать тур';

  @override
  String get onboardingGesturesTitle => 'Навигация по линии жизни';

  @override
  String get onboardingGestureSwipe => 'Свайп';

  @override
  String get onboardingGesturePinch => 'Масштабирование';

  @override
  String get onboardingGestureDoubleTap => 'Двойной тап';

  @override
  String get onboardingGesturesSubtitle =>
      'Ваша линия жизни будет расти вместе с вами. Масштабируйте щипком, дважды нажмите для быстрого приближения. Проводите пальцем влево и вправо для навигации по времени.';

  @override
  String get onboardingContinueButton => 'Продолжить';

  @override
  String get onboardingFinalTitle => 'Все готово!';

  @override
  String get onboardingFinalSubtitle =>
      'Ваше путешествие начинается сейчас. Начните запечатлевать важные моменты.';

  @override
  String get onboardingStartJourneyButton => 'Начать мое путешествие';

  @override
  String get onboardingSkipTourButton => 'Пропустить тур';

  @override
  String get onboardingLifelineIntroText =>
      'Это ваша линия жизни. Каждое добавленное воспоминание создаст уникальный узел на этом пути, формируя красивую карту вашего жизненного пути.';

  @override
  String get onboardingLifelineIntroButton => 'Далее';

  @override
  String get onboardingAddMemoryText =>
      'Нажмите здесь, чтобы добавить новое воспоминание. Для каждого запечатленного момента на вашей линии жизни появится узел.';

  @override
  String get onboardingNavGesturesText =>
      'Отлично! Теперь давайте научимся навигации по вашей временной шкале.';

  @override
  String get onboardingControlsPanelText =>
      'Используйте эти элементы управления для управления просмотром. Вы можете центрировать линию жизни, настраивать визуальные эффекты и получать доступ к своему профилю.';

  @override
  String get onboardingControlsPanelButton => 'Понятно';

  @override
  String get onboardingStatsCardText =>
      'Эта карточка показывает сводку ваших воспоминаний. Нажмите на нее, чтобы открыть полный, доступный для поиска список всего вашего путешествия.';

  @override
  String get onboardingStatsCardButton => 'Почти готово!';

  @override
  String get audioPlayerPreviousTooltip => 'Предыдущий трек';

  @override
  String get audioPlayerPlayTooltip => 'Воспроизвести';

  @override
  String get audioPlayerPauseTooltip => 'Пауза';

  @override
  String get audioPlayerNextTooltip => 'Следующий трек';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'Шаг $step: ';
  }

  @override
  String get premiumBannerTitle => 'Разблокируйте Lifeline Premium';

  @override
  String get premiumBannerSubtitle =>
      'Безлимитные медиа, продвинутая рефлексия, исторический контекст и многое другое!';

  @override
  String get premiumDialogTitle => 'Перейдите на Premium';

  @override
  String premiumDialogContent(String feature) {
    return 'Разблокируйте возможность $feature и получите доступ ко всем премиум-функциям.';
  }

  @override
  String get premiumDialogGoPremium => 'Перейти на Premium';

  @override
  String get premiumFeaturePhotos => 'добавлять больше фото';

  @override
  String get premiumFeatureVideos => 'добавлять видео';

  @override
  String get premiumFeatureAudio => 'добавлять аудиозаметки';

  @override
  String get premiumFeatureSpotify => 'добавлять треки из Spotify';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'Раскройте свой полный потенциал';

  @override
  String get premiumScreenHeaderSubtitle =>
      'Преодолейте границы с Lifeline Premium и извлеките максимум из своего путешествия к самопознанию.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'Безлимитные фото и видео';

  @override
  String get premiumFeatureUnlimitedAudio => 'Безлимитные аудиозаметки';

  @override
  String get premiumFeatureUnlimitedSpotify => 'Безлимитные треки из Spotify';

  @override
  String get premiumFeatureAdvancedCbt => 'Продвинутый помощник по рефлексии';

  @override
  String get premiumFeatureActionReminders => 'Напоминания о планах действий';

  @override
  String get premiumFeatureHistoricalContext =>
      'Исторический контекст \'В мире\'';

  @override
  String get premiumFeatureSoundLibrary => 'Полная библиотека фоновых звуков';

  @override
  String get premiumScreenYearlyPopular => 'Самый популярный и выгодный';

  @override
  String get premiumScreenProcessingPurchase => 'Обработка покупки...';

  @override
  String get premiumScreenRestore => 'Восстановить покупки';

  @override
  String get premiumScreenTerms => 'Условия обслуживания';

  @override
  String get premiumScreenPrivacy => 'Политика конфиденциальности';

  @override
  String get premiumStatusTitle => 'Премиум-пользователь';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'Истекает $date';
  }

  @override
  String get onboardingEncryptionTitle => 'Ваши воспоминания, защищены';

  @override
  String get onboardingEncryptionSubtitle =>
      'Lifeline предлагает сквозное шифрование. Это означает, что только вы можете читать ваши личные воспоминания. Давайте настроим ваш Мастер-пароль, чтобы защитить их.';

  @override
  String get onboardingEncryptionSetupButton => 'Настроить сейчас';

  @override
  String get onboardingEncryptionLaterButton => 'Может быть, позже';

  @override
  String get onboardingEncryptionActiveTitle => 'Шифрование активно';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'Ваши воспоминания уже защищены. Вы можете управлять своим мастер-паролем в настройках профиля.';

  @override
  String get onboardingEncryptionContinueButton => 'Продолжить';

  @override
  String get memoryEditEncryptMemory => 'Зашифровать это воспоминание';

  @override
  String get memoryEditSetupEncryptionTitle => 'Включить шифрование?';

  @override
  String get memoryEditSetupEncryptionContent =>
      'Чтобы защитить это воспоминание, вам сначала нужно создать Мастер-пароль. Это будет ваш единственный ключ ко всем зашифрованным записям.';

  @override
  String get memoryEditCreatePasswordButton => 'Создать Мастер-пароль';

  @override
  String get memoryViewExportPdf => 'Поделиться как PDF';

  @override
  String get shareActionTitle => 'Добавить в Lifeline';

  @override
  String get shareActionSubtitle => 'Что вы хотите сделать с этими файлами?';

  @override
  String get shareCreateNewMemory => 'Создать новое воспоминание';

  @override
  String get shareAddToExisting => 'Дополнить существующее';

  @override
  String get selectMemoryTitle => 'Выберите воспоминание';

  @override
  String get selectMemorySearchHint => 'Поиск по названию или содержанию...';

  @override
  String get selectMemoryEmpty => 'Воспоминания не найдены';

  @override
  String get memoryUpdatedSuccess => 'Воспоминание успешно дополнено!';

  @override
  String unlockFailedAttemptsRemaining(int count) {
    return 'Неверный пароль. Осталось $count попытки.';
  }

  @override
  String unlockTooManyAttempts(int seconds) {
    return 'Слишком много попыток. Повторите через $seconds секунд.';
  }

  @override
  String get unlocking => 'Разблокировка...';

  @override
  String get exportingPdf => 'Подготовка PDF...';

  @override
  String exportFailed(String error) {
    return 'Не удалось экспортировать: $error';
  }

  @override
  String get profileEnableQuickUnlock => 'Включить быстрый доступ';

  @override
  String get profileQuickUnlockSubtitle =>
      'Используйте отпечаток пальца, лицо или PIN-код устройства, чтобы разблокировать.';

  @override
  String get profileRequireBiometricsForMemoryTitle =>
      'Требовать биометрию для каждой записи';

  @override
  String get profileRequireBiometricsForMemorySubtitle =>
      'Если включено, потребуется аутентификация для открытия или редактирования отдельных зашифрованных воспоминаний даже при разблокированном приложении.';

  @override
  String get quickUnlockPrompt =>
      'Пройдите проверку, чтобы разблокировать Lifeline';

  @override
  String get quickUnlockEnablePrompt =>
      'Пройдите проверку, чтобы включить быстрый доступ';

  @override
  String get masterPasswordRequiredTitle => 'Требуется мастер-пароль';

  @override
  String get masterPasswordRequiredContent =>
      'Введите мастер-пароль, чтобы включить эту функцию.';

  @override
  String get unlockScreenTitle => 'Разблокировать Lifeline';

  @override
  String get unlockWithBiometrics => 'Разблокировать с помощью биометрии';

  @override
  String get unlockEnterMasterPassword => 'Введите мастер-пароль';

  @override
  String get unlockForgotPassword => 'Забыли пароль?';

  @override
  String get unlockResetEncryptionTitle => 'Сброс шифрования';

  @override
  String get unlockResetEncryptionWarning =>
      '⚠️ ВНИМАНИЕ: Это действие необратимо!';

  @override
  String get unlockResetEncryptionDescription =>
      'Если вы забыли мастер-пароль, вы можете сбросить шифрование. Однако это приведет к безвозвратному удалению всех зашифрованных воспоминаний.';

  @override
  String get unlockResetEncryptionConsequences => 'Что будет удалено:';

  @override
  String get unlockResetEncryptionConsequence1 =>
      'Все зашифрованные воспоминания (локальные и в облаке)';

  @override
  String get unlockResetEncryptionConsequence2 => 'Шифрование будет отключено';

  @override
  String get unlockResetEncryptionConsequence3 =>
      'Вы сможете продолжить использовать приложение без шифрования';

  @override
  String get unlockResetEncryptionConfirm =>
      'Удалить зашифрованные воспоминания';

  @override
  String get unlockResetEncryptionSuccess =>
      'Шифрование сброшено. Теперь вы можете использовать приложение без мастер-пароля.';

  @override
  String get unlockResetEncryptionError => 'Не удалось сбросить шифрование';

  @override
  String get draftBannerSingleTitle => 'У вас есть незаконченное воспоминание';

  @override
  String draftBannerSingleSubtitle(String timeAgo) {
    return 'Последнее изменение: $timeAgo';
  }

  @override
  String draftBannerMultipleTitle(int count) {
    return 'У вас есть $count незаконченных воспоминаний';
  }

  @override
  String get draftBannerMultipleSubtitle => 'Нажмите, чтобы посмотреть все';

  @override
  String get draftBannerResume => 'Продолжить';

  @override
  String get draftBannerDelete => 'Удалить';

  @override
  String get draftResumedSuccess => 'Черновик возобновлён';

  @override
  String get draftDeleteDialogTitle => 'Удалить черновик?';

  @override
  String get draftDeleteDialogMessage =>
      'Этот черновик будет удалён навсегда. Это действие нельзя отменить.';

  @override
  String get draftDeleteCancel => 'Отмена';

  @override
  String get draftDeleteConfirm => 'Удалить';

  @override
  String get draftDeletedSuccess => 'Черновик удалён';

  @override
  String get draftDeletedError => 'Не удалось удалить черновик';

  @override
  String draftListDialogTitle(int count) {
    return 'У вас $count черновиков';
  }

  @override
  String get draftListItemNoTitle => 'Без названия';

  @override
  String get draftListItemNoContent => 'Нет содержания';

  @override
  String draftListItemLastModified(String timeAgo) {
    return 'Последнее изменение: $timeAgo';
  }

  @override
  String get timeAgoJustNow => 'только что';

  @override
  String timeAgoMinutes(int count) {
    return '$count минут назад';
  }

  @override
  String timeAgoHours(int count) {
    return '$count часов назад';
  }

  @override
  String timeAgoDays(int count) {
    return '$count дней назад';
  }

  @override
  String timeAgoWeeks(int count) {
    return '$count недель назад';
  }

  @override
  String get fileSizeTooLargeImage =>
      'Файл изображения слишком большой. Максимальный размер — 10 МБ.';

  @override
  String get fileSizeTooLargeVideo =>
      'Видеофайл слишком большой. Максимальный размер — 100 МБ.';

  @override
  String get fileSizeTooLargeAudio =>
      'Аудиофайл слишком большой. Максимальный размер — 25 МБ.';

  @override
  String get biometricUnlockFailedMessage =>
      'Необходимо пересоздать ключи безопасности после переустановки приложения. Пожалуйста, введите мастер-пароль для продолжения.';

  @override
  String get quickUnlockAutoEnabledMessage =>
      '✓ Биометрическая разблокировка автоматически включена для вас!';

  @override
  String lifelineInsightStreakDays(int count) {
    return '🔥 Серия $count дней';
  }

  @override
  String lifelineInsightMemoriesThisMonth(int count) {
    return '📝 $count воспоминаний в этом месяце';
  }

  @override
  String lifelineInsightMemoriesThisWeek(int count) {
    return '✨ $count новых на этой неделе';
  }

  @override
  String lifelineInsightReflectionsCount(int count) {
    return '⭐ $count рефлексий';
  }

  @override
  String lifelineInsightPhotosCount(int count) {
    return '📸 $count фотографий';
  }

  @override
  String lifelineInsightAudioCount(int count) {
    return '🎵 $count аудиозаметок';
  }

  @override
  String lifelineInsightSpanningYears(int years) {
    return '📅 Охватывает $years лет';
  }

  @override
  String lifelineInsightTotalMemories(int count) {
    return '📖 $count запечатленных моментов';
  }

  @override
  String get lifelineInsightPositiveVibes => '😊 В основном позитивные эмоции';

  @override
  String get lifelineInsightGrowthJourney => '🌱 Путь роста';

  @override
  String get lifelineInsightBalancedEmotions => '⚖️ Сбалансированные эмоции';

  @override
  String get lifelineInsightStartJourney => '✍️ Начните свое путешествие';

  @override
  String get lifelineInsightBuildStreak => '💪 Создайте серию';

  @override
  String get purchaseSuccessMessage =>
      'Покупка успешна! Добро пожаловать в Premium!';

  @override
  String get graphicsQualityTitle => 'Качество графики';

  @override
  String get graphicsQualityAuto => 'Авто';

  @override
  String get graphicsQualityLow => 'Низкое';

  @override
  String get graphicsQualityMedium => 'Среднее';

  @override
  String get graphicsQualityHigh => 'Высокое';

  @override
  String get graphicsQualityAutoSubtitle =>
      'Автоматически определять производительность устройства';

  @override
  String get graphicsQualityLowSubtitle =>
      'Максимальная экономия батареи, минимум эффектов';

  @override
  String get graphicsQualityMediumSubtitle =>
      'Баланс производительности и визуальных эффектов';

  @override
  String get graphicsQualityHighSubtitle =>
      'Максимальное качество графики, повышенный расход батареи';

  @override
  String graphicsQualityAutoDetected(String performance) {
    return 'Авто ($performance)';
  }

  @override
  String get notificationAnniversaryTitle => 'Напоминания о годовщинах';

  @override
  String get notificationAnniversarySubtitle =>
      'Напоминать о важных моментах из прошлого';

  @override
  String get notificationMotivationalTitle => 'Мотивационные напоминания';

  @override
  String get notificationMotivationalSubtitle =>
      'Деликатные напоминания запечатлеть важные моменты';

  @override
  String get notificationInsightTitle => 'Эмоциональные инсайты';

  @override
  String get notificationInsightSubtitle =>
      'Размышления о вашем эмоциональном пути';

  @override
  String get emotionVisualizationTitle => '🎨 Эмоциональная Визуализация';

  @override
  String get emotionVisualizationSubtitle => 'Настройте отображение эмоций';

  @override
  String get emotionVisualizationTimelineSection => 'На жизненной линии:';

  @override
  String get emotionVisualizationLevel1Title => 'Уровень 1: Годовой градиент';

  @override
  String get emotionVisualizationLevel1Subtitle =>
      'Общее свечение эмоций (зум < 250%)';

  @override
  String get emotionVisualizationLevel2Title => 'Уровень 2: Месячные кластеры';

  @override
  String get emotionVisualizationLevel2Subtitle =>
      'Эмоции по месяцам (зум 250%-460%)';

  @override
  String get emotionVisualizationLevel3Title => 'Уровень 3: Аура узлов';

  @override
  String get emotionVisualizationLevel3Subtitle =>
      'Свечение вокруг узлов (зум > 460%)';

  @override
  String get emotionVisualizationEnable => 'Включить';

  @override
  String get emotionVisualizationIntensity => 'Интенсивность';

  @override
  String get emotionVisualizationRadius => 'Радиус';

  @override
  String get emotionVisualizationRadiusMultiplier => 'Радиус (множитель)';

  @override
  String get emotionVisualizationBlur => 'Размытие';

  @override
  String get emotionVisualizationBlurMultiplier => 'Размытие (множитель)';

  @override
  String get emotionVisualizationSaturation => 'Насыщенность';

  @override
  String get emotionVisualizationMemoryViewSection =>
      'При просмотре воспоминания:';

  @override
  String get emotionVisualizationMemoryGradientTitle =>
      'Эмоциональный градиент';

  @override
  String get emotionVisualizationMemoryGradientSubtitle =>
      'Цветной фон на основе эмоций';

  @override
  String get emotionVisualizationMemoryParticlesTitle =>
      'Эмоциональные частицы';

  @override
  String get emotionVisualizationMemoryParticlesSubtitle =>
      'Анимированные частицы (Premium)';

  @override
  String get emotionVisualizationPhotoColorGradingTitle =>
      'Цветокоррекция фото';

  @override
  String get emotionVisualizationPhotoColorGradingSubtitle =>
      'Подстройка фото под эмоции (Premium)';

  @override
  String get profileCreationErrorTitle => 'Не удалось создать профиль';

  @override
  String profileCreationErrorAttemptsMessage(int attempts) {
    return 'Мы попробовали $attempts раз, но не смогли создать ваш профиль.';
  }

  @override
  String get profileCreationErrorReasons => 'Это может быть связано с:';

  @override
  String get profileCreationErrorReasonsList =>
      '• Проблемами с подключением к Интернету\n• Проблемами на сервере\n• Ошибками прав доступа';

  @override
  String get profileCreationErrorTryAgain => 'Попробовать снова';

  @override
  String get profileCreationErrorLogout => 'Выйти';

  @override
  String get profileCreationErrorContactSupport =>
      'Связаться со службой поддержки';

  @override
  String get shareDialogErrorLoadingProfile => 'Ошибка загрузки профиля';
}
