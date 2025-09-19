// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get signIn => '登录';

  @override
  String get register => '注册';

  @override
  String get createAccount => '创建新账户';

  @override
  String get alreadyHaveAccount => '我已有账户';

  @override
  String get orSignInWith => '或使用其他方式登录';

  @override
  String get passwordTooShort => '密码必须至少为6个字符';

  @override
  String get invalidEmail => '请输入有效的电子邮件地址';

  @override
  String get consentWelcomeTitle => '欢迎来到 Lifeline';

  @override
  String get consentWelcomeSubtitle => '在开始之前，请查看并同意我们的条款。';

  @override
  String get consentIAgreeTo => '我已阅读并同意';

  @override
  String get consentTermsOfService => '服务条款';

  @override
  String get consentAnd => '和';

  @override
  String get consentPrivacyPolicy => '隐私政策';

  @override
  String get consentContinue => '继续';

  @override
  String consentErrorSaving(String error) {
    return '保存设置时出错：$error';
  }

  @override
  String get splashMessageInitializing => '正在初始化...';

  @override
  String get splashMessageCheckingSettings => '正在检查设置...';

  @override
  String get splashMessageAuthenticating => '正在验证...';

  @override
  String get splashMessageSyncing => '正在同步您的时间线...';

  @override
  String get authGateLoadingMemories => '正在加载记忆...';

  @override
  String get authGateAuthenticating => '正在验证...';

  @override
  String get authGateSomethingWentWrong => '出错了';

  @override
  String get authGateCouldNotLoad => '我们无法加载您的数据。请检查您的网络连接并重试。';

  @override
  String get authGateTryAgain => '重试';

  @override
  String get authGateEmptyState => '您的 Lifeline 已准备就绪。\n点击 + 按钮添加您的第一条记忆。';

  @override
  String get authGateUnsavedDraftTitle => '未保存的记忆';

  @override
  String get authGateUnsavedDraftContent => '您有一条未保存的记忆草稿。要继续编辑吗？';

  @override
  String get authGateDiscard => '丢弃';

  @override
  String get authGateContinueEditing => '继续编辑';

  @override
  String get verifyEmailTitle => '电子邮件验证';

  @override
  String get verifyEmailSentTo => '验证邮件已发送至：';

  @override
  String get verifyEmailInstructions => '请点击邮件中的链接以完成注册。';

  @override
  String get verifyEmailResendButton => '重新发送邮件';

  @override
  String get verifyEmailCancelButton => '取消';

  @override
  String get profileTitle => '个人资料和设置';

  @override
  String get profileSectionProfile => '个人资料';

  @override
  String get profileChangeNameTitle => '更改姓名';

  @override
  String get profileEnterYourName => '输入您的姓名';

  @override
  String get profileSave => '保存';

  @override
  String get profileCancel => '取消';

  @override
  String get profileName => '姓名';

  @override
  String get profileEmail => '电子邮件';

  @override
  String get profileCountry => '国家/地区';

  @override
  String get profileCountryNotSelected => '未选择';

  @override
  String get profileLanguage => '内容语言';

  @override
  String get profileLanguageDefault => '英语（默认）';

  @override
  String get profileSelectLanguage => '选择语言';

  @override
  String get profileSectionSettings => '设置';

  @override
  String get profileTheme => '主题';

  @override
  String get profileThemeSystem => '系统';

  @override
  String get profileThemeLight => '浅色';

  @override
  String get profileThemeDark => '深色';

  @override
  String get profileReauthTitle => '需要重新认证';

  @override
  String get profileReauthContent => '这是一项敏感操作。请在继续前重新登录。';

  @override
  String get profileReauthButton => '登录并删除';

  @override
  String get profileReauthPasswordDialogTitle => '确认操作';

  @override
  String get profileReauthPasswordDialogContent => '要删除您的帐户，请输入您当前的密码。';

  @override
  String get profilePasswordCannotBeEmpty => '密码不能为空';

  @override
  String get profileChangePasswordSuccess => '主密码修改成功！';

  @override
  String get profileChangePasswordErrorIncorrect => '您输入的当前主密码不正确。';

  @override
  String get profileOldPasswordHint => '旧密码';

  @override
  String get profileNewPasswordHint => '新密码';

  @override
  String get profileDeleteAccountConfirmContent =>
      '此操作不可逆。您的整个帐户，包括所有记忆和设置，将被永久删除。要继续，请按住删除按钮5秒钟。';

  @override
  String get profileChangePasswordCurrentPasswordHint => '当前主密码';

  @override
  String get profileChangePasswordNewPasswordHint => '新主密码';

  @override
  String get profileChangePasswordInfo => '请输入您当前的主密码以设置新密码。这将重新加密您的密钥。';

  @override
  String get profileGraphics => '图形质量';

  @override
  String get profileGraphicsAuto => '自动';

  @override
  String get profileGraphicsLow => '低';

  @override
  String get profileGraphicsMedium => '中';

  @override
  String get profileGraphicsHigh => '高';

  @override
  String get profileReminders => '反思提醒';

  @override
  String get profileRemindersSubtitle => '接收您的行动计划通知';

  @override
  String get profileSectionSecurity => '安全';

  @override
  String get profileChangePassword => '更改主密码';

  @override
  String get profileEncryptionActive => '端到端加密已激活';

  @override
  String get profileEnableEncryption => '启用端到端加密';

  @override
  String get profileEnableEncryptionSubtitle => '使用主密码保护您的敏感记忆。';

  @override
  String get profileCreateMasterPassword => '创建主密码';

  @override
  String get profileMasterPasswordInfo => '此密码将保护您的记忆。如果忘记，将无法恢复。请妥善保管。';

  @override
  String get profileMasterPasswordHint => '主密码';

  @override
  String get profileConfirmPasswordHint => '确认密码';

  @override
  String get profilePasswordMinLength => '密码必须至少为8个字符';

  @override
  String get profilePasswordsDoNotMatch => '密码不匹配';

  @override
  String get profileEnable => '启用';

  @override
  String get profileSectionHelp => '帮助';

  @override
  String get profileReplayTutorial => '重播教程';

  @override
  String get profileReplayTutorialConfirmTitle => '重播教程？';

  @override
  String get profileReplayTutorialConfirmContent => '您确定要重新开始教程吗？';

  @override
  String get profileRestart => '重新开始';

  @override
  String get profileSectionAccount => '账户管理';

  @override
  String get profileSignOut => '退出登录';

  @override
  String get profileDeleteAccount => '删除账户';

  @override
  String get profileDeleteAccountConfirmTitle => '删除账户？';

  @override
  String get profileDelete => '删除';

  @override
  String get profileDeletingAccount => '正在删除您的账户...';

  @override
  String get profileErrorCouldNotFindProfile => '找不到用户个人资料。';

  @override
  String get memoryEditNewTitle => '新的记忆';

  @override
  String get memoryEditEditTitle => '编辑记忆';

  @override
  String get memoryEditSave => '保存';

  @override
  String get memoryEditTitleHint => '标题';

  @override
  String get memoryEditTitleValidator => '请输入标题';

  @override
  String get memoryEditDescriptionHint => '描述';

  @override
  String get memoryEditDateLabel => '日期：';

  @override
  String get memoryEditSelectDateButton => '选择日期';

  @override
  String get memoryEditAmbientSoundLabel => '环境音：';

  @override
  String get memoryEditAmbientSoundDropdownHint => '选择一个环境音';

  @override
  String get memoryEditMusicAnchorLabel => '音乐锚点：';

  @override
  String get memoryEditAttachTrackButton => '附加 Spotify 曲目';

  @override
  String get memoryEditPhotosLabel => '照片：';

  @override
  String get memoryEditNoPhotosSelected => '未选择照片';

  @override
  String get memoryEditAddPhotosButton => '添加照片';

  @override
  String get memoryEditVideosLabel => '视频：';

  @override
  String get memoryEditNoVideosSelected => '未选择视频';

  @override
  String get memoryEditAddVideoButton => '添加视频';

  @override
  String get memoryEditAudioNoteLabel => '语音备忘：';

  @override
  String get memoryEditAudioNoteSaved => '语音备忘已保存';

  @override
  String get memoryEditRecordButton => '录制';

  @override
  String get memoryEditStopRecordingButton => '停止录制';

  @override
  String get memoryEditRecordingIndicator => '录制中...';

  @override
  String get memoryEditReflectionSectionTitle => '反思';

  @override
  String get memoryEditEncryptLabel => '加密';

  @override
  String get memoryEditEncryptionInfoTooltip => '什么是加密？';

  @override
  String get memoryEditImpactPrompt => '这件事对我有什么影响？';

  @override
  String get memoryEditLessonPrompt => '我学到了什么教训？';

  @override
  String get memoryEditEmotionsLabel => '情绪：';

  @override
  String get emotionJoy => '喜悦';

  @override
  String get emotionNostalgia => '怀旧';

  @override
  String get emotionPride => '骄傲';

  @override
  String get emotionSadness => '悲伤';

  @override
  String get emotionGratitude => '感激';

  @override
  String get emotionLove => '爱';

  @override
  String get emotionFear => '恐惧';

  @override
  String get emotionAnger => '愤怒';

  @override
  String get memoryEditCbtHelperTitle => '反思助手';

  @override
  String get memoryEditCbtStep1Title => '最初的想法或信念是什么？';

  @override
  String get memoryEditCbtStep1Subtitle => '例如，“我会失败”或“我做的一切都对”。';

  @override
  String get memoryEditCbtStep2Title => '有什么支持这个想法？';

  @override
  String get memoryEditCbtStep2Subtitle => '有哪些事实或事件证明这个想法是正确的？';

  @override
  String get memoryEditCbtStep3Title => '从另一面看是什么样的？';

  @override
  String get memoryEditCbtStep3Subtitle => '有哪些事实或事件可能反驳或挑战最初的想法？';

  @override
  String get memoryEditCbtStep4Title => '我怎样才能换个角度看这个问题？';

  @override
  String get memoryEditCbtStep4Subtitle => '根据以上内容，形成一个新的、更平衡的观点。';

  @override
  String get memoryEditActionPlanTitle => '行动计划';

  @override
  String get memoryEditActionPrompt => '我能采取的一小步是什么？';

  @override
  String get memoryEditReminderLabel => '提醒：';

  @override
  String get memoryEditReminderNotSet => '未设置';

  @override
  String get memoryEditSetReminderButton => '设置日期';

  @override
  String get memoryEditYourThoughtsHint => '在此处写下您的想法...';

  @override
  String get memoryEditDraftSavedMessage => '草稿已保存';

  @override
  String get memoryEditErrorRepoUnavailable => '错误：存储库不可用。';

  @override
  String memoryEditErrorSaving(String error) {
    return '保存记忆时出错：$error';
  }

  @override
  String get memoryEditUnlockDialogTitle => '解锁以保存';

  @override
  String get memoryEditUnlockDialogContent => '请输入您的主密码以保存此加密记忆。';

  @override
  String get memoryEditMasterPasswordHint => '主密码';

  @override
  String get memoryEditUnlockButton => '解锁';

  @override
  String get memoryEditEncryptionInfoDialogTitle => '端到端加密';

  @override
  String get memoryEditEncryptionInfoDialogContent =>
      '当您加密一条记忆时，其描述和反思字段将使用从您的主密码派生的密钥进行加密。\n\n数据以不可读的格式存储在云端，只能在您的设备上使用您的密码解密。\n\n重要提示：我们无法恢复您的主密码。如果忘记，您的加密数据将永久丢失。';

  @override
  String get memoryEditOkButton => '好的';

  @override
  String memoryEditPermissionDeniedSnackbar(String permissionName) {
    return ' 的权限已被拒绝。请在设置中启用它。';
  }

  @override
  String get memoryEditSettingsButton => '设置';

  @override
  String get memoryEditNoInternetSnackbar => '搜索音乐需要网络连接。';

  @override
  String memoryEditEmotionIntensityDialogTitle(String emotion) {
    return '“$emotion”的强度';
  }

  @override
  String get memoryViewBackTooltip => '返回';

  @override
  String get memoryViewShareTooltip => '分享';

  @override
  String get memoryViewEditTooltip => '编辑';

  @override
  String get memoryViewDeleteTooltip => '删除';

  @override
  String get memoryViewTabMemory => '记忆';

  @override
  String get memoryViewTabInTheWorld => '世界动态';

  @override
  String get memoryViewEncryptedTitle => '加密的记忆';

  @override
  String get memoryViewReflectionTitle => '反思';

  @override
  String get memoryViewReflectionImpact => '影响';

  @override
  String get memoryViewReflectionLesson => '学到的教训';

  @override
  String get memoryViewCbtStep1Title => '最初的想法或信念';

  @override
  String get memoryViewCbtStep2Title => '支持此想法的证据';

  @override
  String get memoryViewCbtStep3Title => '反对此想法的证据';

  @override
  String get memoryViewCbtStep4Title => '新的、平衡的观点（重构）';

  @override
  String memoryViewActionReminder(String date) {
    return '提醒：$date';
  }

  @override
  String get memoryViewMarkIncompleteTooltip => '标记为未完成';

  @override
  String get memoryViewMarkCompleteTooltip => '标记为已完成';

  @override
  String get memoryViewUnlockDialogTitle => '解锁记忆';

  @override
  String get memoryViewUnlockDialogContent => '输入您的主密码以查看此内容。';

  @override
  String get memoryViewIncorrectPassword => '密码不正确。';

  @override
  String get memoryViewUnlockButton => '解锁';

  @override
  String get memoryViewErrorCouldNotLoadProfile => '无法加载您的个人资料以获取历史数据。';

  @override
  String get memoryViewErrorCouldNotLoadHistoricalData => '无法加载当天的历史数据。';

  @override
  String get memoryViewNoHistoricalData => '当天没有可用的历史数据。';

  @override
  String get memoryViewErrorCouldNotLoadTrack => '无法加载曲目';

  @override
  String get memoryViewTabNews => '新闻';

  @override
  String get memoryViewTabMusic => '音乐';

  @override
  String get memoryViewNoDataForDay => '当天没有数据。';

  @override
  String get memoryViewNoNewsForDay => '当天没有历史新闻。';

  @override
  String memoryViewNewsSource(String source) {
    return '来源：$source';
  }

  @override
  String get memoryViewConfirmDeleteTitle => '确认删除';

  @override
  String get memoryViewConfirmDeleteContent => '此操作不可逆。要继续，请按住删除按钮5秒钟。';

  @override
  String get memoryViewDeleteButton => '删除';

  @override
  String get memoryViewErrorLoadingProfile => '我们无法加载您的个人资料。请检查您的网络连接并重试。';

  @override
  String get memoryViewErrorLocalDb => '错误：无法访问本地数据库。';

  @override
  String get memoryViewMemoryDeleted => '记忆已删除';

  @override
  String get memoryViewSharingNotImplemented => '分享功能尚未实现。';

  @override
  String get memoryViewActionCompleted => '行动已标记为完成！';

  @override
  String get memoryViewActionIncomplete => '行动已标记为未完成。';

  @override
  String memoryViewErrorUpdatingAction(String error) {
    return '更新行动时出错：$error';
  }

  @override
  String get memoryViewContentEncrypted => '内容已加密';

  @override
  String get memoryViewReflectionEncrypted => '反思已加密';

  @override
  String get memoryViewMediaEncrypted => '媒体已加密';

  @override
  String memoryViewAmbientSound(String sound) {
    return '环境音：$sound';
  }

  @override
  String get memoryViewAudioNote => '语音备忘';

  @override
  String get spotifySearchTitle => '搜索 Spotify 曲目';

  @override
  String get spotifySearchHint => '歌曲名称或艺术家';

  @override
  String get documentErrorLoading => '无法加载文档。';

  @override
  String lifelineMemoriesCount(int count) {
    return '记忆：$count条';
  }

  @override
  String lifelinePeriodRange(int startYear, int endYear) {
    return '时期：$startYear - $endYear';
  }

  @override
  String lifelineSyncStatus(String status, int jobs) {
    return '$status (剩余$jobs个)';
  }

  @override
  String get lifelineCalculating => '计算中...';

  @override
  String lifelineScaleValue(int scale) {
    return '缩放：$scale%';
  }

  @override
  String lifelineFpsValue(String fps) {
    return 'FPS: $fps';
  }

  @override
  String lifelineFramePaintValue(int ms) {
    return '帧绘制：$ms毫秒';
  }

  @override
  String get lifelineShowFullTimelineTooltip => '显示完整时间线';

  @override
  String get lifelineVisualSettingsTooltip => '视觉设置';

  @override
  String get lifelineMenuProfile => '个人资料';

  @override
  String get lifelineMenuDebugOn => '开启调试';

  @override
  String get lifelineMenuDebugOff => '关闭调试';

  @override
  String get lifelineMenuSignOut => '退出登录';

  @override
  String get lifelineSearchHint => '搜索...';

  @override
  String get lifelineMemoriesListTitle => '记忆';

  @override
  String get lifelineVisualSettingsDialogTitle => '视觉设置';

  @override
  String get lifelineVisualSettingsSpeed => '速度';

  @override
  String get lifelineVisualSettingsAmplitude => '振幅';

  @override
  String get lifelineVisualSettingsYearLine => '年份线位置';

  @override
  String get lifelineVisualSettingsBranchDensity => '分支密度';

  @override
  String get lifelineVisualSettingsBranchIntensity => '分支强度';

  @override
  String get lifelineVisualSettingsAnimate => '动画';

  @override
  String get lifelineVisualSettingsDoneButton => '完成';

  @override
  String get onboardingWelcomeTitle => '欢迎来到 Lifeline';

  @override
  String get onboardingWelcomeSubtitle =>
      '您的个人旅程，可视化呈现。让我们快速浏览一下，看看如何开始记录您的瞬间。';

  @override
  String get onboardingSkipButton => '暂时跳过';

  @override
  String get onboardingBeginTourButton => '开始导览';

  @override
  String get onboardingGesturesTitle => '导航您的时间线';

  @override
  String get onboardingGestureSwipe => '滑动';

  @override
  String get onboardingGesturePinch => '捏合缩放';

  @override
  String get onboardingGesturesSubtitle =>
      '您的 Lifeline 将与您一同成长。捏合以缩小，查看全局。左右滑动以在时间中导航。';

  @override
  String get onboardingContinueButton => '继续';

  @override
  String get onboardingFinalTitle => '一切就绪！';

  @override
  String get onboardingFinalSubtitle => '您的旅程现在开始。开始记录那些重要的瞬间。';

  @override
  String get onboardingStartJourneyButton => '开始我的旅程';

  @override
  String get onboardingSkipTourButton => '跳过导览';

  @override
  String get onboardingLifelineIntroText =>
      '这是您的 Lifeline。您添加的每一条记忆都将在此路径上创建一个独特的节点，构成您人生旅程的美丽地图。';

  @override
  String get onboardingLifelineIntroButton => '下一步';

  @override
  String get onboardingAddMemoryText =>
      '点击此处添加新的记忆。您记录的每个瞬间都会在您的 Lifeline 上出现一个节点。';

  @override
  String get onboardingNavGesturesText => '太棒了！现在，让我们学习如何导航您的时间线。';

  @override
  String get onboardingControlsPanelText =>
      '使用这些控件来管理您的视图。您可以重新居中时间线、调整视觉效果并访问您的个人资料。';

  @override
  String get onboardingControlsPanelButton => '明白了';

  @override
  String get onboardingStatsCardText => '这张卡片显示了您的记忆摘要。点击它以打开您整个旅程的完整、可搜索的列表。';

  @override
  String get onboardingStatsCardButton => '快完成了！';

  @override
  String get audioPlayerPreviousTooltip => '上一首';

  @override
  String get audioPlayerPlayTooltip => '播放';

  @override
  String get audioPlayerPauseTooltip => '暂停';

  @override
  String get audioPlayerNextTooltip => '下一首';

  @override
  String memoryEditCbtStepLabel(int step) {
    return '第 $step 步: ';
  }

  @override
  String get premiumBannerTitle => '解锁 Lifeline 高级版';

  @override
  String get premiumBannerSubtitle => '无限媒体、高级反思、历史背景等等！';

  @override
  String get premiumDialogTitle => '升级到高级版';

  @override
  String premiumDialogContent(String feature) {
    return '解锁$feature的功能并访问所有高级功能。';
  }

  @override
  String get premiumDialogGoPremium => '成为高级会员';

  @override
  String get premiumFeaturePhotos => '添加更多照片';

  @override
  String get premiumFeatureVideos => '添加视频';

  @override
  String get premiumFeatureAudio => '添加音频笔记';

  @override
  String get premiumFeatureSpotify => '添加 Spotify 曲目';

  @override
  String get premiumScreenTitle => 'Lifeline 高级版';

  @override
  String get premiumScreenHeaderTitle => '释放您的全部潜力';

  @override
  String get premiumScreenHeaderSubtitle =>
      '使用 Lifeline 高级版超越极限，从您的自我发现之旅中获得最大收益。';

  @override
  String get premiumFeatureUnlimitedPhotos => '无限照片和视频';

  @override
  String get premiumFeatureUnlimitedAudio => '无限音频笔记';

  @override
  String get premiumFeatureUnlimitedSpotify => '无限 Spotify 曲目';

  @override
  String get premiumFeatureAdvancedCbt => '高级反思助手';

  @override
  String get premiumFeatureActionReminders => '行动计划提醒';

  @override
  String get premiumFeatureHistoricalContext => '历史“世界动态”背景';

  @override
  String get premiumFeatureSoundLibrary => '完整的环境音库';

  @override
  String get premiumScreenYearlyPopular => '最受欢迎和最超值';

  @override
  String get premiumScreenRestore => '恢复购买';

  @override
  String get premiumScreenTerms => '服务条款';

  @override
  String get premiumScreenPrivacy => '隐私政策';

  @override
  String get premiumStatusTitle => '高级会员';

  @override
  String premiumStatusExpiresOn(String date) {
    return '有效期至 $date';
  }

  @override
  String get onboardingEncryptionTitle => '您的记忆，安全无虞';

  @override
  String get onboardingEncryptionSubtitle =>
      'Lifeline 提供端到端加密。这意味着只有您可以阅读您的私人记忆。让我们来设置您的主密码以保护它们。';

  @override
  String get onboardingEncryptionSetupButton => '立即设置';

  @override
  String get onboardingEncryptionLaterButton => '以后再说';

  @override
  String get onboardingEncryptionActiveTitle => '加密已激活';

  @override
  String get onboardingEncryptionActiveSubtitle =>
      '您的记忆已受保护。您可以在个人资料设置中管理您的主密码。';

  @override
  String get onboardingEncryptionContinueButton => '继续';

  @override
  String get memoryEditEncryptMemory => '加密此记忆';

  @override
  String get memoryEditSetupEncryptionTitle => '启用加密？';

  @override
  String get memoryEditSetupEncryptionContent =>
      '要保护此记忆，您首先需要创建一个主密码。这将是您所有加密条目的唯一密钥。';

  @override
  String get memoryEditCreatePasswordButton => '创建主密码';

  @override
  String get memoryViewExportPdf => '以 PDF 格式分享';
}
