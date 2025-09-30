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
            SnackBar(
              content: const Text('Biometric authentication is no longer available on this device.'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Biometric unlock failed. Please use your master password.'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
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
            SnackBar(
              content: const Text('An error occurred during biometric authentication.'),
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
