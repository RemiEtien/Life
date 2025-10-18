// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get createAccount => 'Neues Konto erstellen';

  @override
  String get alreadyHaveAccount => 'Ich habe bereits ein Konto';

  @override
  String get orSignInWith => 'Oder anmelden mit';

  @override
  String get passwordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get invalidEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get consentWelcomeTitle => 'Willkommen bei Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'Bevor Sie beginnen, lesen und akzeptieren Sie bitte unsere Bedingungen.';

  @override
  String get consentIAgreeTo => 'Ich habe die ';

  @override
  String get consentTermsOfService => 'Nutzungsbedingungen';

  @override
  String get consentAnd => ' und die ';

  @override
  String get consentPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get consentContinue => 'Weiter';

  @override
  String consentErrorSaving(String error) {
    return 'Fehler beim Speichern der Einstellungen: $error';
  }

  @override
  String get splashMessageInitializing => 'Initialisierung...';

  @override
  String get splashMessageCheckingSettings => 'Einstellungen werden geprüft...';

  @override
  String get splashMessageAuthenticating => 'Authentifizierung...';

  @override
  String get splashMessageSyncing => 'Deine Zeitachse wird synchronisiert...';

  @override
  String get authGateLoadingMemories => 'Erinnerungen werden geladen...';

  @override
  String get authGateAuthenticating => 'Authentifizierung...';

  @override
  String get authGateSomethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get authGateCouldNotLoad =>
      'Wir konnten Ihre Daten nicht laden. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get authGateTryAgain => 'Erneut versuchen';

  @override
  String get authGateEmptyState =>
      'Deine Lifeline ist bereit.\nTippe auf den +-Button, um deine erste Erinnerung hinzuzufügen.';

  @override
  String get authGateUnsavedDraftTitle => 'Ungespeicherte Erinnerung';

  @override
  String get authGateUnsavedDraftContent =>
      'Sie haben einen ungespeicherten Erinnerungsentwurf. Möchten Sie die Bearbeitung fortsetzen?';

  @override
  String get authGateDiscard => 'Verwerfen';

  @override
  String get authGateContinueEditing => 'Bearbeitung fortsetzen';

  @override
  String get verifyEmailTitle => 'E-Mail-Bestätigung';

  @override
  String get verifyEmailSentTo => 'Eine Bestätigungs-E-Mail wurde gesendet an:';

  @override
  String get verifyEmailInstructions =>
      'Bitte klicken Sie auf den Link in der E-Mail, um Ihre Registrierung abzuschließen.';

  @override
  String get verifyEmailResendButton => 'E-Mail erneut senden';

  @override
  String get verifyEmailCancelButton => 'Abbrechen';

  @override
  String get profileTitle => 'Profil & Einstellungen';

  @override
  String get profileSectionProfile => 'PROFIL';

  @override
  String get profileChangeNameTitle => 'Namen ändern';

  @override
  String get profileEnterYourName => 'Gib deinen Namen ein';

  @override
  String get profileSave => 'Speichern';

  @override
  String get profileCancel => 'Abbrechen';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'E-Mail';

  @override
  String get profileCountry => 'Land';

  @override
  String get profileCountryNotSelected => 'Nicht ausgewählt';

  @override
  String get profileLanguage => 'Inhaltssprache';

  @override
  String get profileLanguageDefault => 'Englisch (Standard)';

  @override
  String get profileSelectLanguage => 'Sprache auswählen';

  @override
  String get profileSectionSettings => 'EINSTELLUNGEN';

  @override
  String get profileTheme => 'Thema';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Hell';

  @override
  String get profileThemeDark => 'Dunkel';

  @override
  String get profileReauthTitle => 'Erneute Authentifizierung erforderlich';

  @override
  String get profileReauthContent =>
      'Dies ist ein sensibler Vorgang. Bitte melden Sie sich erneut an, bevor Sie fortfahren.';

  @override
  String get profileReauthButton => 'Anmelden & Löschen';

  @override
  String get profileReauthPasswordDialogTitle => 'Aktion bestätigen';

  @override
  String get profileReauthPasswordDialogContent =>
      'Um Ihr Konto zu löschen, geben Sie bitte Ihr aktuelles Passwort ein.';

  @override
  String get profilePasswordCannotBeEmpty => 'Passwort darf nicht leer sein';

  @override
  String get profileChangePasswordSuccess =>
      'Master-Passwort erfolgreich geändert!';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'Das eingegebene aktuelle Passwort ist falsch.';

  @override
  String get profileOldPasswordHint => 'Altes Passwort';

  @override
  String get profileNewPasswordHint => 'Neues Passwort';

  @override
  String get profileDeleteAccountConfirmContent =>
      'Diese Aktion ist unumkehrbar. Ihr gesamtes Konto, einschließlich aller Erinnerungen und Einstellungen, wird dauerhaft gelöscht. Um fortzufahren, halten Sie die Löschtaste 5 Sekunden lang gedrückt.';

  @override
  String get profileChangePasswordCurrentPasswordHint =>
      'Aktuelles Master-Passwort';

  @override
  String get profileChangePasswordNewPasswordHint => 'Neues Master-Passwort';

  @override
  String get profileChangePasswordInfo =>
      'Bitte geben Sie Ihr aktuelles Master-Passwort ein, um ein neues festzulegen. Dadurch wird Ihr geheimer Schlüssel neu verschlüsselt.';

  @override
  String get profileGraphics => 'Grafikqualität';

  @override
  String get profileGraphicsAuto => 'Automatisch';

  @override
  String get profileGraphicsLow => 'Niedrig';

  @override
  String get profileGraphicsMedium => 'Mittel';

  @override
  String get profileGraphicsHigh => 'Hoch';

  @override
  String get profileReminders => 'Reflexions-Erinnerungen';

  @override
  String get profileRemindersSubtitle =>
      'Erhalten Sie Benachrichtigungen für Ihre Aktionspläne';

  @override
  String get profileSectionSecurity => 'SICHERHEIT';

  @override
  String get profileChangePassword => 'Master-Passwort ändern';

  @override
  String get profileEncryptionActive =>
      'Ende-zu-Ende-Verschlüsselung ist aktiv';

  @override
  String get profileEnableEncryption =>
      'Ende-zu-Ende-Verschlüsselung aktivieren';

  @override
  String get profileEnableEncryptionSubtitle =>
      'Schützen Sie Ihre sensiblen Erinnerungen mit einem Master-Passwort.';

  @override
  String get profileCreateMasterPassword => 'Master-Passwort erstellen';

  @override
  String get profileMasterPasswordInfo =>
      'Dieses Passwort schützt Ihre Erinnerungen. Es kann nicht wiederhergestellt werden, wenn Sie es vergessen. Bitte bewahren Sie es sicher auf.';

  @override
  String get profileMasterPasswordHint => 'Master-Passwort';

  @override
  String get profileConfirmPasswordHint => 'Passwort bestätigen';

  @override
  String get profilePasswordMinLength =>
      'Das Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get profilePasswordsDoNotMatch =>
      'Die Passwörter stimmen nicht überein';

  @override
  String get profileEnable => 'Aktivieren';

  @override
  String get profileSectionHelp => 'HILFE';

  @override
  String get profileReplayTutorial => 'Tutorial wiederholen';

  @override
  String get profileReplayTutorialConfirmTitle => 'Tutorial wiederholen?';

  @override
  String get profileReplayTutorialConfirmContent =>
      'Sind Sie sicher, dass Sie das Tutorial neu starten möchten?';

  @override
  String get profileRestart => 'Neustart';

  @override
  String get profileSectionAccount => 'KONTOVERWALTUNG';

  @override
  String get profileSignOut => 'Abmelden';

  @override
  String get profileDeleteAccount => 'Konto löschen';

  @override
  String get profileDeleteAccountConfirmTitle => 'Konto löschen?';

  @override
  String get profileDelete => 'Löschen';

  @override
  String get profileDeletingAccount => 'Dein Konto wird gelöscht...';

  @override
  String get profileErrorCouldNotFindProfile =>
      'Benutzerprofil konnte nicht gefunden werden.';

  @override
  String get memoryEditNewTitle => 'Neue Erinnerung';

  @override
  String get memoryEditEditTitle => 'Erinnerung bearbeiten';

  @override
  String get memoryEditSave => 'Speichern';

  @override
  String get memoryEditTitleHint => 'Titel';

  @override
  String get memoryEditTitleValidator => 'Bitte geben Sie einen Titel ein';

  @override
  String get memoryEditDescriptionHint => 'Beschreibung';

  @override
  String get memoryEditDateLabel => 'Datum:';

  @override
  String get memoryEditSelectDateButton => 'Datum auswählen';

  @override
  String get memoryEditAmbientSoundLabel => 'Umgebungsgeräusch:';

  @override
  String get memoryEditAmbientSoundDropdownHint =>
      'Wählen Sie ein Umgebungsgeräusch';

  @override
  String get memoryEditMusicAnchorLabel => 'Musik-Anker:';

  @override
  String get memoryEditAttachTrackButton => 'Titel von Spotify anhängen';

  @override
  String get memoryEditPhotosLabel => 'Fotos:';

  @override
  String get memoryEditNoPhotosSelected => 'Keine Fotos ausgewählt';

  @override
  String get memoryEditAddPhotosButton => 'Fotos hinzufügen';

  @override
  String get memoryEditVideosLabel => 'Videos:';

  @override
  String get memoryEditNoVideosSelected => 'Keine Videos ausgewählt';

  @override
  String get memoryEditAddVideoButton => 'Video hinzufügen';

  @override
  String get memoryEditAudioNoteLabel => 'Audionotiz:';

  @override
  String get memoryEditAudioNoteSaved => 'Audionotiz gespeichert';

  @override
  String get memoryEditRecordButton => 'Aufnehmen';

  @override
  String get memoryEditStopRecordingButton => 'Aufnahme stoppen';

  @override
  String get memoryEditRecordingIndicator => 'Aufnahme...';

  @override
  String get memoryEditReflectionSectionTitle => 'Reflexion';

  @override
  String get memoryEditEncryptLabel => 'Verschlüsseln';

  @override
  String get memoryEditEncryptionInfoTooltip => 'Was ist Verschlüsselung?';

  @override
  String get memoryEditImpactPrompt =>
      'Wie hat dieses Ereignis mich beeinflusst?';

  @override
  String get memoryEditLessonPrompt => 'Welche Lektion habe ich gelernt?';

  @override
  String get memoryEditEmotionsLabel => 'Emotionen:';

  @override
  String get emotionJoy => 'Freude';

  @override
  String get emotionNostalgia => 'Nostalgie';

  @override
  String get emotionPride => 'Stolz';

  @override
  String get emotionSadness => 'Traurigkeit';

  @override
  String get emotionGratitude => 'Dankbarkeit';

  @override
  String get emotionLove => 'Liebe';

  @override
  String get emotionFear => 'Angst';

  @override
  String get emotionAnger => 'Wut';

  @override
  String get emotionSurprise => 'Überraschung';

  @override
  String get emotionDisgust => 'Ekel';

  @override
  String get memoryEditCbtHelperTitle => 'Reflexionshelfer';

  @override
  String get memoryEditCbtStep1Title =>
      'Was war der erste Gedanke oder Glaube?';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'z.B. \'Ich werde versagen\' oder \'Ich habe alles richtig gemacht\'.';

  @override
  String get memoryEditCbtStep2Title => 'Was unterstützt diesen Gedanken?';

  @override
  String get memoryEditCbtStep2Subtitle =>
      'Welche Fakten oder Ereignisse beweisen, dass dieser Gedanke wahr ist?';

  @override
  String get memoryEditCbtStep3Title =>
      'Wie ist die Sicht von der anderen Seite?';

  @override
  String get memoryEditCbtStep3Subtitle =>
      'Welche Fakten oder Ereignisse könnten den ersten Gedanken widerlegen oder in Frage stellen?';

  @override
  String get memoryEditCbtStep4Title => 'Wie kann ich das anders betrachten?';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'Formulieren Sie auf der Grundlage des oben Gesagten eine neue, ausgewogenere Perspektive.';

  @override
  String get memoryEditActionPlanTitle => 'Aktionsplan';

  @override
  String get memoryEditActionPrompt =>
      'Was ist ein kleiner Schritt, den ich unternehmen kann?';

  @override
  String get memoryEditReminderLabel => 'Erinnerung:';

  @override
  String get memoryEditReminderNotSet => 'Nicht festgelegt';

  @override
  String get memoryEditSetReminderButton => 'Datum festlegen';

  @override
  String get memoryEditYourThoughtsHint => 'Ihre Gedanken hier...';

  @override
  String get memoryEditDraftSavedMessage => 'Entwurf gespeichert';

  @override
  String get memoryEditErrorRepoUnavailable =>
      'Fehler: Repository nicht verfügbar.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'Fehler beim Speichern der Erinnerung: $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'Zum Speichern entsperren';

  @override
  String get memoryEditUnlockDialogContent =>
      'Bitte geben Sie Ihr Master-Passwort ein, um diese verschlüsselte Erinnerung zu speichern.';

  @override
  String get memoryEditMasterPasswordHint => 'Master-Passwort';

  @override
  String get memoryEditUnlockButton => 'Entsperren';

  @override
  String get memoryEditEncryptionInfoDialogTitle =>
      'Ende-zu-Ende-Verschlüsselung';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'Wenn Sie eine Erinnerung verschlüsseln, werden ihre Beschreibungs- und Reflexionsfelder mit einem Schlüssel verschlüsselt, der von Ihrem Master-Passwort abgeleitet ist.\n\nDie Daten werden in einem unlesbaren Format in der Cloud gespeichert und können nur auf Ihren Geräten mit Ihrem Passwort entschlüsselt werden.\n\nWICHTIG: Wir können Ihr Master-Passwort nicht wiederherstellen. Wenn Sie es vergessen, gehen Ihre verschlüsselten Daten für immer verloren.';

  @override
  String get memoryEditOkButton => 'OK';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'Die Berechtigung für $permissionName wurde verweigert. Bitte aktivieren Sie sie in den Einstellungen.';
  }

  @override
  String get memoryEditSettingsButton => 'Einstellungen';

  @override
  String get memoryEditNoInternetSnackbar =>
      'Für die Musiksuche ist eine Internetverbindung erforderlich.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'Intensität für \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'Zurück';

  @override
  String get memoryViewShareTooltip => 'Teilen';

  @override
  String get memoryViewEditTooltip => 'Bearbeiten';

  @override
  String get memoryViewDeleteTooltip => 'Löschen';

  @override
  String get memoryViewTabMemory => 'Erinnerung';

  @override
  String get memoryViewTabInTheWorld => 'In der Welt';

  @override
  String get memoryViewEncryptedTitle => 'Verschlüsselte Erinnerung';

  @override
  String get memoryViewReflectionTitle => 'Reflexion';

  @override
  String get memoryViewReflectionImpact => 'Auswirkung';

  @override
  String get memoryViewReflectionLesson => 'Gelerntes';

  @override
  String get memoryViewCbtStep1Title => 'Erster Gedanke oder Glaube';

  @override
  String get memoryViewCbtStep2Title => 'Beweise für diesen Gedanken';

  @override
  String get memoryViewCbtStep3Title => 'Beweise gegen diesen Gedanken';

  @override
  String get memoryViewCbtStep4Title =>
      'Neue, ausgewogene Perspektive (Neubewertung)';

  @override
  String memoryViewActionReminder(String date) {
    return 'Erinnerung: $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'Als unvollständig markieren';

  @override
  String get memoryViewMarkCompleteTooltip => 'Als vollständig markieren';

  @override
  String get memoryViewUnlockDialogTitle => 'Erinnerung entsperren';

  @override
  String get memoryViewUnlockDialogContent =>
      'Geben Sie Ihr Master-Passwort ein, um diesen Inhalt anzuzeigen.';

  @override
  String get memoryViewIncorrectPassword => 'Falsches Passwort.';

  @override
  String get memoryViewUnlockButton => 'Entsperren';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'Ihr Profil konnte nicht geladen werden, um historische Daten abzurufen.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'Historische Daten für diesen Tag konnten nicht geladen werden.';

  @override
  String get memoryViewNoHistoricalData =>
      'Für diesen Tag sind keine historischen Daten verfügbar.';

  @override
  String get memoryViewErrorCouldNotLoadTrack =>
      'Titel konnte nicht geladen werden';

  @override
  String get memoryViewTabNews => 'Nachrichten';

  @override
  String get memoryViewTabMusic => 'Musik';

  @override
  String get memoryViewNoDataForDay => 'Keine Daten für diesen Tag.';

  @override
  String get memoryViewNoNewsForDay =>
      'Keine historischen Nachrichten für diesen Tag.';

  @override
  String memoryViewNewsSource(String source) {
    return 'Quelle: $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'Löschen bestätigen';

  @override
  String get memoryViewConfirmDeleteContent =>
      'Diese Aktion ist unumkehrbar. Um fortzufahren, halten Sie die Löschtaste 5 Sekunden lang gedrückt.';

  @override
  String get memoryViewDeleteButton => 'LÖSCHEN';

  @override
  String get memoryViewErrorLoadingProfile =>
      'Wir konnten Ihr Profil nicht laden. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get memoryViewErrorLocalDb =>
      'Fehler: Zugriff auf die lokale Datenbank nicht möglich.';

  @override
  String get memoryViewMemoryDeleted => 'Erinnerung gelöscht';

  @override
  String get memoryViewSharingNotImplemented =>
      'Die Freigabefunktion ist noch nicht implementiert.';

  @override
  String get memoryViewActionCompleted => 'Aktion als abgeschlossen markiert!';

  @override
  String get memoryViewActionIncomplete => 'Aktion als unvollständig markiert.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'Fehler beim Aktualisieren der Aktion: $error';
  }

  @override
  String get memoryViewContentEncrypted => 'Inhalt ist verschlüsselt';

  @override
  String get memoryViewReflectionEncrypted => 'Reflexion ist verschlüsselt';

  @override
  String get memoryViewMediaEncrypted => 'Medien sind verschlüsselt';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'Umgebungsgeräusch: $sound';
  }

  @override
  String get memoryViewAudioNote => 'Audionotiz';

  @override
  String get spotifySearchTitle => 'Spotify-Titel suchen';

  @override
  String get spotifySearchHint => 'Songtitel oder Künstler';

  @override
  String get documentErrorLoading => 'Dokument konnte nicht geladen werden.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'Erinnerungen: $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'Zeitraum: $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status ($jobs übrig)';
  }

  @override
  String get lifelineCalculating => 'Berechnung...';

  @override
  String lifelineScaleValue(int scale) {
    return 'Maßstab: $scale%';
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
  String get lifelineShowFullTimelineTooltip => 'Gesamte Zeitachse anzeigen';

  @override
  String get lifelineVisualSettingsTooltip => 'Visuelle Einstellungen';

  @override
  String get lifelineMenuProfile => 'Profil';

  @override
  String get lifelineMenuDebugOn => 'Debug Ein';

  @override
  String get lifelineMenuDebugOff => 'Debug Aus';

  @override
  String get lifelineMenuSignOut => 'Abmelden';

  @override
  String get lifelineSearchHint => 'Suchen...';

  @override
  String get lifelineMemoriesListTitle => 'Erinnerungen';

  @override
  String get lifelineVisualSettingsDialogTitle => 'Visuelle Einstellungen';

  @override
  String get lifelineVisualSettingsSpeed => 'Geschwindigkeit';

  @override
  String get lifelineVisualSettingsAmplitude => 'Amplitude';

  @override
  String get lifelineVisualSettingsYearLine => 'Position der Jahreslinie';

  @override
  String get lifelineVisualSettingsBranchDensity => 'Zweig-Dichte';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'Zweig-Intensität';

  @override
  String get lifelineVisualSettingsAnimate => 'Animieren';

  @override
  String get lifelineVisualSettingsDoneButton => 'Fertig';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'Ihre persönliche Reise, visualisiert. Machen wir eine kurze Tour, um zu sehen, wie Sie anfangen können, Ihre Momente festzuhalten.';

  @override
  String get onboardingSkipButton => 'Fürs Erste überspringen';

  @override
  String get onboardingBeginTourButton => 'Tour beginnen';

  @override
  String get onboardingGesturesTitle => 'Navigieren Sie durch Ihre Zeitachse';

  @override
  String get onboardingGestureSwipe => 'Wischen';

  @override
  String get onboardingGesturePinch => 'Zum Zoomen zusammenziehen';

  @override
  String get onboardingGestureDoubleTap => 'Doppeltippen';

  @override
  String get onboardingGesturesSubtitle =>
      'Ihre Lifeline wird mit Ihnen wachsen. Ziehen Sie zusammen zum Zoomen, doppeltippen Sie zum schnellen Hineinzoomen. Wischen Sie nach links und rechts, um durch die Zeit zu navigieren.';

  @override
  String get onboardingContinueButton => 'Weiter';

  @override
  String get onboardingFinalTitle => 'Sie sind bereit!';

  @override
  String get onboardingFinalSubtitle =>
      'Ihre Reise beginnt jetzt. Fangen Sie an, die wichtigen Momente festzuhalten.';

  @override
  String get onboardingStartJourneyButton => 'Meine Reise beginnen';

  @override
  String get onboardingSkipTourButton => 'Tour überspringen';

  @override
  String get onboardingLifelineIntroText =>
      'Das ist Ihre Lifeline. Jede Erinnerung, die Sie hinzufügen, erzeugt einen einzigartigen Knoten auf diesem Pfad und bildet eine wunderschöne Karte Ihrer Lebensreise.';

  @override
  String get onboardingLifelineIntroButton => 'Weiter';

  @override
  String get onboardingAddMemoryText =>
      'Tippen Sie hier, um eine neue Erinnerung hinzuzufügen. Für jeden festgehaltenen Moment erscheint ein Knoten auf Ihrer Lifeline.';

  @override
  String get onboardingNavGesturesText =>
      'Großartig! Lassen Sie uns nun lernen, wie Sie durch Ihre Zeitachse navigieren.';

  @override
  String get onboardingControlsPanelText =>
      'Verwenden Sie diese Steuerelemente, um Ihre Ansicht zu verwalten. Sie können die Zeitachse neu zentrieren, visuelle Effekte anpassen und auf Ihr Profil zugreifen.';

  @override
  String get onboardingControlsPanelButton => 'Verstanden';

  @override
  String get onboardingStatsCardText =>
      'Diese Karte zeigt eine Zusammenfassung Ihrer Erinnerungen. Tippen Sie darauf, um eine vollständige, durchsuchbare Liste Ihrer gesamten Reise zu öffnen.';

  @override
  String get onboardingStatsCardButton => 'Fast geschafft!';

  @override
  String get audioPlayerPreviousTooltip => 'Vorheriger Titel';

  @override
  String get audioPlayerPlayTooltip => 'Abspielen';

  @override
  String get audioPlayerPauseTooltip => 'Pause';

  @override
  String get audioPlayerNextTooltip => 'Nächster Titel';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'Schritt $step: ';
  }

  @override
  String get premiumBannerTitle => 'Lifeline Premium freischalten';

  @override
  String get premiumBannerSubtitle =>
      'Unbegrenzte Medien, erweiterte Reflexion, historischer Kontext und mehr!';

  @override
  String get premiumDialogTitle => 'Auf Premium upgraden';

  @override
  String premiumDialogContent(String feature) {
    return 'Schalten Sie die Möglichkeit frei, $feature und erhalten Sie Zugriff auf alle Premium-Funktionen.';
  }

  @override
  String get premiumDialogGoPremium => 'Premium holen';

  @override
  String get premiumFeaturePhotos => 'weitere Fotos hinzuzufügen';

  @override
  String get premiumFeatureVideos => 'ein Video hinzuzufügen';

  @override
  String get premiumFeatureAudio => 'eine Audionotiz hinzuzufügen';

  @override
  String get premiumFeatureSpotify => 'einen Spotify-Titel hinzuzufügen';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'Entfalten Sie Ihr volles Potenzial';

  @override
  String get premiumScreenHeaderSubtitle =>
      'Gehen Sie mit Lifeline Premium über die Grenzen hinaus und holen Sie das Beste aus Ihrer Reise der Selbstfindung heraus.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'Unbegrenzte Fotos & Videos';

  @override
  String get premiumFeatureUnlimitedAudio => 'Unbegrenzte Audionotizen';

  @override
  String get premiumFeatureUnlimitedSpotify => 'Unbegrenzte Spotify-Titel';

  @override
  String get premiumFeatureAdvancedCbt => 'Erweiterter Reflexionshelfer';

  @override
  String get premiumFeatureActionReminders => 'Aktionsplan-Erinnerungen';

  @override
  String get premiumFeatureHistoricalContext =>
      'Historischer \'In der Welt\'-Kontext';

  @override
  String get premiumFeatureSoundLibrary =>
      'Vollständige Umgebungsgeräusch-Bibliothek';

  @override
  String get premiumScreenYearlyPopular =>
      'Am beliebtesten & Bestes Preis-Leistungs-Verhältnis';

  @override
  String get premiumScreenProcessingPurchase => 'Verarbeite Kauf...';

  @override
  String get premiumScreenRestore => 'Käufe wiederherstellen';

  @override
  String get premiumScreenTerms => 'Nutzungsbedingungen';

  @override
  String get premiumScreenPrivacy => 'Datenschutzrichtlinie';

  @override
  String get premiumStatusTitle => 'Premium-Mitglied';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'Läuft am $date ab';
  }

  @override
  String get onboardingEncryptionTitle => 'Ihre Erinnerungen, gesichert';

  @override
  String get onboardingEncryptionSubtitle =>
      'Lifeline bietet eine Ende-zu-Ende-Verschlüsselung. Das bedeutet, dass nur Sie Ihre privaten Erinnerungen lesen können. Richten wir Ihr Master-Passwort ein, um sie zu schützen.';

  @override
  String get onboardingEncryptionSetupButton => 'Jetzt einrichten';

  @override
  String get onboardingEncryptionLaterButton => 'Vielleicht später';

  @override
  String get onboardingEncryptionActiveTitle => 'Verschlüsselung ist aktiv';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'Deine Erinnerungen sind bereits geschützt. Du kannst dein Master-Passwort in den Profileinstellungen verwalten.';

  @override
  String get onboardingEncryptionContinueButton => 'Weiter';

  @override
  String get memoryEditEncryptMemory => 'Diese Erinnerung verschlüsseln';

  @override
  String get memoryEditSetupEncryptionTitle => 'Verschlüsselung aktivieren?';

  @override
  String get memoryEditSetupEncryptionContent =>
      'Um diese Erinnerung zu schützen, müssen Sie zuerst ein Master-Passwort erstellen. Dies wird Ihr einziger Schlüssel für alle verschlüsselten Einträge sein.';

  @override
  String get memoryEditCreatePasswordButton => 'Master-Passwort erstellen';

  @override
  String get memoryViewExportPdf => 'Als PDF teilen';

  @override
  String get shareActionTitle => 'Zu Lifeline hinzufügen';

  @override
  String get shareActionSubtitle => 'Was möchten Sie mit diesen Dateien tun?';

  @override
  String get shareCreateNewMemory => 'Neue Erinnerung erstellen';

  @override
  String get shareAddToExisting => 'Zu bestehender Erinnerung hinzufügen';

  @override
  String get selectMemoryTitle => 'Erinnerung auswählen';

  @override
  String get selectMemorySearchHint => 'Suche nach Titel oder Inhalt...';

  @override
  String get selectMemoryEmpty => 'Keine Erinnerungen gefunden';

  @override
  String get memoryUpdatedSuccess => 'Erinnerung erfolgreich aktualisiert!';

  @override
  String unlockFailedAttemptsRemaining(int count) {
    return 'Falsches Passwort. Noch $count Versuche.';
  }

  @override
  String unlockTooManyAttempts(int seconds) {
    return 'Zu viele Versuche. Bitte versuche es in $seconds Sekunden erneut.';
  }

  @override
  String get unlocking => 'Entsperren...';

  @override
  String get exportingPdf => 'PDF wird vorbereitet...';

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get profileEnableQuickUnlock => 'Schnellentsperren aktivieren';

  @override
  String get profileQuickUnlockSubtitle =>
      'Verwende deinen Fingerabdruck, dein Gesicht oder die Geräte-PIN zum Entsperren.';

  @override
  String get profileRequireBiometricsForMemoryTitle =>
      'Biometrie für jede Erinnerung anfordern';

  @override
  String get profileRequireBiometricsForMemorySubtitle =>
      'Wenn aktiviert, ist eine Authentifizierung erforderlich, um einzelne verschlüsselte Erinnerungen zu öffnen oder zu bearbeiten – selbst wenn die App entsperrt ist.';

  @override
  String get quickUnlockPrompt =>
      'Authentifiziere dich, um Lifeline zu entsperren';

  @override
  String get quickUnlockEnablePrompt =>
      'Authentifiziere dich, um Schnellentsperren zu aktivieren';

  @override
  String get masterPasswordRequiredTitle => 'Master-Passwort erforderlich';

  @override
  String get masterPasswordRequiredContent =>
      'Bitte gib dein Master-Passwort ein, um diese Funktion zu aktivieren.';

  @override
  String get unlockScreenTitle => 'Lifeline entsperren';

  @override
  String get unlockWithBiometrics => 'Mit Biometrie entsperren';

  @override
  String get unlockEnterMasterPassword => 'Master-Passwort eingeben';

  @override
  String get unlockForgotPassword => 'Passwort vergessen?';

  @override
  String get unlockResetEncryptionTitle => 'Verschlüsselung zurücksetzen';

  @override
  String get unlockResetEncryptionWarning =>
      '⚠️ WARNUNG: Diese Aktion kann nicht rückgängig gemacht werden!';

  @override
  String get unlockResetEncryptionDescription =>
      'Wenn du dein Master-Passwort vergessen hast, kannst du die Verschlüsselung zurücksetzen. Dies führt jedoch zum unwiderruflichen Löschen aller verschlüsselten Erinnerungen.';

  @override
  String get unlockResetEncryptionConsequences => 'Was wird gelöscht:';

  @override
  String get unlockResetEncryptionConsequence1 =>
      'Alle verschlüsselten Erinnerungen (lokal und in der Cloud)';

  @override
  String get unlockResetEncryptionConsequence2 =>
      'Die Verschlüsselung wird deaktiviert';

  @override
  String get unlockResetEncryptionConsequence3 =>
      'Du kannst die App weiterhin ohne Verschlüsselung nutzen';

  @override
  String get unlockResetEncryptionConfirm =>
      'Verschlüsselte Erinnerungen löschen';

  @override
  String get unlockResetEncryptionSuccess =>
      'Verschlüsselung wurde zurückgesetzt. Du kannst die App jetzt ohne Master-Passwort verwenden.';

  @override
  String get unlockResetEncryptionError =>
      'Verschlüsselung konnte nicht zurückgesetzt werden';

  @override
  String get draftBannerSingleTitle => 'Du hast eine unfertige Erinnerung';

  @override
  String draftBannerSingleSubtitle(String timeAgo) {
    return 'Zuletzt bearbeitet: $timeAgo';
  }

  @override
  String draftBannerMultipleTitle(int count) {
    return 'Du hast $count unfertige Erinnerungen';
  }

  @override
  String get draftBannerMultipleSubtitle => 'Tippen, um alle anzuzeigen';

  @override
  String get draftBannerResume => 'Fortsetzen';

  @override
  String get draftBannerDelete => 'Löschen';

  @override
  String get draftResumedSuccess => 'Entwurf erfolgreich fortgesetzt';

  @override
  String get draftDeleteDialogTitle => 'Entwurf löschen?';

  @override
  String get draftDeleteDialogMessage =>
      'Dieser Entwurf wird dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get draftDeleteCancel => 'Abbrechen';

  @override
  String get draftDeleteConfirm => 'Löschen';

  @override
  String get draftDeletedSuccess => 'Entwurf erfolgreich gelöscht';

  @override
  String get draftDeletedError => 'Fehler beim Löschen des Entwurfs';

  @override
  String draftListDialogTitle(int count) {
    return 'Du hast $count Entwürfe';
  }

  @override
  String get draftListItemNoTitle => 'Unbenannte Erinnerung';

  @override
  String get draftListItemNoContent => 'Kein Inhalt';

  @override
  String draftListItemLastModified(String timeAgo) {
    return 'Zuletzt geändert: $timeAgo';
  }

  @override
  String get timeAgoJustNow => 'gerade eben';

  @override
  String timeAgoMinutes(int count) {
    return 'vor $count Minuten';
  }

  @override
  String timeAgoHours(int count) {
    return 'vor $count Stunden';
  }

  @override
  String timeAgoDays(int count) {
    return 'vor $count Tagen';
  }

  @override
  String timeAgoWeeks(int count) {
    return 'vor $count Wochen';
  }

  @override
  String get fileSizeTooLargeImage =>
      'Die Bilddatei ist zu groß. Maximale Größe beträgt 10 MB.';

  @override
  String get fileSizeTooLargeVideo =>
      'Die Videodatei ist zu groß. Maximale Größe beträgt 100 MB.';

  @override
  String get fileSizeTooLargeAudio =>
      'Die Audiodatei ist zu groß. Maximale Größe beträgt 25 MB.';

  @override
  String get biometricUnlockFailedMessage =>
      'Nach der Neuinstallation der App müssen Sicherheitsschlüssel neu erstellt werden. Bitte geben Sie Ihr Master-Passwort ein, um fortzufahren.';

  @override
  String get quickUnlockAutoEnabledMessage =>
      '✓ Biometrische Entsperrung wurde automatisch für Sie aktiviert!';

  @override
  String lifelineInsightStreakDays(int count) {
    return '🔥 $count Tage Streak';
  }

  @override
  String lifelineInsightMemoriesThisMonth(int count) {
    return '📝 $count Erinnerungen in diesem Monat';
  }

  @override
  String lifelineInsightMemoriesThisWeek(int count) {
    return '✨ $count neue diese Woche';
  }

  @override
  String lifelineInsightReflectionsCount(int count) {
    return '⭐ $count Reflexionen';
  }

  @override
  String lifelineInsightPhotosCount(int count) {
    return '📸 $count Fotos';
  }

  @override
  String lifelineInsightAudioCount(int count) {
    return '🎵 $count Audionotizen';
  }

  @override
  String lifelineInsightSpanningYears(int years) {
    return '📅 Umfasst $years Jahre';
  }

  @override
  String lifelineInsightTotalMemories(int count) {
    return '📖 $count erfasste Momente';
  }

  @override
  String get lifelineInsightPositiveVibes => '😊 Überwiegend positive Stimmung';

  @override
  String get lifelineInsightGrowthJourney => '🌱 Reise des Wachstums';

  @override
  String get lifelineInsightBalancedEmotions => '⚖️ Ausgeglichene Emotionen';

  @override
  String get lifelineInsightStartJourney => '✍️ Beginne deine Reise';

  @override
  String get lifelineInsightBuildStreak => '💪 Baue deinen Streak auf';

  @override
  String get purchaseSuccessMessage =>
      'Kauf erfolgreich! Willkommen bei Premium!';

  @override
  String get graphicsQualityTitle => 'Grafikqualität';

  @override
  String get graphicsQualityAuto => 'Automatisch';

  @override
  String get graphicsQualityLow => 'Niedrig';

  @override
  String get graphicsQualityMedium => 'Mittel';

  @override
  String get graphicsQualityHigh => 'Hoch';

  @override
  String get graphicsQualityAutoSubtitle =>
      'Geräteleistung automatisch erkennen';

  @override
  String get graphicsQualityLowSubtitle =>
      'Beste Akkulaufzeit, minimale Effekte';

  @override
  String get graphicsQualityMediumSubtitle => 'Ausgewogene Leistung und Optik';

  @override
  String get graphicsQualityHighSubtitle =>
      'Beste Grafik, höherer Akkuverbrauch';

  @override
  String graphicsQualityAutoDetected(String performance) {
    return 'Auto ($performance)';
  }

  @override
  String get notificationAnniversaryTitle => 'Jahrestags-Erinnerungen';

  @override
  String get notificationAnniversarySubtitle =>
      'An wichtige Momente aus der Vergangenheit erinnern';

  @override
  String get notificationMotivationalTitle => 'Gelegentliche Motivationen';

  @override
  String get notificationMotivationalSubtitle =>
      'Sanfte Erinnerungen, wichtige Momente festzuhalten';

  @override
  String get notificationInsightTitle => 'Emotionale Einblicke';

  @override
  String get notificationInsightSubtitle =>
      'Reflexionen über Ihre emotionale Reise';

  @override
  String get emotionVisualizationTitle => '🎨 Emotions-Visualisierung';

  @override
  String get emotionVisualizationSubtitle => 'Emotions-Anzeige anpassen';

  @override
  String get emotionVisualizationTimelineSection => 'Auf der Lebenslinie:';

  @override
  String get emotionVisualizationLevel1Title => 'Stufe 1: Jährlicher Verlauf';

  @override
  String get emotionVisualizationLevel1Subtitle =>
      'Allgemeines Emotions-Leuchten (Zoom < 250%)';

  @override
  String get emotionVisualizationLevel2Title => 'Stufe 2: Monatliche Cluster';

  @override
  String get emotionVisualizationLevel2Subtitle =>
      'Emotionen pro Monat (Zoom 250%-460%)';

  @override
  String get emotionVisualizationLevel3Title => 'Stufe 3: Knoten-Aura';

  @override
  String get emotionVisualizationLevel3Subtitle =>
      'Leuchten um Knoten (Zoom > 460%)';

  @override
  String get emotionVisualizationEnable => 'Aktivieren';

  @override
  String get emotionVisualizationIntensity => 'Intensität';

  @override
  String get emotionVisualizationRadius => 'Radius';

  @override
  String get emotionVisualizationRadiusMultiplier => 'Radius (Multiplikator)';

  @override
  String get emotionVisualizationBlur => 'Unschärfe';

  @override
  String get emotionVisualizationBlurMultiplier => 'Unschärfe (Multiplikator)';

  @override
  String get emotionVisualizationSaturation => 'Sättigung';

  @override
  String get emotionVisualizationMemoryViewSection =>
      'Bei Erinnerungs-Ansicht:';

  @override
  String get emotionVisualizationMemoryGradientTitle => 'Emotions-Verlauf';

  @override
  String get emotionVisualizationMemoryGradientSubtitle =>
      'Farbiger Hintergrund basierend auf Emotionen';

  @override
  String get emotionVisualizationMemoryParticlesTitle => 'Emotions-Partikel';

  @override
  String get emotionVisualizationMemoryParticlesSubtitle =>
      'Animierte Partikel (Premium)';

  @override
  String get emotionVisualizationPhotoColorGradingTitle => 'Foto-Farbkorrektur';

  @override
  String get emotionVisualizationPhotoColorGradingSubtitle =>
      'Fotos an Emotionen anpassen (Premium)';

  @override
  String get profileCreationErrorTitle => 'Profil konnte nicht erstellt werden';

  @override
  String profileCreationErrorAttemptsMessage(int attempts) {
    return 'Wir haben es $attempts Mal versucht, konnten Ihr Profil jedoch nicht erstellen.';
  }

  @override
  String get profileCreationErrorReasons =>
      'Dies könnte folgende Ursachen haben:';

  @override
  String get profileCreationErrorReasonsList =>
      '• Probleme mit der Netzwerkverbindung\n• Serverprobleme\n• Berechtigungsfehler';

  @override
  String get profileCreationErrorTryAgain => 'Erneut versuchen';

  @override
  String get profileCreationErrorLogout => 'Abmelden';

  @override
  String get profileCreationErrorContactSupport => 'Support kontaktieren';

  @override
  String get shareDialogErrorLoadingProfile => 'Fehler beim Laden des Profils';

  @override
  String get aiSettingsTitle => 'AI-Funktionen';

  @override
  String get aiSettingsSubtitleEnabled => 'AI analysiert Ihre Erinnerungen';

  @override
  String get aiSettingsSubtitleDisabled => 'AI-Funktionen sind deaktiviert';

  @override
  String get aiSettingsMasterSwitch => 'AI-Funktionen aktivieren';

  @override
  String get aiSettingsMasterSwitchSubtitle =>
      'AI analysiert Ihre Erinnerungen, um Muster zu finden';

  @override
  String get aiSettingsSmartPrompts => 'Intelligente Vorschläge';

  @override
  String get aiSettingsSmartPromptsSubtitle =>
      'AI schlägt Fragen vor, während Sie schreiben';

  @override
  String get aiSettingsSmartPromptsInEdit =>
      'In Erinnerungsbearbeitung anzeigen';

  @override
  String get aiSettingsPatternAnalysis => 'Musteranalyse';

  @override
  String get aiSettingsPatternAnalysisSubtitle =>
      'Wöchentliche Analyse von Mustern und Zyklen';

  @override
  String get aiSettingsPatternAnalysisEnable => 'Musteranalyse aktivieren';

  @override
  String get aiSettingsPatternAnalysisMonthly => 'In Monatsansicht anzeigen';

  @override
  String get aiSettingsPatternAnalysisMemory =>
      'In Erinnerungsansicht anzeigen';

  @override
  String get aiSettingsPatternAnalysisList => 'In Erinnerungsliste anzeigen';

  @override
  String get aiSettingsPredictiveInsights => 'Vorausschauende Einblicke';

  @override
  String get aiSettingsPredictiveInsightsSubtitle =>
      'AI sagt basierend auf Ihrem Verlauf voraus';

  @override
  String get aiSettingsPredictiveInsightsEnable =>
      'Vorausschauende Einblicke aktivieren';

  @override
  String get aiSettingsPredictiveInsightsEdit =>
      'In Erinnerungsbearbeitung anzeigen';

  @override
  String get aiSettingsPredictiveInsightsNotifications =>
      'Proaktive Benachrichtigungen';

  @override
  String get aiSettingsPredictiveInsightsNotificationsSubtitle =>
      'Benachrichtigt werden, wenn AI ein Muster erkennt';

  @override
  String get aiSettingsPrivacyTitle => 'Datenschutz';

  @override
  String get aiSettingsPrivacySubtitle =>
      'Kontrollieren Sie, worauf AI zugreifen kann';

  @override
  String get aiSettingsPrivacyEncrypted =>
      'Verschlüsselte Erinnerungen verarbeiten';

  @override
  String get aiSettingsPrivacyEncryptedSubtitle =>
      'AI erlauben, verschlüsselte Inhalte zu analysieren';

  @override
  String get aiSettingsPrivacyInfoTitle => 'AI-Datenschutz';

  @override
  String get aiSettingsPrivacyInfoContent =>
      'Ihre Erinnerungen werden zur Analyse an Google Gemini AI gesendet. Google speichert Ihre Daten NICHT dauerhaft. Die gesamte Verarbeitung ist vorübergehend.\n\nVerschlüsselte Erinnerungen werden NICHT an AI gesendet, es sei denn, Sie aktivieren dies ausdrücklich oben.\n\nSie können AI-Funktionen jederzeit deaktivieren.';

  @override
  String get aiSettingsBadgeFree => 'KOSTENLOS';

  @override
  String get aiSettingsBadgePremium => 'PREMIUM';

  @override
  String get aiSettingsUpgradeButton => 'Upgraden';

  @override
  String get aiSettingsUpgradeDialogContent =>
      'Premium-Funktionen demnächst verfügbar!';

  @override
  String get aiConsentDialogTitle => 'AI-Funktionen aktivieren?';

  @override
  String get aiConsentDialogBenefit1 => 'Nachdenkliche Fragen vorschlagen';

  @override
  String get aiConsentDialogBenefit2 => 'Wiederkehrende Muster finden';

  @override
  String get aiConsentDialogBenefit3 =>
      'Negative Zyklen vorhersagen und verhindern helfen';

  @override
  String get aiConsentDialogPrivacyTitle => 'Datenschutzgarantie:';

  @override
  String get aiConsentDialogPrivacy1 => 'Betrieben von Google Gemini';

  @override
  String get aiConsentDialogPrivacy2 =>
      'Ihre Daten werden NICHT von Google gespeichert';

  @override
  String get aiConsentDialogPrivacy3 =>
      'Verschlüsselte Erinnerungen bleiben verschlüsselt';

  @override
  String get aiConsentDialogPrivacy4 => 'Sie kontrollieren, was AI sehen kann';

  @override
  String get aiConsentDialogPrivacyNote =>
      'Durch Aktivierung von AI stimmen Sie zu, dass Ihre nicht verschlüsselten Erinnerungen zur Analyse an Google Gemini gesendet werden. Google verarbeitet Daten vorübergehend (speichert sie nicht dauerhaft).';

  @override
  String get aiConsentDialogCancel => 'Abbrechen';

  @override
  String get aiConsentDialogEnable => 'AI aktivieren';

  @override
  String get aiEncryptedWarningTitle =>
      'Verschlüsselte Erinnerungen verarbeiten?';

  @override
  String get aiEncryptedWarningContent =>
      'Dies sendet Ihre verschlüsselten Erinnerungen zur Analyse an Google Gemini AI.\n\nObwohl Gemini Daten nicht dauerhaft speichert, werden Ihre verschlüsselten Inhalte während der Verarbeitung vorübergehend für die AI sichtbar sein.\n\nAktivieren Sie dies nur, wenn Sie damit einverstanden sind, dass Googles AI Ihre verschlüsselten Erinnerungen sieht.';

  @override
  String get aiEncryptedWarningCancel => 'Abbrechen';

  @override
  String get aiEncryptedWarningEnable => 'Aktivieren';

  @override
  String get aiNoInternetTitle => 'Keine Internetverbindung';

  @override
  String get aiNoInternetMessage =>
      'AI-Funktionen benötigen eine Internetverbindung, um zu funktionieren. Bitte verbinden Sie sich mit WLAN oder mobilen Daten und versuchen Sie es erneut.';

  @override
  String get aiNoInternetRetry => 'Erneut versuchen';

  @override
  String get aiNoInternetDismiss => 'Schließen';
}
