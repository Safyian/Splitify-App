import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks whether the user has already seen the onboarding flow.
///
/// Uses a local flag in secure storage. If the user reinstalls or switches
/// devices they'll see onboarding again — acceptable for an educational intro.
class OnboardingHelper {
  OnboardingHelper._();

  static const _key = 'has_seen_onboarding';
  static const _storage = FlutterSecureStorage();

  static Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  static Future<void> markSeen() async {
    await _storage.write(key: _key, value: 'true');
  }

  /// Optional: call on logout if you want onboarding to show again for a
  /// fresh account on the same device. Leave unused to keep it once-per-device.
  static Future<void> reset() async {
    await _storage.delete(key: _key);
  }
}
