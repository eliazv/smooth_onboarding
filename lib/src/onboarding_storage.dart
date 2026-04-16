import 'package:shared_preferences/shared_preferences.dart';

/// Persistence helper used to remember whether onboarding was completed.
class OnboardingStorage {
  /// Default key used to store completion state.
  static const String defaultStorageKey = 'smooth_onboarding_done';

  /// Returns `true` when onboarding has not been completed yet.
  static Future<bool> isFirstLaunch(
      {String storageKey = defaultStorageKey}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return !(preferences.getBool(storageKey) ?? false);
  }

  /// Returns `true` when onboarding should be shown.
  static Future<bool> shouldShowOnboarding(
      {String storageKey = defaultStorageKey}) async {
    return isFirstLaunch(storageKey: storageKey);
  }

  /// Returns `true` when onboarding completion has already been stored.
  static Future<bool> isCompleted(
      {String storageKey = defaultStorageKey}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(storageKey) ?? false;
  }

  /// Marks onboarding as completed.
  static Future<void> markCompleted(
      {String storageKey = defaultStorageKey}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(storageKey, true);
  }

  /// Clears the completion flag.
  static Future<void> reset({String storageKey = defaultStorageKey}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
