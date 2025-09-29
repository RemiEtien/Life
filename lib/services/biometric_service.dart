import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// A service that abstracts the functionality of the local_auth package.
/// This helps in centralizing biometric logic and makes it easier to mock for testing.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if biometrics (like fingerprint or face ID) are available on the device.
  Future<bool> isBiometricsAvailable() async {
    try {
      // canCheckBiometrics checks if hardware is present.
      final canCheck = await _auth.canCheckBiometrics;
      // isDeviceSupported checks if there are any biometrics enrolled.
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      // Handle exceptions, e.g., if the platform is not supported.
      return false;
    }
  }

  /// Prompts the user to authenticate using biometrics or the device passcode/PIN.
  Future<bool> authenticate(String localizedReason) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          // stickyAuth makes the auth dialog stay even if the app goes to the background.
          stickyAuth: true,
          // biometricOnly = false allows fallback to PIN/passcode if biometrics fail or are not enrolled.
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      // Handle exceptions during authentication (e.g., user cancels).
      return false;
    }
  }
}
