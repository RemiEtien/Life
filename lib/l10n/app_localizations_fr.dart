// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get register => 'S\'inscrire';

  @override
  String get createAccount => 'Créer un nouveau compte';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get orSignInWith => 'Ou se connecter avec';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get invalidEmail => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get consentWelcomeTitle => 'Bienvenue sur Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'Avant de commencer, veuillez lire et accepter nos conditions.';

  @override
  String get consentIAgreeTo => 'J\'ai lu et j\'accepte les ';

  @override
  String get consentTermsOfService => 'Conditions d\'utilisation';

  @override
  String get consentAnd => ' et la ';

  @override
  String get consentPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get consentContinue => 'Continuer';

  @override
  String consentErrorSaving(String error) {
    return 'Erreur lors de l\'enregistrement des paramètres : $error';
  }

  @override
  String get splashMessageInitializing => 'Initialisation...';

  @override
  String get splashMessageCheckingSettings => 'Vérification des paramètres...';

  @override
  String get splashMessageAuthenticating => 'Authentification...';

  @override
  String get splashMessageSyncing => 'Synchronisation de votre timeline...';

  @override
  String get authGateLoadingMemories => 'Chargement des souvenirs...';

  @override
  String get authGateAuthenticating => 'Authentification...';

  @override
  String get authGateSomethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get authGateCouldNotLoad =>
      'Nous n\'avons pas pu charger vos données. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get authGateTryAgain => 'Réessayer';

  @override
  String get authGateEmptyState =>
      'Votre Lifeline est prête.\nAppuyez sur le bouton + pour ajouter votre premier souvenir.';

  @override
  String get authGateUnsavedDraftTitle => 'Souvenir non enregistré';

  @override
  String get authGateUnsavedDraftContent =>
      'Vous avez un brouillon de souvenir non enregistré. Voulez-vous continuer à le modifier ?';

  @override
  String get authGateDiscard => 'Annuler';

  @override
  String get authGateContinueEditing => 'Continuer la modification';

  @override
  String get verifyEmailTitle => 'Vérification de l\'e-mail';

  @override
  String get verifyEmailSentTo => 'Un e-mail de vérification a été envoyé à :';

  @override
  String get verifyEmailInstructions =>
      'Veuillez cliquer sur le lien dans l\'e-mail pour finaliser votre inscription.';

  @override
  String get verifyEmailResendButton => 'Renvoyer l\'e-mail';

  @override
  String get verifyEmailCancelButton => 'Annuler';

  @override
  String get profileTitle => 'Profil et paramètres';

  @override
  String get profileSectionProfile => 'PROFIL';

  @override
  String get profileChangeNameTitle => 'Changer de nom';

  @override
  String get profileEnterYourName => 'Entrez votre nom';

  @override
  String get profileSave => 'Enregistrer';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get profileName => 'Nom';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileCountry => 'Pays';

  @override
  String get profileCountryNotSelected => 'Non sélectionné';

  @override
  String get profileLanguage => 'Langue de l\'interface';

  @override
  String get profileLanguageDefault => 'Français (par défaut)';

  @override
  String get profileSelectLanguage => 'Sélectionner la langue';

  @override
  String get profileSectionSettings => 'PARAMÈTRES';

  @override
  String get profileTheme => 'Thème';

  @override
  String get profileThemeSystem => 'Système';

  @override
  String get profileThemeLight => 'Clair';

  @override
  String get profileThemeDark => 'Sombre';

  @override
  String get profileReauthTitle => 'Ré-authentification requise';

  @override
  String get profileReauthContent =>
      'Ceci est une opération sensible. Veuillez vous reconnecter avant de continuer.';

  @override
  String get profileReauthButton => 'Se connecter et supprimer';

  @override
  String get profileReauthPasswordDialogTitle => 'Confirmer l\'action';

  @override
  String get profileReauthPasswordDialogContent =>
      'Pour supprimer votre compte, veuillez saisir votre mot de passe actuel.';

  @override
  String get profilePasswordCannotBeEmpty =>
      'Le mot de passe ne peut pas être vide';

  @override
  String get profileChangePasswordSuccess =>
      'Mot de passe principal modifié avec succès !';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'Le mot de passe principal actuel que vous avez entré est incorrect.';

  @override
  String get profileOldPasswordHint => 'Ancien mot de passe';

  @override
  String get profileNewPasswordHint => 'Nouveau mot de passe';

  @override
  String get profileDeleteAccountConfirmContent =>
      'Cette action est irréversible. L\'intégralité de votre compte, y compris tous les souvenirs et paramètres, sera définitivement supprimée. Pour continuer, maintenez le bouton de suppression enfoncé pendant 5 secondes.';

  @override
  String get profileChangePasswordCurrentPasswordHint =>
      'Mot de passe principal actuel';

  @override
  String get profileChangePasswordNewPasswordHint =>
      'Nouveau mot de passe principal';

  @override
  String get profileChangePasswordInfo =>
      'Veuillez saisir votre mot de passe principal actuel pour en définir un nouveau. Cela chiffrera à nouveau votre clé secrète.';

  @override
  String get profileGraphics => 'Qualité graphique';

  @override
  String get profileGraphicsAuto => 'Automatique';

  @override
  String get profileGraphicsLow => 'Basse';

  @override
  String get profileGraphicsMedium => 'Moyenne';

  @override
  String get profileGraphicsHigh => 'Élevée';

  @override
  String get profileReminders => 'Rappels de réflexion';

  @override
  String get profileRemindersSubtitle =>
      'Recevoir des notifications pour vos plans d\'action';

  @override
  String get profileSectionSecurity => 'SÉCURITÉ';

  @override
  String get profileChangePassword => 'Changer le mot de passe principal';

  @override
  String get profileEncryptionActive =>
      'Le chiffrement de bout en bout est actif';

  @override
  String get profileEnableEncryption =>
      'Activer le chiffrement de bout en bout';

  @override
  String get profileEnableEncryptionSubtitle =>
      'Protégez vos souvenirs sensibles avec un mot de passe principal.';

  @override
  String get profileCreateMasterPassword => 'Créer un mot de passe principal';

  @override
  String get profileMasterPasswordInfo =>
      'Ce mot de passe protégera vos souvenirs. Il ne peut pas être récupéré si vous l\'oubliez. Veuillez le conserver en lieu sûr.';

  @override
  String get profileMasterPasswordHint => 'Mot de passe principal';

  @override
  String get profileConfirmPasswordHint => 'Confirmer le mot de passe';

  @override
  String get profilePasswordMinLength =>
      'Le mot de passe doit comporter au moins 8 caractères';

  @override
  String get profilePasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get profileEnable => 'Activer';

  @override
  String get profileSectionHelp => 'AIDE';

  @override
  String get profileReplayTutorial => 'Rejouer le tutoriel';

  @override
  String get profileReplayTutorialConfirmTitle => 'Rejouer le tutoriel ?';

  @override
  String get profileReplayTutorialConfirmContent =>
      'Êtes-vous sûr de vouloir redémarrer le tutoriel ?';

  @override
  String get profileRestart => 'Redémarrer';

  @override
  String get profileSectionAccount => 'GESTION DU COMPTE';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileDeleteAccountConfirmTitle => 'Supprimer le compte ?';

  @override
  String get profileDelete => 'Supprimer';

  @override
  String get profileDeletingAccount => 'Suppression de votre compte...';

  @override
  String get profileErrorCouldNotFindProfile =>
      'Impossible de trouver le profil utilisateur.';

  @override
  String get memoryEditNewTitle => 'Nouveau souvenir';

  @override
  String get memoryEditEditTitle => 'Modifier le souvenir';

  @override
  String get memoryEditSave => 'Enregistrer';

  @override
  String get memoryEditTitleHint => 'Titre';

  @override
  String get memoryEditTitleValidator => 'Veuillez entrer un titre';

  @override
  String get memoryEditDescriptionHint => 'Description';

  @override
  String get memoryEditDateLabel => 'Date :';

  @override
  String get memoryEditSelectDateButton => 'Sélectionner la date';

  @override
  String get memoryEditAmbientSoundLabel => 'Son d\'ambiance :';

  @override
  String get memoryEditAmbientSoundDropdownHint =>
      'Sélectionnez un son d\'ambiance';

  @override
  String get memoryEditMusicAnchorLabel => 'Ancre musicale :';

  @override
  String get memoryEditAttachTrackButton => 'Joindre un morceau depuis Spotify';

  @override
  String get memoryEditPhotosLabel => 'Photos :';

  @override
  String get memoryEditNoPhotosSelected => 'Aucune photo sélectionnée';

  @override
  String get memoryEditAddPhotosButton => 'Ajouter des photos';

  @override
  String get memoryEditVideosLabel => 'Vidéos :';

  @override
  String get memoryEditNoVideosSelected => 'Aucune vidéo sélectionnée';

  @override
  String get memoryEditAddVideoButton => 'Ajouter une vidéo';

  @override
  String get memoryEditAudioNoteLabel => 'Note audio :';

  @override
  String get memoryEditAudioNoteSaved => 'Note audio enregistrée';

  @override
  String get memoryEditRecordButton => 'Enregistrer';

  @override
  String get memoryEditStopRecordingButton => 'Arrêter l\'enregistrement';

  @override
  String get memoryEditRecordingIndicator => 'Enregistrement...';

  @override
  String get memoryEditReflectionSectionTitle => 'Réflexion';

  @override
  String get memoryEditEncryptLabel => 'Chiffrer';

  @override
  String get memoryEditEncryptionInfoTooltip =>
      'Qu\'est-ce que le chiffrement ?';

  @override
  String get memoryEditImpactPrompt =>
      'Quel a été l\'impact de cet événement sur moi ?';

  @override
  String get memoryEditLessonPrompt => 'Quelle leçon ai-je apprise ?';

  @override
  String get memoryEditEmotionsLabel => 'Émotions :';

  @override
  String get emotionJoy => 'Joie';

  @override
  String get emotionNostalgia => 'Nostalgie';

  @override
  String get emotionPride => 'Fierté';

  @override
  String get emotionSadness => 'Tristesse';

  @override
  String get emotionGratitude => 'Gratitude';

  @override
  String get emotionLove => 'Amour';

  @override
  String get emotionFear => 'Peur';

  @override
  String get emotionAnger => 'Colère';

  @override
  String get memoryEditCbtHelperTitle => 'Aide à la réflexion';

  @override
  String get memoryEditCbtStep1Title =>
      'Quelle a été la première pensée ou croyance ?';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'par exemple, \'Je vais échouer\' ou \'J\'ai tout fait correctement\'.';

  @override
  String get memoryEditCbtStep2Title =>
      'Qu\'est-ce qui soutient cette pensée ?';

  @override
  String get memoryEditCbtStep2Subtitle =>
      'Quels faits ou événements prouvent que cette pensée est vraie ?';

  @override
  String get memoryEditCbtStep3Title => 'Quel est le point de vue opposé ?';

  @override
  String get memoryEditCbtStep3Subtitle =>
      'Quels faits ou événements pourraient réfuter ou contester la première pensée ?';

  @override
  String get memoryEditCbtStep4Title =>
      'Comment puis-je voir cela différemment ?';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'Sur la base de ce qui précède, formulez une nouvelle perspective plus équilibrée.';

  @override
  String get memoryEditActionPlanTitle => 'Plan d\'action';

  @override
  String get memoryEditActionPrompt => 'Quelle petite étape puis-je franchir ?';

  @override
  String get memoryEditReminderLabel => 'Rappel :';

  @override
  String get memoryEditReminderNotSet => 'Non défini';

  @override
  String get memoryEditSetReminderButton => 'Définir la date';

  @override
  String get memoryEditYourThoughtsHint => 'Vos pensées ici...';

  @override
  String get memoryEditDraftSavedMessage => 'Brouillon enregistré';

  @override
  String get memoryEditErrorRepoUnavailable => 'Erreur : Dépôt non disponible.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'Erreur lors de l\'enregistrement du souvenir : $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'Déverrouiller pour enregistrer';

  @override
  String get memoryEditUnlockDialogContent =>
      'Veuillez entrer votre mot de passe principal pour enregistrer ce souvenir chiffré.';

  @override
  String get memoryEditMasterPasswordHint => 'Mot de passe principal';

  @override
  String get memoryEditUnlockButton => 'Déverrouiller';

  @override
  String get memoryEditEncryptionInfoDialogTitle =>
      'Chiffrement de bout en bout';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'Lorsque vous chiffrez un souvenir, sa description et ses champs de réflexion sont brouillés à l\'aide d\'une clé dérivée de votre mot de passe principal.\n\nLes données sont stockées dans un format illisible dans le cloud et ne peuvent être déchiffrées que sur vos appareils avec votre mot de passe.\n\nIMPORTANT : Nous ne pouvons pas récupérer votre mot de passe principal. Si vous l\'oubliez, vos données chiffrées seront perdues à jamais.';

  @override
  String get memoryEditOkButton => 'OK';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'L\'autorisation pour $permissionName a été refusée. Veuillez l\'activer dans les paramètres.';
  }

  @override
  String get memoryEditSettingsButton => 'Paramètres';

  @override
  String get memoryEditNoInternetSnackbar =>
      'Une connexion Internet est requise pour rechercher de la musique.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'Intensité pour \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'Retour';

  @override
  String get memoryViewShareTooltip => 'Partager';

  @override
  String get memoryViewEditTooltip => 'Modifier';

  @override
  String get memoryViewDeleteTooltip => 'Supprimer';

  @override
  String get memoryViewTabMemory => 'Souvenir';

  @override
  String get memoryViewTabInTheWorld => 'Dans le monde';

  @override
  String get memoryViewEncryptedTitle => 'Souvenir chiffré';

  @override
  String get memoryViewReflectionTitle => 'Réflexion';

  @override
  String get memoryViewReflectionImpact => 'Impact';

  @override
  String get memoryViewReflectionLesson => 'Leçon apprise';

  @override
  String get memoryViewCbtStep1Title => 'Première pensée ou croyance';

  @override
  String get memoryViewCbtStep2Title => 'Preuves en faveur de cette pensée';

  @override
  String get memoryViewCbtStep3Title => 'Preuves contre cette pensée';

  @override
  String get memoryViewCbtStep4Title =>
      'Nouvelle perspective équilibrée (Recadrage)';

  @override
  String memoryViewActionReminder(String date) {
    return 'Rappel : $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'Marquer comme incomplet';

  @override
  String get memoryViewMarkCompleteTooltip => 'Marquer comme complet';

  @override
  String get memoryViewUnlockDialogTitle => 'Déverrouiller le souvenir';

  @override
  String get memoryViewUnlockDialogContent =>
      'Entrez votre mot de passe principal pour voir ce contenu.';

  @override
  String get memoryViewIncorrectPassword => 'Mot de passe incorrect.';

  @override
  String get memoryViewUnlockButton => 'Déverrouiller';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'Impossible de charger votre profil pour récupérer les données historiques.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'Impossible de charger les données historiques pour ce jour.';

  @override
  String get memoryViewNoHistoricalData =>
      'Aucune donnée historique disponible pour ce jour.';

  @override
  String get memoryViewErrorCouldNotLoadTrack =>
      'Impossible de charger le morceau';

  @override
  String get memoryViewTabNews => 'Actualités';

  @override
  String get memoryViewTabMusic => 'Musique';

  @override
  String get memoryViewNoDataForDay => 'Aucune donnée pour ce jour.';

  @override
  String get memoryViewNoNewsForDay =>
      'Aucune actualité historique pour ce jour.';

  @override
  String memoryViewNewsSource(String source) {
    return 'Source : $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'Confirmer la suppression';

  @override
  String get memoryViewConfirmDeleteContent =>
      'Cette action est irréversible. Pour continuer, maintenez le bouton de suppression enfoncé pendant 5 secondes.';

  @override
  String get memoryViewDeleteButton => 'SUPPRIMER';

  @override
  String get memoryViewErrorLoadingProfile =>
      'Nous n\'avons pas pu charger votre profil. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get memoryViewErrorLocalDb =>
      'Erreur : Impossible d\'accéder à la base de données locale.';

  @override
  String get memoryViewMemoryDeleted => 'Souvenir supprimé';

  @override
  String get memoryViewSharingNotImplemented =>
      'La fonctionnalité de partage n\'est pas encore implémentée.';

  @override
  String get memoryViewActionCompleted => 'Action marquée comme terminée !';

  @override
  String get memoryViewActionIncomplete => 'Action marquée comme incomplète.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'Erreur lors de la mise à jour de l\'action : $error';
  }

  @override
  String get memoryViewContentEncrypted => 'Le contenu est chiffré';

  @override
  String get memoryViewReflectionEncrypted => 'La réflexion est chiffrée';

  @override
  String get memoryViewMediaEncrypted => 'Les médias sont chiffrés';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'Son d\'ambiance : $sound';
  }

  @override
  String get memoryViewAudioNote => 'Note audio';

  @override
  String get spotifySearchTitle => 'Rechercher un morceau Spotify';

  @override
  String get spotifySearchHint => 'Titre de la chanson ou artiste';

  @override
  String get documentErrorLoading => 'Impossible de charger le document.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'Souvenirs : $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'Période : $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status ($jobs restants)';
  }

  @override
  String get lifelineCalculating => 'Calcul en cours...';

  @override
  String lifelineScaleValue(int scale) {
    return 'Échelle : $scale%';
  }

  @override
  String lifelineFpsValue(String fps) {
    return 'FPS : $fps';
  }

  @override
  String lifelineFramePaintValue(int ms) {
    return 'Rendu de l\'image : $ms ms';
  }

  @override
  String get lifelineShowFullTimelineTooltip => 'Afficher la timeline complète';

  @override
  String get lifelineVisualSettingsTooltip => 'Paramètres visuels';

  @override
  String get lifelineMenuProfile => 'Profil';

  @override
  String get lifelineMenuDebugOn => 'Débogage activé';

  @override
  String get lifelineMenuDebugOff => 'Débogage désactivé';

  @override
  String get lifelineMenuSignOut => 'Se déconnecter';

  @override
  String get lifelineSearchHint => 'Rechercher...';

  @override
  String get lifelineMemoriesListTitle => 'Souvenirs';

  @override
  String get lifelineVisualSettingsDialogTitle => 'Paramètres visuels';

  @override
  String get lifelineVisualSettingsSpeed => 'Vitesse';

  @override
  String get lifelineVisualSettingsAmplitude => 'Amplitude';

  @override
  String get lifelineVisualSettingsYearLine =>
      'Position de la ligne de l\'année';

  @override
  String get lifelineVisualSettingsBranchDensity => 'Densité des branches';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'Intensité des branches';

  @override
  String get lifelineVisualSettingsAnimate => 'Animer';

  @override
  String get lifelineVisualSettingsDoneButton => 'Terminé';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'Votre parcours personnel, visualisé. Faisons un petit tour pour voir comment vous pouvez commencer à capturer vos moments.';

  @override
  String get onboardingSkipButton => 'Passer pour l\'instant';

  @override
  String get onboardingBeginTourButton => 'Commencer la visite';

  @override
  String get onboardingGesturesTitle => 'Naviguez dans votre timeline';

  @override
  String get onboardingGestureSwipe => 'Balayer';

  @override
  String get onboardingGesturePinch => 'Pincer pour zoomer';

  @override
  String get onboardingGestureDoubleTap => 'Double tape';

  @override
  String get onboardingGesturesSubtitle =>
      'Votre Lifeline grandira avec vous. Pincez pour zoomer, double tapez pour zoomer rapidement. Balayez vers la gauche et la droite pour naviguer dans le temps.';

  @override
  String get onboardingContinueButton => 'Continuer';

  @override
  String get onboardingFinalTitle => 'Vous êtes prêt !';

  @override
  String get onboardingFinalSubtitle =>
      'Votre voyage commence maintenant. Commencez à capturer les moments qui comptent.';

  @override
  String get onboardingStartJourneyButton => 'Commencer mon voyage';

  @override
  String get onboardingSkipTourButton => 'Passer la visite';

  @override
  String get onboardingLifelineIntroText =>
      'Ceci est votre Lifeline. Chaque souvenir que vous ajoutez créera un nœud unique sur ce chemin, formant une belle carte du voyage de votre vie.';

  @override
  String get onboardingLifelineIntroButton => 'Suivant';

  @override
  String get onboardingAddMemoryText =>
      'Appuyez ici pour ajouter un nouveau souvenir. Un nœud apparaîtra sur votre Lifeline pour chaque moment que vous capturez.';

  @override
  String get onboardingNavGesturesText =>
      'Super ! Maintenant, apprenons à naviguer dans votre timeline.';

  @override
  String get onboardingControlsPanelText =>
      'Utilisez ces commandes pour gérer votre vue. Vous pouvez recentrer la timeline, ajuster les effets visuels et accéder à votre profil.';

  @override
  String get onboardingControlsPanelButton => 'Compris';

  @override
  String get onboardingStatsCardText =>
      'Cette carte affiche un résumé de vos souvenirs. Appuyez dessus pour ouvrir une liste complète et consultable de tout votre parcours.';

  @override
  String get onboardingStatsCardButton => 'Presque terminé !';

  @override
  String get audioPlayerPreviousTooltip => 'Piste précédente';

  @override
  String get audioPlayerPlayTooltip => 'Lire';

  @override
  String get audioPlayerPauseTooltip => 'Pause';

  @override
  String get audioPlayerNextTooltip => 'Piste suivante';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'Étape $step : ';
  }

  @override
  String get premiumBannerTitle => 'Débloquer Lifeline Premium';

  @override
  String get premiumBannerSubtitle =>
      'Médias illimités, réflexion avancée, contexte historique, et plus encore !';

  @override
  String get premiumDialogTitle => 'Passer à Premium';

  @override
  String premiumDialogContent(String feature) {
    return 'Débloquez la possibilité de $feature et accédez à toutes les fonctionnalités premium.';
  }

  @override
  String get premiumDialogGoPremium => 'Passer à Premium';

  @override
  String get premiumFeaturePhotos => 'ajouter plus de photos';

  @override
  String get premiumFeatureVideos => 'ajouter une vidéo';

  @override
  String get premiumFeatureAudio => 'ajouter une note audio';

  @override
  String get premiumFeatureSpotify => 'ajouter un morceau Spotify';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'Libérez tout votre potentiel';

  @override
  String get premiumScreenHeaderSubtitle =>
      'Dépassez les limites avec Lifeline Premium et tirez le meilleur parti de votre voyage de découverte de soi.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'Photos et vidéos illimitées';

  @override
  String get premiumFeatureUnlimitedAudio => 'Notes audio illimitées';

  @override
  String get premiumFeatureUnlimitedSpotify => 'Morceaux Spotify illimités';

  @override
  String get premiumFeatureAdvancedCbt => 'Assistant de réflexion avancé';

  @override
  String get premiumFeatureActionReminders => 'Rappels de plan d\'action';

  @override
  String get premiumFeatureHistoricalContext =>
      'Contexte historique \'Dans le monde\'';

  @override
  String get premiumFeatureSoundLibrary =>
      'Bibliothèque de sons d\'ambiance complète';

  @override
  String get premiumScreenYearlyPopular =>
      'Le plus populaire & le meilleur rapport qualité-prix';

  @override
  String get premiumScreenProcessingPurchase => 'Traitement de l\'achat...';

  @override
  String get premiumScreenRestore => 'Restaurer les achats';

  @override
  String get premiumScreenTerms => 'Conditions d\'utilisation';

  @override
  String get premiumScreenPrivacy => 'Politique de confidentialité';

  @override
  String get premiumStatusTitle => 'Membre Premium';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String get onboardingEncryptionTitle => 'Vos souvenirs, sécurisés';

  @override
  String get onboardingEncryptionSubtitle =>
      'Lifeline propose un chiffrement de bout en bout. Cela signifie que vous seul pouvez lire vos souvenirs privés. Configurons votre mot de passe principal pour les protéger.';

  @override
  String get onboardingEncryptionSetupButton => 'Configurer maintenant';

  @override
  String get onboardingEncryptionLaterButton => 'Peut-être plus tard';

  @override
  String get onboardingEncryptionActiveTitle => 'Le chiffrement est actif';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'Vos souvenirs sont déjà protégés. Vous pouvez gérer votre mot de passe principal dans les paramètres du profil.';

  @override
  String get onboardingEncryptionContinueButton => 'Continuer';

  @override
  String get memoryEditEncryptMemory => 'Chiffrer ce souvenir';

  @override
  String get memoryEditSetupEncryptionTitle => 'Activer le chiffrement ?';

  @override
  String get memoryEditSetupEncryptionContent =>
      'Pour protéger ce souvenir, vous devez d\'abord créer un mot de passe principal. Ce sera votre unique clé pour toutes les entrées chiffrées.';

  @override
  String get memoryEditCreatePasswordButton =>
      'Créer un mot de passe principal';

  @override
  String get memoryViewExportPdf => 'Partager en PDF';

  @override
  String get shareActionTitle => 'Ajouter à Lifeline';

  @override
  String get shareActionSubtitle =>
      'Que souhaitez-vous faire avec ces fichiers ?';

  @override
  String get shareCreateNewMemory => 'Créer un nouveau souvenir';

  @override
  String get shareAddToExisting => 'Ajouter à un souvenir existant';

  @override
  String get selectMemoryTitle => 'Sélectionner un souvenir';

  @override
  String get selectMemorySearchHint => 'Rechercher par titre ou contenu...';

  @override
  String get selectMemoryEmpty => 'Aucun souvenir trouvé';

  @override
  String get memoryUpdatedSuccess => 'Souvenir mis à jour avec succès !';

  @override
  String unlockFailedAttemptsRemaining(int count) {
    return 'Mot de passe incorrect. Il reste $count tentatives.';
  }

  @override
  String unlockTooManyAttempts(int seconds) {
    return 'Trop de tentatives. Réessayez dans $seconds secondes.';
  }

  @override
  String get unlocking => 'Déverrouillage...';

  @override
  String get exportingPdf => 'Préparation du PDF...';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get profileEnableQuickUnlock => 'Activer le déverrouillage rapide';

  @override
  String get profileQuickUnlockSubtitle =>
      'Utilisez votre empreinte digitale, votre visage ou le code PIN de l’appareil pour déverrouiller.';

  @override
  String get profileRequireBiometricsForMemoryTitle =>
      'Exiger la biométrie pour chaque souvenir';

  @override
  String get profileRequireBiometricsForMemorySubtitle =>
      'Si activé, une authentification est requise pour ouvrir ou modifier des souvenirs chiffrés individuellement, même lorsque l’application est déverrouillée.';

  @override
  String get quickUnlockPrompt =>
      'Authentifiez-vous pour déverrouiller Lifeline';

  @override
  String get quickUnlockEnablePrompt =>
      'Authentifiez-vous pour activer le déverrouillage rapide';

  @override
  String get masterPasswordRequiredTitle => 'Mot de passe maître requis';

  @override
  String get masterPasswordRequiredContent =>
      'Veuillez saisir votre mot de passe maître pour activer cette fonctionnalité.';

  @override
  String get unlockScreenTitle => 'Déverrouiller Lifeline';

  @override
  String get unlockWithBiometrics => 'Déverrouiller avec la biométrie';

  @override
  String get unlockEnterMasterPassword => 'Saisir le mot de passe maître';

  @override
  String get unlockForgotPassword => 'Mot de passe oublié ?';

  @override
  String get unlockResetEncryptionTitle => 'Réinitialiser le chiffrement';

  @override
  String get unlockResetEncryptionWarning =>
      '⚠️ ATTENTION : Cette action est irréversible !';

  @override
  String get unlockResetEncryptionDescription =>
      'Si vous avez oublié votre mot de passe maître, vous pouvez réinitialiser le chiffrement. Cependant, cela supprimera définitivement tous les souvenirs chiffrés.';

  @override
  String get unlockResetEncryptionConsequences => 'Ce qui sera supprimé :';

  @override
  String get unlockResetEncryptionConsequence1 =>
      'Tous les souvenirs chiffrés (locaux et dans le cloud)';

  @override
  String get unlockResetEncryptionConsequence2 =>
      'Le chiffrement sera désactivé';

  @override
  String get unlockResetEncryptionConsequence3 =>
      'Vous pourrez continuer à utiliser l\'application sans chiffrement';

  @override
  String get unlockResetEncryptionConfirm => 'Supprimer les souvenirs chiffrés';

  @override
  String get unlockResetEncryptionSuccess =>
      'Le chiffrement a été réinitialisé. Vous pouvez maintenant utiliser l\'application sans mot de passe maître.';

  @override
  String get unlockResetEncryptionError =>
      'Échec de la réinitialisation du chiffrement';

  @override
  String get draftBannerSingleTitle => 'Vous avez un souvenir inachevé';

  @override
  String draftBannerSingleSubtitle(String timeAgo) {
    return 'Dernière modification : $timeAgo';
  }

  @override
  String draftBannerMultipleTitle(int count) {
    return 'Vous avez $count souvenirs inachevés';
  }

  @override
  String get draftBannerMultipleSubtitle => 'Appuyez pour tout afficher';

  @override
  String get draftBannerResume => 'Reprendre';

  @override
  String get draftBannerDelete => 'Supprimer';

  @override
  String get draftResumedSuccess => 'Brouillon repris avec succès';

  @override
  String get draftDeleteDialogTitle => 'Supprimer le brouillon ?';

  @override
  String get draftDeleteDialogMessage =>
      'Ce brouillon sera supprimé définitivement. Cette action est irréversible.';

  @override
  String get draftDeleteCancel => 'Annuler';

  @override
  String get draftDeleteConfirm => 'Supprimer';

  @override
  String get draftDeletedSuccess => 'Brouillon supprimé avec succès';

  @override
  String get draftDeletedError => 'Échec de la suppression du brouillon';

  @override
  String draftListDialogTitle(int count) {
    return 'Vous avez $count brouillons';
  }

  @override
  String get draftListItemNoTitle => 'Souvenir sans titre';

  @override
  String get draftListItemNoContent => 'Aucun contenu';

  @override
  String draftListItemLastModified(String timeAgo) {
    return 'Dernière modification : $timeAgo';
  }

  @override
  String get timeAgoJustNow => 'à l\'instant';

  @override
  String timeAgoMinutes(int count) {
    return 'il y a $count minutes';
  }

  @override
  String timeAgoHours(int count) {
    return 'il y a $count heures';
  }

  @override
  String timeAgoDays(int count) {
    return 'il y a $count jours';
  }

  @override
  String timeAgoWeeks(int count) {
    return 'il y a $count semaines';
  }

  @override
  String get fileSizeTooLargeImage =>
      'Le fichier image est trop volumineux. La taille maximale est de 10 Mo.';

  @override
  String get fileSizeTooLargeVideo =>
      'Le fichier vidéo est trop volumineux. La taille maximale est de 100 Mo.';

  @override
  String get fileSizeTooLargeAudio =>
      'Le fichier audio est trop volumineux. La taille maximale est de 25 Mo.';

  @override
  String get biometricUnlockFailedMessage =>
      'Les clés de sécurité doivent être recréées après la réinstallation de l\'application. Veuillez saisir votre mot de passe principal pour continuer.';

  @override
  String lifelineInsightStreakDays(int count) {
    return '🔥 Série de $count jours';
  }

  @override
  String lifelineInsightMemoriesThisMonth(int count) {
    return '📝 $count souvenirs ce mois-ci';
  }

  @override
  String lifelineInsightMemoriesThisWeek(int count) {
    return '✨ $count nouveaux cette semaine';
  }

  @override
  String lifelineInsightReflectionsCount(int count) {
    return '⭐ $count réflexions';
  }

  @override
  String lifelineInsightPhotosCount(int count) {
    return '📸 $count photos';
  }

  @override
  String lifelineInsightAudioCount(int count) {
    return '🎵 $count notes audio';
  }

  @override
  String lifelineInsightSpanningYears(int years) {
    return '📅 S\'étend sur $years années';
  }

  @override
  String lifelineInsightTotalMemories(int count) {
    return '📖 $count moments capturés';
  }

  @override
  String get lifelineInsightPositiveVibes =>
      '😊 Ambiance principalement positive';

  @override
  String get lifelineInsightGrowthJourney => '🌱 Parcours de croissance';

  @override
  String get lifelineInsightBalancedEmotions => '⚖️ Émotions équilibrées';

  @override
  String get lifelineInsightStartJourney => '✍️ Commencez votre voyage';

  @override
  String get lifelineInsightBuildStreak => '💪 Construisez votre série';

  @override
  String get purchaseSuccessMessage =>
      'Achat réussi ! Bienvenue dans Premium !';

  @override
  String get graphicsQualityTitle => 'Qualité graphique';

  @override
  String get graphicsQualityAuto => 'Auto';

  @override
  String get graphicsQualityLow => 'Faible';

  @override
  String get graphicsQualityMedium => 'Moyenne';

  @override
  String get graphicsQualityHigh => 'Élevée';

  @override
  String get graphicsQualityAutoSubtitle =>
      'Détecter automatiquement les performances de l\"appareil';

  @override
  String get graphicsQualityLowSubtitle =>
      'Meilleure autonomie, effets minimaux';

  @override
  String get graphicsQualityMediumSubtitle =>
      'Performances et visuels équilibrés';

  @override
  String get graphicsQualityHighSubtitle =>
      'Meilleurs visuels, plus de consommation de batterie';

  @override
  String graphicsQualityAutoDetected(String performance) {
    return 'Auto ($performance)';
  }
}
