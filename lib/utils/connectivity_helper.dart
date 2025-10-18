import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';

/// Helper class for checking internet connectivity
class ConnectivityHelper {
  /// Checks if device has internet connection
  /// Returns true if connected, false otherwise
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to lookup google.com to verify internet connectivity
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      // On any other error, assume no connection to be safe
      return false;
    }
  }

  /// Shows a dialog informing user that AI features require internet
  /// Returns true if user wants to retry, false if dismissed
  static Future<bool> showNoInternetDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.aiNoInternetTitle),
          ],
        ),
        content: Text(l10n.aiNoInternetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.aiNoInternetDismiss),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.aiNoInternetRetry),
          ),
        ],
      ),
    );

    return retry ?? false;
  }

  /// Shows a snackbar with internet warning (less intrusive than dialog)
  static void showNoInternetSnackBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.aiNoInternetMessage),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.aiNoInternetDismiss,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Checks internet and shows warning if not connected
  /// Returns true if connected, false if not
  static Future<bool> checkInternetWithWarning(BuildContext context, {bool useSnackBar = false}) async {
    final hasInternet = await hasInternetConnection();

    if (!hasInternet) {
      if (useSnackBar) {
        showNoInternetSnackBar(context);
      } else {
        await showNoInternetDialog(context);
      }
    }

    return hasInternet;
  }
}
