import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/application_providers.dart';
import '../widgets/premium_upsell_widgets.dart';
import 'package:collection/collection.dart';

// Dialog to create the master password for the first time.
Future<bool> showCreateMasterPasswordDialog(
    BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final encryptionNotifier = ref.read(encryptionServiceProvider.notifier);

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool obscurePassword = true;
      bool obscureConfirmPassword = true;

      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(l10n.profileCreateMasterPassword),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.profileMasterPasswordInfo),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.profileMasterPasswordHint,
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (val) => (val?.length ?? 0) < 8
                        ? l10n.profilePasswordMinLength
                        : null,
                  ),
                  TextFormField(
                    controller: confirmController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: l10n.profileConfirmPasswordHint,
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() =>
                            obscureConfirmPassword = !obscureConfirmPassword),
                      ),
                    ),
                    validator: (val) => val != passwordController.text
                        ? l10n.profilePasswordsDoNotMatch
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.profileCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  if (!context.mounted) return;
                  await encryptionNotifier
                      .setupEncryption(passwordController.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Encryption enabled successfully!')),
                    );
                    Navigator.of(context).pop(true);
                  }
                }
              },
              child: Text(l10n.profileEnable),
            ),
          ],
        );
      });
    },
  );
  passwordController.dispose();
  confirmController.dispose();
  return confirmed ?? false;
}

// Dialog to change the master password.
class _ChangeMasterPasswordDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  const _ChangeMasterPasswordDialog({required this.l10n});

  @override
  ConsumerState<_ChangeMasterPasswordDialog> createState() =>
      __ChangeMasterPasswordDialogState();
}

