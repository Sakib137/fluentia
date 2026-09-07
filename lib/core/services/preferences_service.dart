import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/app_exception.dart';

/// Abstract contract for key-value preferences.
abstract class PreferencesService {
  String? getString(String key);
  Future<bool> setString(String key, String value);

  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);

  int? getInt(String key);
  Future<bool> setInt(String key, int value);

  double? getDouble(String key);
  Future<bool> setDouble(String key, double value);

  List<String>? getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);

  Future<bool> remove(String key);
  Future<bool> clear();
}

/// SharedPreferences implementation of [PreferencesService].
class SharedPreferencesService implements PreferencesService {
  SharedPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to save string preference: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to save bool preference: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to save int preference: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to save double preference: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to save string list preference: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to remove preference: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to clear preferences: $e',
        details: e,
        stackTrace: st,
      );
    }
  }
}

/// Provider for raw SharedPreferences instance, overridden in main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be initialized and overridden in ProviderScope',
  );
});

/// Provider for [PreferencesService].
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesService(prefs);
});
