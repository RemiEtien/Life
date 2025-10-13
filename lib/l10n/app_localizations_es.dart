// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get createAccount => 'Crear una nueva cuenta';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get orSignInWith => 'O inicia sesión con';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get invalidEmail =>
      'Por favor, introduce un correo electrónico válido';

  @override
  String get consentWelcomeTitle => 'Bienvenido a Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'Antes de comenzar, por favor, revisa y acepta nuestros términos.';

  @override
  String get consentIAgreeTo => 'He leído y acepto los ';

  @override
  String get consentTermsOfService => 'Términos de Servicio';

  @override
  String get consentAnd => ' y la ';

  @override
  String get consentPrivacyPolicy => 'Política de Privacidad';

  @override
  String get consentContinue => 'Continuar';

  @override
  String consentErrorSaving(String error) {
    return 'Error al guardar la configuración: $error';
  }

  @override
  String get splashMessageInitializing => 'Inicializando...';

  @override
  String get splashMessageCheckingSettings => 'Comprobando ajustes...';

  @override
  String get splashMessageAuthenticating => 'Autenticando...';

  @override
  String get splashMessageSyncing => 'Sincronizando tu línea de tiempo...';

  @override
  String get authGateLoadingMemories => 'Cargando recuerdos...';

  @override
  String get authGateAuthenticating => 'Autenticando...';

  @override
  String get authGateSomethingWentWrong => 'Algo salió mal';

  @override
  String get authGateCouldNotLoad =>
      'No pudimos cargar tus datos. Por favor, comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get authGateTryAgain => 'Intentar de nuevo';

  @override
  String get authGateEmptyState =>
      'Tu Lifeline está lista.\nToca el botón + para añadir tu primer recuerdo.';

  @override
  String get authGateUnsavedDraftTitle => 'Recuerdo no guardado';

  @override
  String get authGateUnsavedDraftContent =>
      'Tienes un borrador de recuerdo sin guardar. ¿Quieres seguir editándolo?';

  @override
  String get authGateDiscard => 'Descartar';

  @override
  String get authGateContinueEditing => 'Continuar editando';

  @override
  String get verifyEmailTitle => 'Verificación de correo electrónico';

  @override
  String get verifyEmailSentTo => 'Se ha enviado un correo de verificación a:';

  @override
  String get verifyEmailInstructions =>
      'Por favor, haz clic en el enlace del correo para completar tu registro.';

  @override
  String get verifyEmailResendButton => 'Reenviar correo';

  @override
  String get verifyEmailCancelButton => 'Cancelar';

  @override
  String get profileTitle => 'Perfil y Ajustes';

  @override
  String get profileSectionProfile => 'PERFIL';

  @override
  String get profileChangeNameTitle => 'Cambiar nombre';

  @override
  String get profileEnterYourName => 'Introduce tu nombre';

  @override
  String get profileSave => 'Guardar';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileEmail => 'Correo electrónico';

  @override
  String get profileCountry => 'País';

  @override
  String get profileCountryNotSelected => 'No seleccionado';

  @override
  String get profileLanguage => 'Idioma del contenido';

  @override
  String get profileLanguageDefault => 'Inglés (predeterminado)';

  @override
  String get profileSelectLanguage => 'Seleccionar idioma';

  @override
  String get profileSectionSettings => 'AJUSTES';

  @override
  String get profileTheme => 'Tema';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Oscuro';

  @override
  String get profileReauthTitle => 'Se requiere reautenticación';

  @override
  String get profileReauthContent =>
      'Esta es una operación sensible. Por favor, inicie sesión de nuevo antes de continuar.';

  @override
  String get profileReauthButton => 'Iniciar sesión y eliminar';

  @override
  String get profileReauthPasswordDialogTitle => 'Confirmar acción';

  @override
  String get profileReauthPasswordDialogContent =>
      'Para eliminar su cuenta, por favor ingrese su contraseña actual.';

  @override
  String get profilePasswordCannotBeEmpty =>
      'La contraseña no puede estar vacía';

  @override
  String get profileChangePasswordSuccess =>
      '¡Contraseña maestra cambiada con éxito!';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'La contraseña actual que has introducido es incorrecta.';

  @override
  String get profileOldPasswordHint => 'Contraseña anterior';

  @override
  String get profileNewPasswordHint => 'Nueva contraseña';

  @override
  String get profileDeleteAccountConfirmContent =>
      'Esta acción es irreversible. Tu cuenta completa, incluyendo todos los recuerdos y ajustes, será eliminada permanentemente. Para continuar, mantén presionado el botón de eliminar durante 5 segundos.';

  @override
  String get profileChangePasswordCurrentPasswordHint =>
      'Contraseña maestra actual';

  @override
  String get profileChangePasswordNewPasswordHint => 'Nueva contraseña maestra';

  @override
  String get profileChangePasswordInfo =>
      'Por favor, introduce tu contraseña maestra actual para establecer una nueva. Esto volverá a cifrar tu clave secreta.';

  @override
  String get profileGraphics => 'Calidad de los gráficos';

  @override
  String get profileGraphicsAuto => 'Automático';

  @override
  String get profileGraphicsLow => 'Baja';

  @override
  String get profileGraphicsMedium => 'Media';

  @override
  String get profileGraphicsHigh => 'Alta';

  @override
  String get profileReminders => 'Recordatorios de reflexión';

  @override
  String get profileRemindersSubtitle =>
      'Recibe notificaciones para tus planes de acción';

  @override
  String get profileSectionSecurity => 'SEGURIDAD';

  @override
  String get profileChangePassword => 'Cambiar contraseña maestra';

  @override
  String get profileEncryptionActive =>
      'El cifrado de extremo a extremo está activo';

  @override
  String get profileEnableEncryption => 'Activar cifrado de extremo a extremo';

  @override
  String get profileEnableEncryptionSubtitle =>
      'Protege tus recuerdos sensibles con una contraseña maestra.';

  @override
  String get profileCreateMasterPassword => 'Crear contraseña maestra';

  @override
  String get profileMasterPasswordInfo =>
      'Esta contraseña protegerá tus recuerdos. No se puede recuperar si la olvidas. Por favor, guárdala en un lugar seguro.';

  @override
  String get profileMasterPasswordHint => 'Contraseña maestra';

  @override
  String get profileConfirmPasswordHint => 'Confirmar contraseña';

  @override
  String get profilePasswordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get profilePasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get profileEnable => 'Activar';

  @override
  String get profileSectionHelp => 'AYUDA';

  @override
  String get profileReplayTutorial => 'Repetir tutorial';

  @override
  String get profileReplayTutorialConfirmTitle => '¿Repetir tutorial?';

  @override
  String get profileReplayTutorialConfirmContent =>
      '¿Estás seguro de que quieres reiniciar el tutorial?';

  @override
  String get profileRestart => 'Reiniciar';

  @override
  String get profileSectionAccount => 'GESTIÓN DE LA CUENTA';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountConfirmTitle => '¿Eliminar cuenta?';

  @override
  String get profileDelete => 'Eliminar';

  @override
  String get profileDeletingAccount => 'Eliminando tu cuenta...';

  @override
  String get profileErrorCouldNotFindProfile =>
      'No se pudo encontrar el perfil de usuario.';

  @override
  String get memoryEditNewTitle => 'Nuevo recuerdo';

  @override
  String get memoryEditEditTitle => 'Editar recuerdo';

  @override
  String get memoryEditSave => 'Guardar';

  @override
  String get memoryEditTitleHint => 'Título';

  @override
  String get memoryEditTitleValidator => 'Por favor, introduce un título';

  @override
  String get memoryEditDescriptionHint => 'Descripción';

  @override
  String get memoryEditDateLabel => 'Fecha:';

  @override
  String get memoryEditSelectDateButton => 'Seleccionar fecha';

  @override
  String get memoryEditAmbientSoundLabel => 'Sonido ambiente:';

  @override
  String get memoryEditAmbientSoundDropdownHint =>
      'Selecciona un sonido ambiente';

  @override
  String get memoryEditMusicAnchorLabel => 'Ancla musical:';

  @override
  String get memoryEditAttachTrackButton => 'Adjuntar pista de Spotify';

  @override
  String get memoryEditPhotosLabel => 'Fotos:';

  @override
  String get memoryEditNoPhotosSelected => 'No hay fotos seleccionadas';

  @override
  String get memoryEditAddPhotosButton => 'Añadir fotos';

  @override
  String get memoryEditVideosLabel => 'Vídeos:';

  @override
  String get memoryEditNoVideosSelected => 'No hay vídeos seleccionados';

  @override
  String get memoryEditAddVideoButton => 'Añadir vídeo';

  @override
  String get memoryEditAudioNoteLabel => 'Nota de audio:';

  @override
  String get memoryEditAudioNoteSaved => 'Nota de audio guardada';

  @override
  String get memoryEditRecordButton => 'Grabar';

  @override
  String get memoryEditStopRecordingButton => 'Detener grabación';

  @override
  String get memoryEditRecordingIndicator => 'Grabando...';

  @override
  String get memoryEditReflectionSectionTitle => 'Reflexión';

  @override
  String get memoryEditEncryptLabel => 'Cifrar';

  @override
  String get memoryEditEncryptionInfoTooltip => '¿Qué es el cifrado?';

  @override
  String get memoryEditImpactPrompt => '¿Cómo me impactó este evento?';

  @override
  String get memoryEditLessonPrompt => '¿Qué lección aprendí?';

  @override
  String get memoryEditEmotionsLabel => 'Emociones:';

  @override
  String get emotionJoy => 'Alegría';

  @override
  String get emotionNostalgia => 'Nostalgia';

  @override
  String get emotionPride => 'Orgullo';

  @override
  String get emotionSadness => 'Tristeza';

  @override
  String get emotionGratitude => 'Gratitud';

  @override
  String get emotionLove => 'Amor';

  @override
  String get emotionFear => 'Miedo';

  @override
  String get emotionAnger => 'Ira';

  @override
  String get memoryEditCbtHelperTitle => 'Ayudante de reflexión';

  @override
  String get memoryEditCbtStep1Title =>
      '¿Cuál fue el primer pensamiento o creencia?';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'p. ej., \'Voy a fracasar\' o \'Hice todo bien\'.';

  @override
  String get memoryEditCbtStep2Title => '¿Qué apoya este pensamiento?';

  @override
  String get memoryEditCbtStep2Subtitle =>
      '¿Qué hechos o eventos demuestran que este pensamiento es cierto?';

  @override
  String get memoryEditCbtStep3Title =>
      '¿Cuál es la visión desde el otro lado?';

  @override
  String get memoryEditCbtStep3Subtitle =>
      '¿Qué hechos o eventos podrían refutar o desafiar el primer pensamiento?';

  @override
  String get memoryEditCbtStep4Title =>
      '¿Cómo puedo ver esto de manera diferente?';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'Basado en lo anterior, formula una perspectiva nueva y más equilibrada.';

  @override
  String get memoryEditActionPlanTitle => 'Plan de acción';

  @override
  String get memoryEditActionPrompt =>
      '¿Cuál es un pequeño paso que puedo dar?';

  @override
  String get memoryEditReminderLabel => 'Recordatorio:';

  @override
  String get memoryEditReminderNotSet => 'No establecido';

  @override
  String get memoryEditSetReminderButton => 'Establecer fecha';

  @override
  String get memoryEditYourThoughtsHint => 'Tus pensamientos aquí...';

  @override
  String get memoryEditDraftSavedMessage => 'Borrador guardado';

  @override
  String get memoryEditErrorRepoUnavailable =>
      'Error: Repositorio no disponible.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'Error al guardar el recuerdo: $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'Desbloquear para guardar';

  @override
  String get memoryEditUnlockDialogContent =>
      'Por favor, introduce tu contraseña maestra para guardar este recuerdo cifrado.';

  @override
  String get memoryEditMasterPasswordHint => 'Contraseña maestra';

  @override
  String get memoryEditUnlockButton => 'Desbloquear';

  @override
  String get memoryEditEncryptionInfoDialogTitle =>
      'Cifrado de extremo a extremo';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'Cuando cifras un recuerdo, sus campos de descripción y reflexión se codifican utilizando una clave derivada de tu contraseña maestra.\n\nLos datos se almacenan en un formato ilegible en la nube y solo se pueden descifrar en tus dispositivos con tu contraseña.\n\nIMPORTANTE: No podemos recuperar tu contraseña maestra. Si la olvidas, tus datos cifrados se perderán para siempre.';

  @override
  String get memoryEditOkButton => 'Aceptar';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'El permiso para $permissionName fue denegado. Por favor, actívalo en los ajustes.';
  }

  @override
  String get memoryEditSettingsButton => 'Ajustes';

  @override
  String get memoryEditNoInternetSnackbar =>
      'Se requiere conexión a Internet para buscar música.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'Intensidad para \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'Atrás';

  @override
  String get memoryViewShareTooltip => 'Compartir';

  @override
  String get memoryViewEditTooltip => 'Editar';

  @override
  String get memoryViewDeleteTooltip => 'Eliminar';

  @override
  String get memoryViewTabMemory => 'Recuerdo';

  @override
  String get memoryViewTabInTheWorld => 'En el mundo';

  @override
  String get memoryViewEncryptedTitle => 'Recuerdo cifrado';

  @override
  String get memoryViewReflectionTitle => 'Reflexión';

  @override
  String get memoryViewReflectionImpact => 'Impacto';

  @override
  String get memoryViewReflectionLesson => 'Lección aprendida';

  @override
  String get memoryViewCbtStep1Title => 'Primer pensamiento o creencia';

  @override
  String get memoryViewCbtStep2Title => 'Evidencia a favor de este pensamiento';

  @override
  String get memoryViewCbtStep3Title =>
      'Evidencia en contra de este pensamiento';

  @override
  String get memoryViewCbtStep4Title =>
      'Perspectiva nueva y equilibrada (Reencuadre)';

  @override
  String memoryViewActionReminder(String date) {
    return 'Recordatorio: $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'Marcar como incompleto';

  @override
  String get memoryViewMarkCompleteTooltip => 'Marcar como completo';

  @override
  String get memoryViewUnlockDialogTitle => 'Desbloquear recuerdo';

  @override
  String get memoryViewUnlockDialogContent =>
      'Introduce tu contraseña maestra para ver este contenido.';

  @override
  String get memoryViewIncorrectPassword => 'Contraseña incorrecta.';

  @override
  String get memoryViewUnlockButton => 'Desbloquear';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'No se pudo cargar tu perfil para obtener datos históricos.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'No se pudieron cargar los datos históricos de este día.';

  @override
  String get memoryViewNoHistoricalData =>
      'No hay datos históricos disponibles para este día.';

  @override
  String get memoryViewErrorCouldNotLoadTrack => 'No se pudo cargar la pista';

  @override
  String get memoryViewTabNews => 'Noticias';

  @override
  String get memoryViewTabMusic => 'Música';

  @override
  String get memoryViewNoDataForDay => 'No hay datos para este día.';

  @override
  String get memoryViewNoNewsForDay =>
      'No hay noticias históricas para este día.';

  @override
  String memoryViewNewsSource(String source) {
    return 'Fuente: $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'Confirmar eliminación';

  @override
  String get memoryViewConfirmDeleteContent =>
      'Esta acción es irreversible. Para continuar, mantén pulsado el botón de eliminar durante 5 segundos.';

  @override
  String get memoryViewDeleteButton => 'ELIMINAR';

  @override
  String get memoryViewErrorLoadingProfile =>
      'No pudimos cargar tu perfil. Por favor, comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get memoryViewErrorLocalDb =>
      'Error: No se pudo acceder a la base de datos local.';

  @override
  String get memoryViewMemoryDeleted => 'Recuerdo eliminado';

  @override
  String get memoryViewSharingNotImplemented =>
      'La función de compartir aún no está implementada.';

  @override
  String get memoryViewActionCompleted => '¡Acción marcada como completada!';

  @override
  String get memoryViewActionIncomplete => 'Acción marcada como incompleta.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'Error al actualizar la acción: $error';
  }

  @override
  String get memoryViewContentEncrypted => 'El contenido está cifrado';

  @override
  String get memoryViewReflectionEncrypted => 'La reflexión está cifrada';

  @override
  String get memoryViewMediaEncrypted => 'Los medios están cifrados';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'Sonido ambiente: $sound';
  }

  @override
  String get memoryViewAudioNote => 'Nota de audio';

  @override
  String get spotifySearchTitle => 'Buscar pista en Spotify';

  @override
  String get spotifySearchHint => 'Título de la canción o artista';

  @override
  String get documentErrorLoading => 'No se pudo cargar el documento.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'Recuerdos: $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'Período: $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status ($jobs restantes)';
  }

  @override
  String get lifelineCalculating => 'Calculando...';

  @override
  String lifelineScaleValue(int scale) {
    return 'Escala: $scale%';
  }

  @override
  String lifelineFpsValue(String fps) {
    return 'FPS: $fps';
  }

  @override
  String lifelineFramePaintValue(int ms) {
    return 'Pintura de fotograma: $ms ms';
  }

  @override
  String get lifelineShowFullTimelineTooltip =>
      'Mostrar línea de tiempo completa';

  @override
  String get lifelineVisualSettingsTooltip => 'Ajustes visuales';

  @override
  String get lifelineMenuProfile => 'Perfil';

  @override
  String get lifelineMenuDebugOn => 'Depuración activada';

  @override
  String get lifelineMenuDebugOff => 'Depuración desactivada';

  @override
  String get lifelineMenuSignOut => 'Cerrar sesión';

  @override
  String get lifelineSearchHint => 'Buscar...';

  @override
  String get lifelineMemoriesListTitle => 'Recuerdos';

  @override
  String get lifelineVisualSettingsDialogTitle => 'Ajustes Visuales';

  @override
  String get lifelineVisualSettingsSpeed => 'Velocidad';

  @override
  String get lifelineVisualSettingsAmplitude => 'Amplitud';

  @override
  String get lifelineVisualSettingsYearLine => 'Posición de la línea del año';

  @override
  String get lifelineVisualSettingsBranchDensity => 'Densidad de ramas';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'Intensidad de ramas';

  @override
  String get lifelineVisualSettingsAnimate => 'Animar';

  @override
  String get lifelineVisualSettingsDoneButton => 'Hecho';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'Tu viaje personal, visualizado. Hagamos un recorrido rápido para ver cómo puedes empezar a capturar tus momentos.';

  @override
  String get onboardingSkipButton => 'Omitir por ahora';

  @override
  String get onboardingBeginTourButton => 'Comenzar recorrido';

  @override
  String get onboardingGesturesTitle => 'Navega por tu línea de tiempo';

  @override
  String get onboardingGestureSwipe => 'Deslizar';

  @override
  String get onboardingGesturePinch => 'Pellizcar para hacer zoom';

  @override
  String get onboardingGestureDoubleTap => 'Doble toque';

  @override
  String get onboardingGesturesSubtitle =>
      'Tu Lifeline crecerá contigo. Pellizca para hacer zoom, toca dos veces para acercar rápidamente. Desliza a la izquierda y a la derecha para navegar por el tiempo.';

  @override
  String get onboardingContinueButton => 'Continuar';

  @override
  String get onboardingFinalTitle => '¡Todo listo!';

  @override
  String get onboardingFinalSubtitle =>
      'Tu viaje comienza ahora. Empieza a capturar los momentos que importan.';

  @override
  String get onboardingStartJourneyButton => 'Comenzar mi viaje';

  @override
  String get onboardingSkipTourButton => 'Omitir recorrido';

  @override
  String get onboardingLifelineIntroText =>
      'Esta es tu Lifeline. Cada recuerdo que añadas creará un nodo único en este camino, formando un hermoso mapa del viaje de tu vida.';

  @override
  String get onboardingLifelineIntroButton => 'Siguiente';

  @override
  String get onboardingAddMemoryText =>
      'Toca aquí para añadir un nuevo recuerdo. Aparecerá un nodo en tu Lifeline por cada momento que captures.';

  @override
  String get onboardingNavGesturesText =>
      '¡Genial! Ahora, aprendamos a navegar por tu línea de tiempo.';

  @override
  String get onboardingControlsPanelText =>
      'Usa estos controles para gestionar tu vista. Puedes recentrar la línea de tiempo, ajustar los efectos visuales y acceder a tu perfil.';

  @override
  String get onboardingControlsPanelButton => 'Entendido';

  @override
  String get onboardingStatsCardText =>
      'Esta tarjeta muestra un resumen de tus recuerdos. Tócala para abrir una lista completa y con capacidad de búsqueda de todo tu viaje.';

  @override
  String get onboardingStatsCardButton => '¡Casi listo!';

  @override
  String get audioPlayerPreviousTooltip => 'Pista anterior';

  @override
  String get audioPlayerPlayTooltip => 'Reproducir';

  @override
  String get audioPlayerPauseTooltip => 'Pausa';

  @override
  String get audioPlayerNextTooltip => 'Pista siguiente';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'Paso $step: ';
  }

  @override
  String get premiumBannerTitle => 'Desbloquear Lifeline Premium';

  @override
  String get premiumBannerSubtitle =>
      '¡Medios ilimitados, reflexión avanzada, contexto histórico y más!';

  @override
  String get premiumDialogTitle => 'Actualizar a Premium';

  @override
  String premiumDialogContent(String feature) {
    return 'Desbloquea la capacidad de $feature y obtén acceso a todas las funciones premium.';
  }

  @override
  String get premiumDialogGoPremium => 'Hazte Premium';

  @override
  String get premiumFeaturePhotos => 'añadir más fotos';

  @override
  String get premiumFeatureVideos => 'añadir un vídeo';

  @override
  String get premiumFeatureAudio => 'añadir una nota de audio';

  @override
  String get premiumFeatureSpotify => 'añadir una pista de Spotify';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'Desbloquea todo tu potencial';

  @override
  String get premiumScreenHeaderSubtitle =>
      'Supera los límites con Lifeline Premium y aprovecha al máximo tu viaje de autodescubrimiento.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'Fotos y vídeos ilimitados';

  @override
  String get premiumFeatureUnlimitedAudio => 'Notas de audio ilimitadas';

  @override
  String get premiumFeatureUnlimitedSpotify => 'Pistas de Spotify ilimitadas';

  @override
  String get premiumFeatureAdvancedCbt => 'Ayudante de reflexión avanzado';

  @override
  String get premiumFeatureActionReminders =>
      'Recordatorios de planes de acción';

  @override
  String get premiumFeatureHistoricalContext =>
      'Contexto histórico \'En el mundo\'';

  @override
  String get premiumFeatureSoundLibrary =>
      'Biblioteca completa de sonidos ambientales';

  @override
  String get premiumScreenYearlyPopular => 'Más popular y mejor valor';

  @override
  String get premiumScreenProcessingPurchase => 'Procesando compra...';

  @override
  String get premiumScreenRestore => 'Restaurar compras';

  @override
  String get premiumScreenTerms => 'Términos de servicio';

  @override
  String get premiumScreenPrivacy => 'Política de privacidad';

  @override
  String get premiumStatusTitle => 'Miembro Premium';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'Expira el $date';
  }

  @override
  String get onboardingEncryptionTitle => 'Tus recuerdos, seguros';

  @override
  String get onboardingEncryptionSubtitle =>
      'Lifeline ofrece cifrado de extremo a extremo. Esto significa que solo tú puedes leer tus recuerdos privados. Configuremos tu contraseña maestra para protegerlos.';

  @override
  String get onboardingEncryptionSetupButton => 'Configurar ahora';

  @override
  String get onboardingEncryptionLaterButton => 'Quizás más tarde';

  @override
  String get onboardingEncryptionActiveTitle => 'El cifrado está activo';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'Tus recuerdos ya están protegidos. Puedes gestionar tu contraseña maestra en los ajustes del perfil.';

  @override
  String get onboardingEncryptionContinueButton => 'Continuar';

  @override
  String get memoryEditEncryptMemory => 'Cifrar este recuerdo';

  @override
  String get memoryEditSetupEncryptionTitle => '¿Activar cifrado?';

  @override
  String get memoryEditSetupEncryptionContent =>
      'Para proteger este recuerdo, primero necesitas crear una contraseña maestra. Esta será tu única clave para todas las entradas cifradas.';

  @override
  String get memoryEditCreatePasswordButton => 'Crear contraseña maestra';

  @override
  String get memoryViewExportPdf => 'Compartir como PDF';

  @override
  String get shareActionTitle => 'Añadir a Lifeline';

  @override
  String get shareActionSubtitle =>
      '¿Qué te gustaría hacer con estos archivos?';

  @override
  String get shareCreateNewMemory => 'Crear un nuevo recuerdo';

  @override
  String get shareAddToExisting => 'Añadir a un recuerdo existente';

  @override
  String get selectMemoryTitle => 'Seleccionar un recuerdo';

  @override
  String get selectMemorySearchHint => 'Buscar por título o contenido...';

  @override
  String get selectMemoryEmpty => 'No se encontraron recuerdos';

  @override
  String get memoryUpdatedSuccess => '¡Recuerdo actualizado con éxito!';

  @override
  String unlockFailedAttemptsRemaining(int count) {
    return 'Contraseña incorrecta. Quedan $count intentos.';
  }

  @override
  String unlockTooManyAttempts(int seconds) {
    return 'Demasiados intentos. Inténtalo de nuevo en $seconds segundos.';
  }

  @override
  String get unlocking => 'Desbloqueando...';

  @override
  String get exportingPdf => 'Preparando PDF...';

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get profileEnableQuickUnlock => 'Activar desbloqueo rápido';

  @override
  String get profileQuickUnlockSubtitle =>
      'Usa tu huella, rostro o PIN del dispositivo para desbloquear.';

  @override
  String get profileRequireBiometricsForMemoryTitle =>
      'Requerir biometría para cada recuerdo';

  @override
  String get profileRequireBiometricsForMemorySubtitle =>
      'Si se activa, se requerirá autenticación para abrir o editar recuerdos cifrados individuales, incluso cuando la app esté desbloqueada.';

  @override
  String get quickUnlockPrompt => 'Autentícate para desbloquear Lifeline';

  @override
  String get quickUnlockEnablePrompt =>
      'Autentícate para activar el desbloqueo rápido';

  @override
  String get masterPasswordRequiredTitle => 'Se requiere la contraseña maestra';

  @override
  String get masterPasswordRequiredContent =>
      'Ingresa tu contraseña maestra para habilitar esta función.';

  @override
  String get unlockScreenTitle => 'Desbloquear Lifeline';

  @override
  String get unlockWithBiometrics => 'Desbloquear con biometría';

  @override
  String get unlockEnterMasterPassword => 'Introduce la contraseña maestra';

  @override
  String get unlockForgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get unlockResetEncryptionTitle => 'Restablecer cifrado';

  @override
  String get unlockResetEncryptionWarning =>
      '⚠️ ADVERTENCIA: ¡Esta acción no se puede deshacer!';

  @override
  String get unlockResetEncryptionDescription =>
      'Si has olvidado tu contraseña maestra, puedes restablecer el cifrado. Sin embargo, esto eliminará permanentemente todas las memorias cifradas.';

  @override
  String get unlockResetEncryptionConsequences => 'Lo que se eliminará:';

  @override
  String get unlockResetEncryptionConsequence1 =>
      'Todas las memorias cifradas (locales y en la nube)';

  @override
  String get unlockResetEncryptionConsequence2 => 'El cifrado se desactivará';

  @override
  String get unlockResetEncryptionConsequence3 =>
      'Podrás seguir usando la aplicación sin cifrado';

  @override
  String get unlockResetEncryptionConfirm => 'Eliminar memorias cifradas';

  @override
  String get unlockResetEncryptionSuccess =>
      'El cifrado se ha restablecido. Ahora puedes usar la aplicación sin contraseña maestra.';

  @override
  String get unlockResetEncryptionError => 'Error al restablecer el cifrado';

  @override
  String get draftBannerSingleTitle => 'Tienes una memoria sin terminar';

  @override
  String draftBannerSingleSubtitle(String timeAgo) {
    return 'Última edición: $timeAgo';
  }

  @override
  String draftBannerMultipleTitle(int count) {
    return 'Tienes $count memorias sin terminar';
  }

  @override
  String get draftBannerMultipleSubtitle => 'Toca para ver todas';

  @override
  String get draftBannerResume => 'Reanudar';

  @override
  String get draftBannerDelete => 'Eliminar';

  @override
  String get draftResumedSuccess => 'Borrador reanudado con éxito';

  @override
  String get draftDeleteDialogTitle => '¿Eliminar borrador?';

  @override
  String get draftDeleteDialogMessage =>
      'Este borrador será eliminado permanentemente. Esta acción no se puede deshacer.';

  @override
  String get draftDeleteCancel => 'Cancelar';

  @override
  String get draftDeleteConfirm => 'Eliminar';

  @override
  String get draftDeletedSuccess => 'Borrador eliminado con éxito';

  @override
  String get draftDeletedError => 'Error al eliminar el borrador';

  @override
  String draftListDialogTitle(int count) {
    return 'Tienes $count borradores';
  }

  @override
  String get draftListItemNoTitle => 'Memoria sin título';

  @override
  String get draftListItemNoContent => 'Sin contenido';

  @override
  String draftListItemLastModified(String timeAgo) {
    return 'Última modificación: $timeAgo';
  }

  @override
  String get timeAgoJustNow => 'justo ahora';

  @override
  String timeAgoMinutes(int count) {
    return 'hace $count minutos';
  }

  @override
  String timeAgoHours(int count) {
    return 'hace $count horas';
  }

  @override
  String timeAgoDays(int count) {
    return 'hace $count días';
  }

  @override
  String timeAgoWeeks(int count) {
    return 'hace $count semanas';
  }

  @override
  String get fileSizeTooLargeImage =>
      'El archivo de imagen es demasiado grande. El tamaño máximo es de 10 MB.';

  @override
  String get fileSizeTooLargeVideo =>
      'El archivo de vídeo es demasiado grande. El tamaño máximo es de 100 MB.';

  @override
  String get fileSizeTooLargeAudio =>
      'El archivo de audio es demasiado grande. El tamaño máximo es de 25 MB.';

  @override
  String get biometricUnlockFailedMessage =>
      'Las claves de seguridad deben recrearse después de reinstalar la aplicación. Por favor, introduce tu contraseña maestra para continuar.';

  @override
  String get quickUnlockAutoEnabledMessage =>
      '✓ Biometric unlock has been automatically enabled for you!';

  @override
  String lifelineInsightStreakDays(int count) {
    return '🔥 Racha de $count días';
  }

  @override
  String lifelineInsightMemoriesThisMonth(int count) {
    return '📝 $count recuerdos este mes';
  }

  @override
  String lifelineInsightMemoriesThisWeek(int count) {
    return '✨ $count nuevos esta semana';
  }

  @override
  String lifelineInsightReflectionsCount(int count) {
    return '⭐ $count reflexiones';
  }

  @override
  String lifelineInsightPhotosCount(int count) {
    return '📸 $count fotos';
  }

  @override
  String lifelineInsightAudioCount(int count) {
    return '🎵 $count notas de audio';
  }

  @override
  String lifelineInsightSpanningYears(int years) {
    return '📅 Abarca $years años';
  }

  @override
  String lifelineInsightTotalMemories(int count) {
    return '📖 $count momentos capturados';
  }

  @override
  String get lifelineInsightPositiveVibes =>
      '😊 Vibraciones mayormente positivas';

  @override
  String get lifelineInsightGrowthJourney => '🌱 Viaje de crecimiento';

  @override
  String get lifelineInsightBalancedEmotions => '⚖️ Emociones equilibradas';

  @override
  String get lifelineInsightStartJourney => '✍️ Comienza tu viaje';

  @override
  String get lifelineInsightBuildStreak => '💪 Construye tu racha';

  @override
  String get purchaseSuccessMessage =>
      '¡Compra exitosa! ¡Bienvenido a Premium!';

  @override
  String get graphicsQualityTitle => 'Calidad gráfica';

  @override
  String get graphicsQualityAuto => 'Auto';

  @override
  String get graphicsQualityLow => 'Baja';

  @override
  String get graphicsQualityMedium => 'Media';

  @override
  String get graphicsQualityHigh => 'Alta';

  @override
  String get graphicsQualityAutoSubtitle =>
      'Detectar automáticamente el rendimiento del dispositivo';

  @override
  String get graphicsQualityLowSubtitle =>
      'Mejor duración de batería, efectos mínimos';

  @override
  String get graphicsQualityMediumSubtitle =>
      'Rendimiento y visuales equilibrados';

  @override
  String get graphicsQualityHighSubtitle =>
      'Mejores visuales, mayor uso de batería';

  @override
  String graphicsQualityAutoDetected(String performance) {
    return 'Auto ($performance)';
  }

  @override
  String get notificationAnniversaryTitle => 'Recordatorios de aniversario';

  @override
  String get notificationAnniversarySubtitle =>
      'Recordar momentos importantes del pasado';

  @override
  String get notificationMotivationalTitle => 'Motivaciones ocasionales';

  @override
  String get notificationMotivationalSubtitle =>
      'Recordatorios suaves para capturar momentos importantes';

  @override
  String get notificationInsightTitle => 'Perspectivas emocionales';

  @override
  String get notificationInsightSubtitle =>
      'Reflexiones sobre tu viaje emocional';

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