class __ChangeMasterPasswordDialogState
    extends ConsumerState<_ChangeMasterPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final encryptionNotifier = ref.read(encryptionServiceProvider.notifier);
    final success = await encryptionNotifier.changeMasterPassword(
        _oldPasswordController.text, _newPasswordController.text);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.profileChangePasswordSuccess)),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = widget.l10n.profileChangePasswordErrorIncorrect;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.profileChangePassword),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Text(widget.l10n.profileChangePasswordInfo),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOldPassword,
                  decoration: InputDecoration(
                    labelText:
                        widget.l10n.profileChangePasswordCurrentPasswordHint,
                    errorText: _errorMessage,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureOldPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscureOldPassword = !_obscureOldPassword),
                    ),
                  ),
                  validator: (val) => (val?.isEmpty ?? true)
                      ? widget.l10n.profilePasswordCannotBeEmpty
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText:
                        widget.l10n.profileChangePasswordNewPasswordHint,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword),
                    ),
                  ),
                  validator: (val) => (val?.length ?? 0) < 8
                      ? widget.l10n.profilePasswordMinLength
                      : null,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: widget.l10n.profileConfirmPasswordHint,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (val) => val != _newPasswordController.text
                      ? widget.l10n.profilePasswordsDoNotMatch
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(widget.l10n.profileCancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleChangePassword,
          child: Text(widget.l10n.profileSave),
        ),
      ],
    );
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _displayNameController;
  bool _isDeleting = false;

  final Map<String, String> _supportedLanguages = {
    'en': 'English',
    'ru': 'Русский',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'he': 'עברית',
    'pt': 'Português',
    'zh': '简体中文',
    'ar': 'العربية',
  };

  @override
  void initState() {
    super.initState();
    unawaited(FirebaseCrashlytics.instance.log('ProfileScreen: initState'));
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    unawaited(FirebaseCrashlytics.instance.log('ProfileScreen: dispose'));
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar(UserProfile profile) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated.')),
        );
      }
      return;
    }

    final userService = ref.read(userServiceProvider);
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (image != null) {
      if (!mounted) return;

      // Check file size before upload (10MB limit per Firebase Storage rules)
      const maxImageSize = 10 * 1024 * 1024; // 10MB
      final fileSize = await File(image.path).length();
      if (fileSize > maxImageSize) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.fileSizeTooLargeImage)),
          );
        }
        return;
      }

      final String? photoUrl =
          await userService.uploadAvatar(currentUser.uid, File(image.path));
      if (!mounted) return;
      if (photoUrl != null) {
        final updatedProfile = profile.copyWith(photoUrl: photoUrl);
        await userService.updateUserProfile(updatedProfile);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to upload avatar. Please try again.')),
          );
        }
      }
    }
  }

  Future<void> _showEditDisplayNameDialog(
      UserProfile profile, AppLocalizations l10n) async {
    _displayNameController.text = profile.displayName;
    final userService = ref.read(userServiceProvider);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.profileChangeNameTitle),
          content: TextField(
            controller: _displayNameController,
            decoration: InputDecoration(hintText: l10n.profileEnterYourName),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.profileCancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(l10n.profileSave),
              onPressed: () async {
                final newName = _displayNameController.text.trim();
                if (newName.isNotEmpty) {
                  final updatedProfile = profile.copyWith(displayName: newName);
                  await userService.updateUserProfile(updatedProfile);
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showCountryPicker(UserProfile profile) {
    final userService = ref.read(userServiceProvider);
    showCountryPicker(
      context: context,
      onSelect: (country) async {
        final updatedProfile =
            profile.copyWith(countryCode: country.countryCode);
        await userService.updateUserProfile(updatedProfile);
      },
    );
  }

  Future<void> _showLanguagePickerDialog(
      UserProfile profile, AppLocalizations l10n) async {
    final userService = ref.read(userServiceProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(l10n.profileSelectLanguage),
          children: _supportedLanguages.entries.map((entry) {
            return SimpleDialogOption(
              onPressed: () async {
                final updatedProfile =
                    profile.copyWith(languageCode: entry.key);
                await userService.updateUserProfile(updatedProfile);
                localeNotifier.setLocale(Locale(entry.key));
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(entry.value),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _handleDeleteAccount(AppLocalizations l10n) async {
    if (!mounted) return;
    setState(() => _isDeleting = true);

    FirebaseCrashlytics.instance
        .log('ProfileScreen: Starting account deletion process.');
    if (!mounted) return;
    final audioNotifier = ref.read(audioPlayerProvider.notifier);
    final authService = ref.read(authServiceProvider);

    await audioNotifier.stopAndReset();
    final result = await authService.deleteAccount();
    if (!mounted) {
      FirebaseCrashlytics.instance
          .log('ProfileScreen: Unmounted during deleteAccount.');
      return;
    }
    if (result == 'success') {
      unawaited(FirebaseCrashlytics.instance.log(
          'ProfileScreen: Account deletion successful. Popping until first route.'));
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (result == 'requires-recent-login') {
      FirebaseCrashlytics.instance
          .log('ProfileScreen: Account deletion requires re-authentication.');
      final user = FirebaseAuth.instance.currentUser;
      final providerId = user?.providerData.firstOrNull?.providerId;
      bool reauthSuccess = false;

      FirebaseCrashlytics.instance
          .log('ProfileScreen: Re-auth needed for provider: $providerId');

      try {
        if (providerId == 'password') {
          final didReauth = await _showPasswordReauthDialog(l10n);
          if (!mounted) return;
          reauthSuccess = didReauth ?? false;
        } else {
          final didReauth = await _showSocialReauthDialog(l10n, providerId);
          if (!mounted) return;
          reauthSuccess = didReauth ?? false;
        }

        unawaited(FirebaseCrashlytics.instance.log(
            'ProfileScreen: Re-authentication success status: $reauthSuccess'));
        if (reauthSuccess) {
          FirebaseCrashlytics.instance
              .log('ProfileScreen: Retrying delete after successful re-auth.');
          if (!mounted) return;
          final finalResult = await authService.deleteAccount();
          if (!mounted) return;

          if (finalResult == 'success') {
            FirebaseCrashlytics.instance
                .log('ProfileScreen: Second deletion attempt successful.');
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          } else {
            FirebaseCrashlytics.instance.recordError(
              Exception('Account deletion failed after re-auth'),
              null,
              reason: finalResult,
            );
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(finalResult)));
          }
        } else {
          FirebaseCrashlytics.instance
              .log('ProfileScreen: Re-authentication was cancelled or failed.');
        }
      } catch (e, s) {
        if (!mounted) return;
        FirebaseCrashlytics.instance.recordError(e, s,
            reason: 'Error during re-authentication flow.');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }

      if (mounted) {
        setState(() => _isDeleting = false);
      }
    } else {
      FirebaseCrashlytics.instance.recordError(
        Exception('Account deletion failed on first attempt'),
        null,
        reason: result,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<bool?> _showPasswordReauthDialog(AppLocalizations l10n) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;
    bool isLoading = false;
    final authService = ref.read(authServiceProvider);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          bool obscurePassword = true;
          return AlertDialog(
            title: Text(l10n.profileReauthPasswordDialogTitle),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    Text(l10n.profileReauthPasswordDialogContent),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        errorText: errorMessage,
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                      validator: (val) => (val?.isEmpty ?? true)
                          ? l10n.profilePasswordCannotBeEmpty
                          : null,
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.of(context).pop(false),
                child: Text(l10n.profileCancel),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          setState(() => isLoading = true);
                          try {
                            if (!mounted) return;
                            await authService.reauthenticateWithPassword(
                                passwordController.text);
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'wrong-password' ||
                                e.code == 'invalid-credential') {
                              setState(() {
                                errorMessage =
                                    l10n.profileChangePasswordErrorIncorrect;
                              });
                            } else {
                              setState(() {
                                errorMessage = e.message;
                              });
                            }
                          } finally {
                            if (mounted) setState(() => isLoading = false);
                          }
                        }
                      },
                child: Text(l10n.profileSave),
              ),
            ],
          );
        });
      },
    );
  }

  Future<bool?> _showSocialReauthDialog(
      AppLocalizations l10n, String? providerId) async {
    if (!mounted) return false;
    final authService = ref.read(authServiceProvider);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.profileReauthTitle),
          content: Text(l10n.profileReauthContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.profileCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (providerId == 'google.com') {
                    await authService.reauthenticateWithGoogle();
                  } else if (providerId == 'apple.com') {
                    await authService.reauthenticateWithApple();
                  }
                  if (context.mounted) Navigator.of(context).pop(true);
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Re-authentication failed: $e')));
                  }
                }
              },
              child: Text(l10n.profileReauthButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _HoldToDeleteAccountDialog(l10n: l10n);
      },
    );
    if (confirmed == true) {
      if (mounted) {
        _handleDeleteAccount(l10n);
      }
    }
  }

  Future<void> _replayOnboarding(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileReplayTutorialConfirmTitle),
        content: Text(l10n.profileReplayTutorialConfirmContent),
        actions: [
          TextButton(
            child: Text(l10n.profileCancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text(l10n.profileRestart),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final notifier = ref.read(onboardingServiceProvider.notifier);
      await notifier.replayTour();
      Navigator.of(context).pop('replay_onboarding');
    }
  }

  void _showChangeMasterPasswordDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => _ChangeMasterPasswordDialog(l10n: l10n),
    );
  }

  // NEW: Handle Quick Unlock toggle
  Future<void> _toggleQuickUnlock(
      bool enabled, UserProfile profile, AppLocalizations l10n) async {
    final encryptionNotifier = ref.read(encryptionServiceProvider.notifier);
    if (enabled) {
      // Show master password dialog to authorize enabling this feature
      final password = await _showMasterPasswordEntryDialog(l10n);
      if (password != null && password.isNotEmpty) {
        final success = await encryptionNotifier.enableQuickUnlock(password);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(l10n.profileChangePasswordErrorIncorrect)),
          );
        }
      }
    } else {
      await encryptionNotifier.disableQuickUnlock();
    }
  }

