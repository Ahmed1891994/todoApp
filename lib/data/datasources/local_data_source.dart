import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<String> getString(String key);
  Future<void> setString(String key, String value);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String> getString(String key) async {
    return sharedPreferences.getString(key) ?? '';
  }

  @override
  Future<void> setString(String key, String value) async {
    await sharedPreferences.setString(key, value);
  }
}