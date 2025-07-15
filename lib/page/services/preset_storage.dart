import 'dart:convert';
import 'package:flashcard/page/model/preset.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresetStorageService {
  static const _key = 'user_presets';

  Future<List<Preset>> loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Preset.fromMap(e)).toList();
  }

  Future<void> savePresets(List<Preset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(presets.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }
}