// NEW: Handle per-memory biometric toggle
  Future<void> _toggleRequireBiometricsForMemory(
      bool enabled, UserProfile profile, AppLocalizations l10n) async {
    final userService = ref.read(userServiceProvider);

    if (enabled) {
      // To enable this higher-security feature, we must verify the user's identity first.
      final biometricService = ref.read(biometricServiceProvider);
      final didAuthenticate =
          await biometricService.authenticate(l10n.quickUnlockEnablePrompt);
      if (!didAuthenticate) return; // User cancelled or failed auth
    }

    final updatedProfile = profile.copyWith(requireBiometricForMemory: enabled);
    await userService.updateUserProfile(updatedProfile);
  }

// NEW: Dialog to enter master password
  Future<String?> _showMasterPasswordEntryDialog(
      AppLocalizations l10n) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _MasterPasswordDialog(l10n: l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsyncValue = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authStateChangesProvider).asData?.value;
    final isPremium = ref.watch(isPremiumProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: _isDeleting
          ? _DeletingScreen(l10n: l10n)
          : userProfileAsyncValue.when(
              loading: () => const _LoadingScreen(),
              error: (err, stack) => _ErrorScreen(
                  l10n: l10n,
                  onRetry: () => ref.refresh(userProfileProvider)),
              data: (profile) {
                if (profile == null) {
                  if (currentUser != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        ref
                            .read(userServiceProvider)
                            .ensureUserProfileExists(currentUser, context);
                      }
                    });
                    return const _LoadingScreen();
                  }
                  return _ErrorScreen(
                    l10n: l10n,
                    message: l10n.profileErrorCouldNotFindProfile,
                    onRetry: () => ref.refresh(userProfileProvider),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSectionTitle(l10n.profileSectionProfile, context),
                    const SizedBox(height: 16),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profile.photoUrl != null
                                ? CachedNetworkImageProvider(profile.photoUrl!)
                                : null,
                            child: profile.photoUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      width: 2)),
                              child: IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.white, size: 20),
                                onPressed: () => _changeAvatar(profile),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isPremium)
                      PremiumStatusCard(premiumUntil: profile.premiumUntil)
                    else
                      const PremiumBannerCard(),
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: l10n.profileName,
                      subtitle: profile.displayName,
                      onTap: () => _showEditDisplayNameDialog(profile, l10n),
                    ),
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      title: l10n.profileEmail,
                      subtitle: profile.email,
                    ),
                    _buildInfoTile(
                      icon: Icons.public_outlined,
                      title: l10n.profileCountry,
                      subtitle:
                          profile.countryCode ?? l10n.profileCountryNotSelected,
                      onTap: () => _showCountryPicker(profile),
                    ),
                    _buildInfoTile(
                      icon: Icons.language_outlined,
                      title: l10n.profileLanguage,
                      subtitle: _supportedLanguages[profile.languageCode] ??
                          _supportedLanguages[Localizations.localeOf(context).languageCode] ??
                          'English',
                      onTap: () => _showLanguagePickerDialog(profile, l10n),
                    ),
                    const Divider(height: 40),
                    _buildSectionTitle(l10n.profileSectionSettings, context),
                    _buildNotificationsSetting(profile, l10n),
                    const Divider(height: 40),
                    _buildSectionTitle(l10n.profileSectionSecurity, context),
                    _buildEncryptionSetting(profile, l10n),
                    const Divider(height: 40),
                    _buildSectionTitle(l10n.profileSectionHelp, context),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: Text(l10n.profileReplayTutorial),
                      onTap: () => _replayOnboarding(l10n),
                    ),
                    const Divider(height: 40),
                    _buildSectionTitle(l10n.profileSectionAccount, context),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.profileSignOut),
                      onTap: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        ref.read(audioPlayerProvider.notifier).stopAndReset();
                        ref
                            .read(encryptionServiceProvider.notifier)
                            .lockSession();
                        ref.read(authServiceProvider).signOut();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.delete_forever,
                          color: Colors.red.shade400),
                      title: Text(l10n.profileDeleteAccount,
                          style: TextStyle(color: Colors.red.shade400)),
                      onTap: () => _showDeleteAccountDialog(l10n),
                    ),
                    const SizedBox(height: 32),
                    _buildVersionInfo(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEncryptionSetting(UserProfile profile, AppLocalizations l10n) {
    if (profile.isEncryptionEnabled) {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.password),
            title: Text(l10n.profileChangePassword),
            subtitle: Text(l10n.profileEncryptionActive),
            onTap: () => _showChangeMasterPasswordDialog(l10n),
          ),
          SwitchListTile(
            title: Text(l10n.profileEnableQuickUnlock),
            subtitle: Text(l10n.profileQuickUnlockSubtitle),
            value: profile.isQuickUnlockEnabled,
            onChanged: (value) => _toggleQuickUnlock(value, profile, l10n),
            secondary: const Icon(Icons.fingerprint),
          ),
          // NEW: Switch for per-memory biometrics
          SwitchListTile(
            title: Text(l10n.profileRequireBiometricsForMemoryTitle),
            subtitle: Text(l10n.profileRequireBiometricsForMemorySubtitle),
            value: profile.requireBiometricForMemory,
            // This switch is only enabled if Quick Unlock is also on.
            onChanged: profile.isQuickUnlockEnabled
                ? (value) =>
                    _toggleRequireBiometricsForMemory(value, profile, l10n)
                : null,
            secondary: const Icon(Icons.lock_person_outlined),
          ),
        ],
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.enhanced_encryption_outlined),
        title: Text(l10n.profileEnableEncryption),
        subtitle: Text(l10n.profileEnableEncryptionSubtitle),
        onTap: () => showCreateMasterPasswordDialog(context, ref),
      );
    }
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing:
          onTap != null ? const Icon(Icons.edit_outlined, size: 20) : null,
      onTap: onTap,
    );
  }

  Widget _buildNotificationsSetting(
      UserProfile profile, AppLocalizations l10n) {
    return SwitchListTile(
      title:
          Text(l10n.profileReminders, style: const TextStyle(fontSize: 16)),
      subtitle: Text(l10n.profileRemindersSubtitle),
      value: profile.notificationsEnabled,
      onChanged: (value) {
        final updatedProfile = profile.copyWith(notificationsEnabled: value);
        ref.read(userServiceProvider).updateUserProfile(updatedProfile);
      },
    );
  }

  Widget _buildVersionInfo() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final version = snapshot.data!.version;
          final buildNumber = snapshot.data!.buildNumber;
          return Center(
            child: Text(
              'v$version ($buildNumber)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorScreen extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  const _ErrorScreen(
      {this.message, required this.onRetry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: Colors.redAccent.shade100, size: 60),
            const SizedBox(height: 20),
            Text(
              l10n.authGateSomethingWentWrong,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? l10n.authGateCouldNotLoad,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha(179)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.authGateTryAgain),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletingScreen extends StatelessWidget {
  final AppLocalizations l10n;
  const _DeletingScreen({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(l10n.profileDeletingAccount),
        ],
      ),
    );
  }
}

