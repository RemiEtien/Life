import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/application_providers.dart';
import '../services/encryption_service.dart';

/// A screen that handles unlocking the app via biometrics or master password.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptQuickUnlockWithBiometrics();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ FIXED: This function now properly handles biometric authentication with result checking
  Future<void> _attemptQuickUnlockWithBiometrics() async {
    final encryptionNotifier = ref.read(encryptionServiceProvider.notifier);
    final profile = ref.read(userProfileProvider).value;

    if (profile?.isQuickUnlockEnabled ?? false) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final biometricService = ref.read(biometricServiceProvider);

      // First check if biometrics are still available
      final isAvailable = await biometricService.isBiometricsAvailable();
      if (!isAvailable) {
        // If biometrics were enabled but no longer are, disable the feature for safety
        await encryptionNotifier.disableQuickUnlock();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication is no longer available on this device.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Prevent auto-locking during biometric prompt
      encryptionNotifier.prepareForUnlockAttempt();
      try {
        // Attempt biometric authentication
        final didAuthenticate =
            await biometricService.authenticate(l10n.quickUnlockPrompt);

        if (didAuthenticate && mounted) {
          // ✅ CRITICAL FIX: Check the result of attemptQuickUnlock
          final unlockSuccess = await encryptionNotifier.attemptQuickUnlock();

          if (unlockSuccess) {
            // Success! The AuthGate will automatically navigate away from UnlockScreen
            if (kDebugMode) {
              debugPrint('[UnlockScreen] Quick unlock successful');
            }
          } else {
            // Quick unlock failed despite successful biometric authentication
            if (kDebugMode) {
              debugPrint('[UnlockScreen] Quick unlock failed despite successful biometric authentication');
            }
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.biometricUnlockFailedMessage),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else if (!didAuthenticate && mounted) {
          // User cancelled or biometric failed
          if (kDebugMode) {
            debugPrint('[UnlockScreen] Biometric authentication was cancelled or failed');
          }
        }
      } catch (e) {
        // Handle any errors during the biometric authentication process
        if (kDebugMode) {
          debugPrint('[UnlockScreen] Error during biometric unlock: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred during biometric authentication.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Always reset the unlock attempt flag
        encryptionNotifier.finishUnlockAttempt();
      }
    }
  }

  Future<void> _submitPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final encryptionNotifier = ref.read(encryptionServiceProvider.notifier);

    // BUG FIX: Prevent auto-locking during any async operation related to unlock
    encryptionNotifier.prepareForUnlockAttempt();
    try {
      await encryptionNotifier.unlockSession(_passwordController.text);
      // AuthGate will handle navigation on successful state change.
    } on EncryptionUnlockException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.memoryViewIncorrectPassword;
        });
      }
    } finally {
      // Always reset the flag
      encryptionNotifier.finishUnlockAttempt();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showResetEncryptionDialog(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.unlockResetEncryptionTitle)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.unlockResetEncryptionWarning,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(l10n.unlockResetEncryptionDescription),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delete_forever, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.unlockResetEncryptionConsequences,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${l10n.unlockResetEncryptionConsequence1}',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                    Text(
                      '• ${l10n.unlockResetEncryptionConsequence2}',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                    Text(
                      '• ${l10n.unlockResetEncryptionConsequence3}',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.profileCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.unlockResetEncryptionConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      try {
        final encryptionNotifier = ref.read(encryptionServiceProvider.notifier);
        await encryptionNotifier.resetEncryption();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.unlockResetEncryptionSuccess),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          // AuthGate will automatically navigate to main screen since encryption is now disabled
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.unlockResetEncryptionError}: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider).value;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.lock_outline,
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  l10n.unlockScreenTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 48),
                if (profile?.isQuickUnlockEnabled ?? false) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.unlockWithBiometrics),
                    onPressed:
                        _isLoading ? null : _attemptQuickUnlockWithBiometrics,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.orSignInWith.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 24),
                ],
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.unlockEnterMasterPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => (value?.isEmpty ?? true)
                      ? l10n.profilePasswordCannotBeEmpty
                      : null,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(l10n.memoryEditUnlockButton),
                      ),
                const SizedBox(height: 16),
                // "Forgot Password?" button
                TextButton(
                  onPressed: _isLoading ? null : () => _showResetEncryptionDialog(l10n),
                  child: Text(
                    l10n.unlockForgotPassword,
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
                // FIX: This button now correctly triggers the sign-out flow.
                TextButton(
                  onPressed: () => ref.read(authServiceProvider).signOut(),
                  child: Text(l10n.profileSignOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
