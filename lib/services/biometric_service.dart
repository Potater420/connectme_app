import 'package:local_auth/local_auth.dart';

/// The only file that talks to the fingerprint sensor.
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Returns true only if the user passed the fingerprint check.
  Future<bool> authenticate() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final hasBiometrics = await _localAuth.canCheckBiometrics;
      if (!isSupported || !hasBiometrics) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Verify your fingerprint to open your profile',
        biometricOnly: true,
      );
    } catch (_) {
      // Cancelled, locked out, or no hardware: treat all as "not verified".
      return false;
    }
  }
}