class _HoldToDeleteAccountDialog extends StatefulWidget {
  final AppLocalizations l10n;
  const _HoldToDeleteAccountDialog({required this.l10n});

  @override
  State<_HoldToDeleteAccountDialog> createState() =>
      __HoldToDeleteAccountDialogState();
}

class __HoldToDeleteAccountDialogState extends State<_HoldToDeleteAccountDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _deleteTimer;
  static const int _holdDurationSeconds = 5;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _holdDurationSeconds),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _deleteTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    _deleteTimer?.cancel();
    _progressController.forward();
    _deleteTimer = Timer(const Duration(seconds: _holdDurationSeconds), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void _cancelHold() {
    _deleteTimer?.cancel();
    _progressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.profileDeleteAccountConfirmTitle),
      content: Text(widget.l10n.profileDeleteAccountConfirmContent),
      actions: <Widget>[
        TextButton(
          child: Text(widget.l10n.profileCancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        Listener(
          onPointerDown: (_) => _startHold(),
          onPointerUp: (_) => _cancelHold(),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return SizedBox(
                width: 100,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor:
                            Colors.red.withAlpha((255 * 0.2).round()),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                    Text(
                      widget.l10n.profileDelete,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Stateful dialog widget for master password entry with show/hide toggle
class _MasterPasswordDialog extends StatefulWidget {
  final AppLocalizations l10n;

  const _MasterPasswordDialog({required this.l10n});

  @override
  State<_MasterPasswordDialog> createState() => _MasterPasswordDialogState();
}

class _MasterPasswordDialogState extends State<_MasterPasswordDialog> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.lock_outline, size: 48),
      title: Text(widget.l10n.masterPasswordRequiredTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.l10n.masterPasswordRequiredContent),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: widget.l10n.profileMasterPasswordHint,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.l10n.profileCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_passwordController.text),
          child: Text(widget.l10n.profileEnable),
        ),
      ],
    );
  }
}
