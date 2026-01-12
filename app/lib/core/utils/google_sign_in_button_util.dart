import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _kUserPreferencesBox = 'userPreferencesBox';

final googleLoginEnabledProvider = StateProvider<bool>((ref) {
  return false;
});

Future<bool> initializeGoogleLoginEnabled() async {
  try {
    if (!Hive.isBoxOpen(_kUserPreferencesBox)) {
      await Hive.openBox<dynamic>(_kUserPreferencesBox);
    }
    final box = Hive.box<dynamic>(_kUserPreferencesBox);
    final value = box.get('googleLoginEnabled', defaultValue: false);
    return value as bool;
  } catch (e) {
    return false;
  }
}

Future<void> setGoogleLoginEnabled(bool enabled) async {
  try {
    if (!Hive.isBoxOpen(_kUserPreferencesBox)) {
      await Hive.openBox<dynamic>(_kUserPreferencesBox);
    }
    final box = Hive.box<dynamic>(_kUserPreferencesBox);
    await box.put('googleLoginEnabled', enabled);
  } catch (e) {
    // Silently fail - non-critical preference that doesn't affect app functionality
  }
}

typedef GoogleSignInCallback = void Function();

Widget buildGoogleSignInButton({
  required bool isEnabled,
  required bool isLoading,
  required GoogleSignInCallback onPressed,
  String label = 'Sign in with Google',
}) {
  if (!isEnabled) {
    return const SizedBox.shrink();
  }

  return SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.account_circle, size: 24),
      label: isLoading
          ? const Text('Signing in...')
          : Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
