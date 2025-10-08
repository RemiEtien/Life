// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get register => 'Registrar';

  @override
  String get createAccount => 'Criar uma nova conta';

  @override
  String get alreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get orSignInWith => 'Ou entre com';

  @override
  String get passwordTooShort => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get invalidEmail => 'Por favor, insira um e-mail válido';

  @override
  String get consentWelcomeTitle => 'Bem-vindo ao Lifeline';

  @override
  String get consentWelcomeSubtitle =>
      'Antes de começar, por favor, revise e concorde com nossos termos.';

  @override
  String get consentIAgreeTo => 'Eu li e concordo com os ';

  @override
  String get consentTermsOfService => 'Termos de Serviço';

  @override
  String get consentAnd => ' e a ';

  @override
  String get consentPrivacyPolicy => 'Política de Privacidade';

  @override
  String get consentContinue => 'Continuar';

  @override
  String consentErrorSaving(String error) {
    return 'Erro ao salvar as configurações: $error';
  }

  @override
  String get splashMessageInitializing => 'Inicializando...';

  @override
  String get splashMessageCheckingSettings => 'Verificando configurações...';

  @override
  String get splashMessageAuthenticating => 'Autenticando...';

  @override
  String get splashMessageSyncing => 'Sincronizando sua linha do tempo...';

  @override
  String get authGateLoadingMemories => 'Carregando memórias...';

  @override
  String get authGateAuthenticating => 'Autenticando...';

  @override
  String get authGateSomethingWentWrong => 'Algo deu errado';

  @override
  String get authGateCouldNotLoad =>
      'Não foi possível carregar seus dados. Verifique sua conexão e tente novamente.';

  @override
  String get authGateTryAgain => 'Tentar Novamente';

  @override
  String get authGateEmptyState =>
      'Sua Lifeline está pronta.\nToque no botão + para adicionar sua primeira memória.';

  @override
  String get authGateUnsavedDraftTitle => 'Memória não salva';

  @override
  String get authGateUnsavedDraftContent =>
      'Você tem um rascunho de memória não salvo. Deseja continuar editando?';

  @override
  String get authGateDiscard => 'Descartar';

  @override
  String get authGateContinueEditing => 'Continuar Editando';

  @override
  String get verifyEmailTitle => 'Verificação de E-mail';

  @override
  String get verifyEmailSentTo => 'Um e-mail de verificação foi enviado para:';

  @override
  String get verifyEmailInstructions =>
      'Por favor, clique no link do e-mail para completar o seu registo.';

  @override
  String get verifyEmailResendButton => 'Reenviar E-mail';

  @override
  String get verifyEmailCancelButton => 'Cancelar';

  @override
  String get profileTitle => 'Perfil e Configurações';

  @override
  String get profileSectionProfile => 'PERFIL';

  @override
  String get profileChangeNameTitle => 'Alterar Nome';

  @override
  String get profileEnterYourName => 'Digite seu nome';

  @override
  String get profileSave => 'Salvar';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileName => 'Nome';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileCountry => 'País';

  @override
  String get profileCountryNotSelected => 'Não selecionado';

  @override
  String get profileLanguage => 'Idioma do Conteúdo';

  @override
  String get profileLanguageDefault => 'Inglês (Padrão)';

  @override
  String get profileSelectLanguage => 'Selecionar Idioma';

  @override
  String get profileSectionSettings => 'CONFIGURAÇÕES';

  @override
  String get profileTheme => 'Tema';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Escuro';

  @override
  String get profileReauthTitle => 'Reautenticação Necessária';

  @override
  String get profileReauthContent =>
      'Esta é uma operação sensível. Por favor, faça login novamente antes de prosseguir.';

  @override
  String get profileReauthButton => 'Entrar e Excluir';

  @override
  String get profileReauthPasswordDialogTitle => 'Confirmar Ação';

  @override
  String get profileReauthPasswordDialogContent =>
      'Para excluir sua conta, digite sua senha atual.';

  @override
  String get profilePasswordCannotBeEmpty => 'A senha não pode estar vazia';

  @override
  String get profileChangePasswordSuccess =>
      'Senha mestre alterada com sucesso!';

  @override
  String get profileChangePasswordErrorIncorrect =>
      'A senha mestra atual que você inseriu está incorreta.';

  @override
  String get profileOldPasswordHint => 'Senha Antiga';

  @override
  String get profileNewPasswordHint => 'Nova Senha';

  @override
  String get profileDeleteAccountConfirmContent =>
      'Esta ação é irreversível. Toda a sua conta, incluindo todas as memórias e configurações, será excluída permanentemente. Para prosseguir, pressione e segure o botão de exclusão por 5 segundos.';

  @override
  String get profileChangePasswordCurrentPasswordHint => 'Senha Mestra Atual';

  @override
  String get profileChangePasswordNewPasswordHint => 'Nova Senha Mestra';

  @override
  String get profileChangePasswordInfo =>
      'Por favor, insira sua senha mestra atual para definir uma nova. Isso irá criptografar novamente sua chave secreta.';

  @override
  String get profileGraphics => 'Qualidade Gráfica';

  @override
  String get profileGraphicsAuto => 'Automático';

  @override
  String get profileGraphicsLow => 'Baixa';

  @override
  String get profileGraphicsMedium => 'Média';

  @override
  String get profileGraphicsHigh => 'Alta';

  @override
  String get profileReminders => 'Lembretes de Reflexão';

  @override
  String get profileRemindersSubtitle =>
      'Receba notificações para seus planos de ação';

  @override
  String get profileSectionSecurity => 'SEGURANÇA';

  @override
  String get profileChangePassword => 'Alterar Senha Mestra';

  @override
  String get profileEncryptionActive =>
      'A criptografia de ponta a ponta está ativa';

  @override
  String get profileEnableEncryption => 'Ativar Criptografia de Ponta a Ponta';

  @override
  String get profileEnableEncryptionSubtitle =>
      'Proteja suas memórias sensíveis com uma senha mestra.';

  @override
  String get profileCreateMasterPassword => 'Criar Senha Mestra';

  @override
  String get profileMasterPasswordInfo =>
      'Esta senha protegerá suas memórias. Ela não pode ser recuperada se você a esquecer. Por favor, guarde-a em um local seguro.';

  @override
  String get profileMasterPasswordHint => 'Senha Mestra';

  @override
  String get profileConfirmPasswordHint => 'Confirmar Senha';

  @override
  String get profilePasswordMinLength =>
      'A senha deve ter pelo menos 8 caracteres';

  @override
  String get profilePasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get profileEnable => 'Ativar';

  @override
  String get profileSectionHelp => 'AJUDA';

  @override
  String get profileReplayTutorial => 'Repetir Tutorial';

  @override
  String get profileReplayTutorialConfirmTitle => 'Repetir Tutorial?';

  @override
  String get profileReplayTutorialConfirmContent =>
      'Tem certeza de que deseja reiniciar o tutorial?';

  @override
  String get profileRestart => 'Reiniciar';

  @override
  String get profileSectionAccount => 'GERENCIAMENTO DA CONTA';

  @override
  String get profileSignOut => 'Sair';

  @override
  String get profileDeleteAccount => 'Excluir Conta';

  @override
  String get profileDeleteAccountConfirmTitle => 'Excluir Conta?';

  @override
  String get profileDelete => 'Excluir';

  @override
  String get profileDeletingAccount => 'Excluindo sua conta...';

  @override
  String get profileErrorCouldNotFindProfile =>
      'Não foi possível encontrar o perfil do usuário.';

  @override
  String get memoryEditNewTitle => 'Nova Memória';

  @override
  String get memoryEditEditTitle => 'Editar Memória';

  @override
  String get memoryEditSave => 'Salvar';

  @override
  String get memoryEditTitleHint => 'Título';

  @override
  String get memoryEditTitleValidator => 'Por favor, insira um título';

  @override
  String get memoryEditDescriptionHint => 'Descrição';

  @override
  String get memoryEditDateLabel => 'Data:';

  @override
  String get memoryEditSelectDateButton => 'Selecionar Data';

  @override
  String get memoryEditAmbientSoundLabel => 'Som Ambiente:';

  @override
  String get memoryEditAmbientSoundDropdownHint => 'Selecione um som ambiente';

  @override
  String get memoryEditMusicAnchorLabel => 'Âncora Musical:';

  @override
  String get memoryEditAttachTrackButton => 'Anexar faixa do Spotify';

  @override
  String get memoryEditPhotosLabel => 'Fotos:';

  @override
  String get memoryEditNoPhotosSelected => 'Nenhuma foto selecionada';

  @override
  String get memoryEditAddPhotosButton => 'Adicionar Fotos';

  @override
  String get memoryEditVideosLabel => 'Vídeos:';

  @override
  String get memoryEditNoVideosSelected => 'Nenhum vídeo selecionado';

  @override
  String get memoryEditAddVideoButton => 'Adicionar Vídeo';

  @override
  String get memoryEditAudioNoteLabel => 'Nota de Áudio:';

  @override
  String get memoryEditAudioNoteSaved => 'Nota de áudio salva';

  @override
  String get memoryEditRecordButton => 'Gravar';

  @override
  String get memoryEditStopRecordingButton => 'Parar Gravação';

  @override
  String get memoryEditRecordingIndicator => 'Gravando...';

  @override
  String get memoryEditReflectionSectionTitle => 'Reflexão';

  @override
  String get memoryEditEncryptLabel => 'Criptografar';

  @override
  String get memoryEditEncryptionInfoTooltip => 'O que é criptografia?';

  @override
  String get memoryEditImpactPrompt => 'Como este evento me impactou?';

  @override
  String get memoryEditLessonPrompt => 'Que lição eu aprendi?';

  @override
  String get memoryEditEmotionsLabel => 'Emoções:';

  @override
  String get emotionJoy => 'Alegria';

  @override
  String get emotionNostalgia => 'Nostalgia';

  @override
  String get emotionPride => 'Orgulho';

  @override
  String get emotionSadness => 'Tristeza';

  @override
  String get emotionGratitude => 'Gratidão';

  @override
  String get emotionLove => 'Amor';

  @override
  String get emotionFear => 'Medo';

  @override
  String get emotionAnger => 'Raiva';

  @override
  String get memoryEditCbtHelperTitle => 'Assistente de Reflexão';

  @override
  String get memoryEditCbtStep1Title =>
      'Qual foi o primeiro pensamento ou crença?';

  @override
  String get memoryEditCbtStep1Subtitle =>
      'ex: \'Vou falhar\' ou \'Fiz tudo certo\'.';

  @override
  String get memoryEditCbtStep2Title => 'O que apoia esse pensamento?';

  @override
  String get memoryEditCbtStep2Subtitle =>
      'Quais fatos ou eventos provam que esse pensamento é verdadeiro?';

  @override
  String get memoryEditCbtStep3Title => 'Qual é a visão do outro lado?';

  @override
  String get memoryEditCbtStep3Subtitle =>
      'Quais fatos ou eventos podem refutar ou desafiar o primeiro pensamento?';

  @override
  String get memoryEditCbtStep4Title =>
      'Como posso ver isso de forma diferente?';

  @override
  String get memoryEditCbtStep4Subtitle =>
      'Com base no exposto, formule uma perspectiva nova e mais equilibrada.';

  @override
  String get memoryEditActionPlanTitle => 'Plano de Ação';

  @override
  String get memoryEditActionPrompt => 'Qual é um pequeno passo que posso dar?';

  @override
  String get memoryEditReminderLabel => 'Lembrete:';

  @override
  String get memoryEditReminderNotSet => 'Não definido';

  @override
  String get memoryEditSetReminderButton => 'Definir Data';

  @override
  String get memoryEditYourThoughtsHint => 'Seus pensamentos aqui...';

  @override
  String get memoryEditDraftSavedMessage => 'Rascunho salvo';

  @override
  String get memoryEditErrorRepoUnavailable =>
      'Erro: Repositório não disponível.';

  @override
  String memoryEditErrorSaving(String error) {
    return 'Erro ao salvar memória: $error';
  }

  @override
  String get memoryEditUnlockDialogTitle => 'Desbloquear para Salvar';

  @override
  String get memoryEditUnlockDialogContent =>
      'Por favor, insira sua Senha Mestra para salvar esta memória criptografada.';

  @override
  String get memoryEditMasterPasswordHint => 'Senha Mestra';

  @override
  String get memoryEditUnlockButton => 'Desbloquear';

  @override
  String get memoryEditEncryptionInfoDialogTitle =>
      'Criptografia de Ponta a Ponta';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      'Quando você criptografa uma memória, seus campos de descrição e reflexão são embaralhados usando uma chave derivada de sua Senha Mestra.\n\nOs dados são armazenados em um formato ilegível na nuvem e só podem ser descriptografados em seus dispositivos com sua senha.\n\nIMPORTANTE: Não podemos recuperar sua Senha Mestra. Se você a esquecer, seus dados criptografados serão perdidos para sempre.';

  @override
  String get memoryEditOkButton => 'OK';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return 'A permissão para $permissionName foi negada. Por favor, ative-a nas configurações.';
  }

  @override
  String get memoryEditSettingsButton => 'Configurações';

  @override
  String get memoryEditNoInternetSnackbar =>
      'É necessária conexão com a internet para pesquisar músicas.';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return 'Intensidade para \'$emotion\'';
  }

  @override
  String get memoryViewBackTooltip => 'Voltar';

  @override
  String get memoryViewShareTooltip => 'Compartilhar';

  @override
  String get memoryViewEditTooltip => 'Editar';

  @override
  String get memoryViewDeleteTooltip => 'Excluir';

  @override
  String get memoryViewTabMemory => 'Memória';

  @override
  String get memoryViewTabInTheWorld => 'No Mundo';

  @override
  String get memoryViewEncryptedTitle => 'Memória Criptografada';

  @override
  String get memoryViewReflectionTitle => 'Reflexão';

  @override
  String get memoryViewReflectionImpact => 'Impacto';

  @override
  String get memoryViewReflectionLesson => 'Lição Aprendida';

  @override
  String get memoryViewCbtStep1Title => 'Primeiro Pensamento ou Crença';

  @override
  String get memoryViewCbtStep2Title => 'Evidências para Este Pensamento';

  @override
  String get memoryViewCbtStep3Title => 'Evidências Contra Este Pensamento';

  @override
  String get memoryViewCbtStep4Title =>
      'Perspectiva Nova e Equilibrada (Reenquadramento)';

  @override
  String memoryViewActionReminder(String date) {
    return 'Lembrete: $date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => 'Marcar como incompleto';

  @override
  String get memoryViewMarkCompleteTooltip => 'Marcar como completo';

  @override
  String get memoryViewUnlockDialogTitle => 'Desbloquear Memória';

  @override
  String get memoryViewUnlockDialogContent =>
      'Digite sua Senha Mestra para ver este conteúdo.';

  @override
  String get memoryViewIncorrectPassword => 'Senha incorreta.';

  @override
  String get memoryViewUnlockButton => 'Desbloquear';

  @override
  String get memoryViewErrorCouldNotLoadProfile =>
      'Não foi possível carregar seu perfil para buscar dados históricos.';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData =>
      'Não foi possível carregar dados históricos para este dia.';

  @override
  String get memoryViewNoHistoricalData =>
      'Não há dados históricos disponíveis para este dia.';

  @override
  String get memoryViewErrorCouldNotLoadTrack =>
      'Não foi possível carregar a faixa';

  @override
  String get memoryViewTabNews => 'Notícias';

  @override
  String get memoryViewTabMusic => 'Música';

  @override
  String get memoryViewNoDataForDay => 'Sem dados para este dia.';

  @override
  String get memoryViewNoNewsForDay => 'Sem notícias históricas para este dia.';

  @override
  String memoryViewNewsSource(String source) {
    return 'Fonte: $source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => 'Confirmar Exclusão';

  @override
  String get memoryViewConfirmDeleteContent =>
      'Esta ação é irreversível. Para prosseguir, pressione e segure o botão de exclusão por 5 segundos.';

  @override
  String get memoryViewDeleteButton => 'EXCLUIR';

  @override
  String get memoryViewErrorLoadingProfile =>
      'Não foi possível carregar seu perfil. Verifique sua conexão e tente novamente.';

  @override
  String get memoryViewErrorLocalDb =>
      'Erro: Não foi possível acessar o banco de dados local.';

  @override
  String get memoryViewMemoryDeleted => 'Memória excluída';

  @override
  String get memoryViewSharingNotImplemented =>
      'A funcionalidade de compartilhamento ainda não foi implementada.';

  @override
  String get memoryViewActionCompleted => 'Ação marcada como concluída!';

  @override
  String get memoryViewActionIncomplete => 'Ação marcada como incompleta.';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return 'Erro ao atualizar ação: $error';
  }

  @override
  String get memoryViewContentEncrypted => 'Conteúdo Criptografado';

  @override
  String get memoryViewReflectionEncrypted => 'Reflexão Criptografada';

  @override
  String get memoryViewMediaEncrypted => 'Mídia Criptografada';

  @override
  String memoryViewAmbientSound(String sound) {
    return 'Som Ambiente: $sound';
  }

  @override
  String get memoryViewAudioNote => 'Nota de Áudio';

  @override
  String get spotifySearchTitle => 'Pesquisar Faixa no Spotify';

  @override
  String get spotifySearchHint => 'Título da música ou artista';

  @override
  String get documentErrorLoading => 'Não foi possível carregar o documento.';

  @override
  String lifelineMemoriesCount(int count) {
    return 'Memórias: $count';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return 'Período: $startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status (faltam $jobs)';
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
    return 'Pintura do Quadro: $ms ms';
  }

  @override
  String get lifelineShowFullTimelineTooltip =>
      'Mostrar linha do tempo completa';

  @override
  String get lifelineVisualSettingsTooltip => 'Configurações visuais';

  @override
  String get lifelineMenuProfile => 'Perfil';

  @override
  String get lifelineMenuDebugOn => 'Depuração Ativada';

  @override
  String get lifelineMenuDebugOff => 'Depuração Desativada';

  @override
  String get lifelineMenuSignOut => 'Sair';

  @override
  String get lifelineSearchHint => 'Pesquisar...';

  @override
  String get lifelineMemoriesListTitle => 'Memórias';

  @override
  String get lifelineVisualSettingsDialogTitle => 'Configurações Visuais';

  @override
  String get lifelineVisualSettingsSpeed => 'Velocidade';

  @override
  String get lifelineVisualSettingsAmplitude => 'Amplitude';

  @override
  String get lifelineVisualSettingsYearLine => 'Posição da Linha do Ano';

  @override
  String get lifelineVisualSettingsBranchDensity => 'Densidade de Ramos';

  @override
  String get lifelineVisualSettingsBranchIntensity => 'Intensidade de Ramos';

  @override
  String get lifelineVisualSettingsAnimate => 'Animar';

  @override
  String get lifelineVisualSettingsDoneButton => 'Concluído';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      'Sua jornada pessoal, visualizada. Vamos fazer um tour rápido para ver como você pode começar a capturar seus momentos.';

  @override
  String get onboardingSkipButton => 'Pular por enquanto';

  @override
  String get onboardingBeginTourButton => 'Começar Tour';

  @override
  String get onboardingGesturesTitle => 'Navegue em Sua Linha do Tempo';

  @override
  String get onboardingGestureSwipe => 'Deslizar';

  @override
  String get onboardingGesturePinch => 'Pinçar para Zoom';

  @override
  String get onboardingGestureDoubleTap => 'Toque duplo';

  @override
  String get onboardingGesturesSubtitle =>
      'Sua Lifeline crescerá com você. Pince para zoom, toque duas vezes para aproximar rapidamente. Deslize para a esquerda e para a direita para navegar no tempo.';

  @override
  String get onboardingContinueButton => 'Continuar';

  @override
  String get onboardingFinalTitle => 'Tudo Pronto!';

  @override
  String get onboardingFinalSubtitle =>
      'Sua jornada começa agora. Comece a capturar os momentos que importam.';

  @override
  String get onboardingStartJourneyButton => 'Começar Minha Jornada';

  @override
  String get onboardingSkipTourButton => 'Pular Tour';

  @override
  String get onboardingLifelineIntroText =>
      'Esta é a sua Lifeline. Cada memória que você adicionar criará um nó único neste caminho, formando um belo mapa da jornada da sua vida.';

  @override
  String get onboardingLifelineIntroButton => 'Próximo';

  @override
  String get onboardingAddMemoryText =>
      'Toque aqui para adicionar uma nova memória. Um nó aparecerá em sua Lifeline para cada momento que você capturar.';

  @override
  String get onboardingNavGesturesText =>
      'Ótimo! Agora, vamos aprender a navegar em sua linha do tempo.';

  @override
  String get onboardingControlsPanelText =>
      'Use estes controles para gerenciar sua visualização. Você pode recentralizar a linha do tempo, ajustar efeitos visuais e acessar seu perfil.';

  @override
  String get onboardingControlsPanelButton => 'Entendi';

  @override
  String get onboardingStatsCardText =>
      'Este cartão mostra um resumo de suas memórias. Toque nele para abrir uma lista completa e pesquisável de toda a sua jornada.';

  @override
  String get onboardingStatsCardButton => 'Quase lá!';

  @override
  String get audioPlayerPreviousTooltip => 'Faixa Anterior';

  @override
  String get audioPlayerPlayTooltip => 'Tocar';

  @override
  String get audioPlayerPauseTooltip => 'Pausar';

  @override
  String get audioPlayerNextTooltip => 'Próxima Faixa';

  @override
  String memoryEditCbtStepLabel(int step) {
    return 'Passo $step: ';
  }

  @override
  String get premiumBannerTitle => 'Desbloqueie o Lifeline Premium';

  @override
  String get premiumBannerSubtitle =>
      'Mídia ilimitada, reflexão avançada, contexto histórico e muito mais!';

  @override
  String get premiumDialogTitle => 'Atualize para o Premium';

  @override
  String premiumDialogContent(String feature) {
    return 'Desbloqueie a capacidade de $feature e tenha acesso a todos os recursos premium.';
  }

  @override
  String get premiumDialogGoPremium => 'Vá para o Premium';

  @override
  String get premiumFeaturePhotos => 'adicionar mais fotos';

  @override
  String get premiumFeatureVideos => 'adicionar um vídeo';

  @override
  String get premiumFeatureAudio => 'adicionar uma nota de áudio';

  @override
  String get premiumFeatureSpotify => 'adicionar uma faixa do Spotify';

  @override
  String get premiumScreenTitle => 'Lifeline Premium';

  @override
  String get premiumScreenHeaderTitle => 'Desbloqueie seu potencial máximo';

  @override
  String get premiumScreenHeaderSubtitle =>
      'Vá além dos limites com o Lifeline Premium e aproveite ao máximo sua jornada de autodescoberta.';

  @override
  String get premiumFeatureUnlimitedPhotos => 'Fotos e vídeos ilimitados';

  @override
  String get premiumFeatureUnlimitedAudio => 'Notas de áudio ilimitadas';

  @override
  String get premiumFeatureUnlimitedSpotify => 'Faixas do Spotify ilimitadas';

  @override
  String get premiumFeatureAdvancedCbt => 'Assistente de reflexão avançado';

  @override
  String get premiumFeatureActionReminders => 'Lembretes do plano de ação';

  @override
  String get premiumFeatureHistoricalContext =>
      'Contexto histórico \'No Mundo\'';

  @override
  String get premiumFeatureSoundLibrary =>
      'Biblioteca completa de sons ambientes';

  @override
  String get premiumScreenYearlyPopular =>
      'Mais popular e melhor custo-benefício';

  @override
  String get premiumScreenProcessingPurchase => 'Processando compra...';

  @override
  String get premiumScreenRestore => 'Restaurar compras';

  @override
  String get premiumScreenTerms => 'Termos de Serviço';

  @override
  String get premiumScreenPrivacy => 'Política de Privacidade';

  @override
  String get premiumStatusTitle => 'Membro Premium';

  @override
  String premiumStatusExpiresOn(String date) {
    return 'Expira em $date';
  }

  @override
  String get onboardingEncryptionTitle => 'Suas memórias, seguras';

  @override
  String get onboardingEncryptionSubtitle =>
      'O Lifeline oferece criptografia de ponta a ponta. Isso significa que apenas você pode ler suas memórias privadas. Vamos configurar sua Senha Mestra para protegê-las.';

  @override
  String get onboardingEncryptionSetupButton => 'Configurar agora';

  @override
  String get onboardingEncryptionLaterButton => 'Talvez mais tarde';

  @override
  String get onboardingEncryptionActiveTitle => 'A Criptografia está Ativa';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      'As suas memórias já estão protegidas. Pode gerir a sua palavra-passe mestra nas definições do perfil.';

  @override
  String get onboardingEncryptionContinueButton => 'Continuar';

  @override
  String get memoryEditEncryptMemory => 'Criptografar esta memória';

  @override
  String get memoryEditSetupEncryptionTitle => 'Ativar criptografia?';

  @override
  String get memoryEditSetupEncryptionContent =>
      'Para proteger esta memória, você primeiro precisa criar uma Senha Mestra. Esta será sua única chave para todas as entradas criptografadas.';

  @override
  String get memoryEditCreatePasswordButton => 'Criar Senha Mestra';

  @override
  String get memoryViewExportPdf => 'Compartilhar como PDF';

  @override
  String get shareActionTitle => 'Adicionar ao Lifeline';

  @override
  String get shareActionSubtitle =>
      'O que você gostaria de fazer com estes arquivos?';

  @override
  String get shareCreateNewMemory => 'Criar uma Nova Memória';

  @override
  String get shareAddToExisting => 'Adicionar a uma Memória Existente';

  @override
  String get selectMemoryTitle => 'Selecionar uma Memória';

  @override
  String get selectMemorySearchHint => 'Pesquisar por título ou conteúdo...';

  @override
  String get selectMemoryEmpty => 'Nenhuma memória encontrada';

  @override
  String get memoryUpdatedSuccess => 'Memória atualizada com sucesso!';

  @override
  String unlockFailedAttemptsRemaining(int count) {
    return 'Senha incorreta. Restam $count tentativas.';
  }

  @override
  String unlockTooManyAttempts(int seconds) {
    return 'Tentativas demais. Tente novamente em $seconds segundos.';
  }

  @override
  String get unlocking => 'Desbloqueando...';

  @override
  String get exportingPdf => 'Preparando PDF...';

  @override
  String exportFailed(String error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String get profileEnableQuickUnlock => 'Ativar desbloqueio rápido';

  @override
  String get profileQuickUnlockSubtitle =>
      'Use sua impressão digital, rosto ou PIN do dispositivo para desbloquear.';

  @override
  String get profileRequireBiometricsForMemoryTitle =>
      'Exigir biometria para cada memória';

  @override
  String get profileRequireBiometricsForMemorySubtitle =>
      'Se ativado, exija autenticação para abrir ou editar memórias criptografadas individualmente, mesmo quando o app estiver desbloqueado.';

  @override
  String get quickUnlockPrompt => 'Autentique-se para desbloquear o Lifeline';

  @override
  String get quickUnlockEnablePrompt =>
      'Autentique-se para ativar o desbloqueio rápido';

  @override
  String get masterPasswordRequiredTitle => 'Senha mestra obrigatória';

  @override
  String get masterPasswordRequiredContent =>
      'Insira sua senha mestra para ativar este recurso.';

  @override
  String get unlockScreenTitle => 'Desbloquear Lifeline';

  @override
  String get unlockWithBiometrics => 'Desbloquear com biometria';

  @override
  String get unlockEnterMasterPassword => 'Digite a senha mestra';

  @override
  String get unlockForgotPassword => 'Esqueceu a senha?';

  @override
  String get unlockResetEncryptionTitle => 'Redefinir criptografia';

  @override
  String get unlockResetEncryptionWarning =>
      '⚠️ AVISO: Esta ação não pode ser desfeita!';

  @override
  String get unlockResetEncryptionDescription =>
      'Se você esqueceu sua senha mestra, pode redefinir a criptografia. No entanto, isso excluirá permanentemente todas as memórias criptografadas.';

  @override
  String get unlockResetEncryptionConsequences => 'O que será excluído:';

  @override
  String get unlockResetEncryptionConsequence1 =>
      'Todas as memórias criptografadas (locais e na nuvem)';

  @override
  String get unlockResetEncryptionConsequence2 =>
      'A criptografia será desativada';

  @override
  String get unlockResetEncryptionConsequence3 =>
      'Você poderá continuar usando o aplicativo sem criptografia';

  @override
  String get unlockResetEncryptionConfirm => 'Excluir memórias criptografadas';

  @override
  String get unlockResetEncryptionSuccess =>
      'A criptografia foi redefinida. Agora você pode usar o aplicativo sem senha mestra.';

  @override
  String get unlockResetEncryptionError => 'Falha ao redefinir a criptografia';

  @override
  String get draftBannerSingleTitle => 'Você tem uma memória inacabada';

  @override
  String draftBannerSingleSubtitle(String timeAgo) {
    return 'Última edição: $timeAgo';
  }

  @override
  String draftBannerMultipleTitle(int count) {
    return 'Você tem $count memórias inacabadas';
  }

  @override
  String get draftBannerMultipleSubtitle => 'Toque para ver todas';

  @override
  String get draftBannerResume => 'Retomar';

  @override
  String get draftBannerDelete => 'Excluir';

  @override
  String get draftResumedSuccess => 'Rascunho retomado com sucesso';

  @override
  String get draftDeleteDialogTitle => 'Excluir rascunho?';

  @override
  String get draftDeleteDialogMessage =>
      'Este rascunho será excluído permanentemente. Esta ação não pode ser desfeita.';

  @override
  String get draftDeleteCancel => 'Cancelar';

  @override
  String get draftDeleteConfirm => 'Excluir';

  @override
  String get draftDeletedSuccess => 'Rascunho excluído com sucesso';

  @override
  String get draftDeletedError => 'Falha ao excluir rascunho';

  @override
  String draftListDialogTitle(int count) {
    return 'Você tem $count rascunhos';
  }

  @override
  String get draftListItemNoTitle => 'Memória sem título';

  @override
  String get draftListItemNoContent => 'Sem conteúdo';

  @override
  String draftListItemLastModified(String timeAgo) {
    return 'Última modificação: $timeAgo';
  }

  @override
  String get timeAgoJustNow => 'agora mesmo';

  @override
  String timeAgoMinutes(int count) {
    return 'há $count minutos';
  }

  @override
  String timeAgoHours(int count) {
    return 'há $count horas';
  }

  @override
  String timeAgoDays(int count) {
    return 'há $count dias';
  }

  @override
  String timeAgoWeeks(int count) {
    return 'há $count semanas';
  }

  @override
  String get fileSizeTooLargeImage =>
      'O arquivo de imagem é muito grande. O tamanho máximo é de 10 MB.';

  @override
  String get fileSizeTooLargeVideo =>
      'O arquivo de vídeo é muito grande. O tamanho máximo é de 100 MB.';

  @override
  String get fileSizeTooLargeAudio =>
      'O arquivo de áudio é muito grande. O tamanho máximo é de 25 MB.';

  @override
  String get biometricUnlockFailedMessage =>
      'As chaves de segurança precisam ser recriadas após reinstalar o aplicativo. Por favor, insira sua senha mestra para continuar.';

  @override
  String lifelineInsightStreakDays(int count) {
    return '🔥 Sequência de $count dias';
  }

  @override
  String lifelineInsightMemoriesThisMonth(int count) {
    return '📝 $count memórias este mês';
  }

  @override
  String lifelineInsightMemoriesThisWeek(int count) {
    return '✨ $count novos esta semana';
  }

  @override
  String lifelineInsightReflectionsCount(int count) {
    return '⭐ $count reflexões';
  }

  @override
  String lifelineInsightPhotosCount(int count) {
    return '📸 $count fotos';
  }

  @override
  String lifelineInsightAudioCount(int count) {
    return '🎵 $count notas de áudio';
  }

  @override
  String lifelineInsightSpanningYears(int years) {
    return '📅 Abrange $years anos';
  }

  @override
  String lifelineInsightTotalMemories(int count) {
    return '📖 $count momentos capturados';
  }

  @override
  String get lifelineInsightPositiveVibes =>
      '😊 Vibrações principalmente positivas';

  @override
  String get lifelineInsightGrowthJourney => '🌱 Jornada de crescimento';

  @override
  String get lifelineInsightBalancedEmotions => '⚖️ Emoções equilibradas';

  @override
  String get lifelineInsightStartJourney => '✍️ Comece sua jornada';

  @override
  String get lifelineInsightBuildStreak => '💪 Construa sua sequência';

  @override
  String get purchaseSuccessMessage =>
      'Compra bem-sucedida! Bem-vindo ao Premium!';

  @override
  String get graphicsQualityTitle => 'Qualidade gráfica';

  @override
  String get graphicsQualityAuto => 'Auto';

  @override
  String get graphicsQualityLow => 'Baixa';

  @override
  String get graphicsQualityMedium => 'Média';

  @override
  String get graphicsQualityHigh => 'Alta';

  @override
  String get graphicsQualityAutoSubtitle =>
      'Detectar automaticamente o desempenho do dispositivo';

  @override
  String get graphicsQualityLowSubtitle =>
      'Melhor duração da bateria, efeitos mínimos';

  @override
  String get graphicsQualityMediumSubtitle =>
      'Desempenho e visuais equilibrados';

  @override
  String get graphicsQualityHighSubtitle =>
      'Melhores visuais, maior uso de bateria';

  @override
  String graphicsQualityAutoDetected(String performance) {
    return 'Auto ($performance)';
  }

  @override
  String get notificationAnniversaryTitle => 'Lembretes de aniversário';

  @override
  String get notificationAnniversarySubtitle =>
      'Lembrar momentos importantes do passado';

  @override
  String get notificationMotivationalTitle => 'Motivações ocasionais';

  @override
  String get notificationMotivationalSubtitle =>
      'Lembretes suaves para capturar momentos importantes';

  @override
  String get notificationInsightTitle => 'Insights emocionais';

  @override
  String get notificationInsightSubtitle =>
      'Reflexões sobre sua jornada emocional';
}
