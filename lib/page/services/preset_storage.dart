import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard/page/model/preset.dart';

class PresetStorage {
  static Future<List<Preset>> loadPresetsForUser(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('presets')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Preset.fromMap(doc.id, doc.data());
    }).toList();
  }

  static Future<void> addPreset(Preset preset) async {
    await FirebaseFirestore.instance.collection('presets').add(preset.toMap());
  }

  static Future<void> deletePreset(String id) async {
    await FirebaseFirestore.instance.collection('presets').doc(id).delete();
  }
}
