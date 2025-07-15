class Preset {
  final String id;
  final String userId;
  final String name;
  final String goal;
  final Duration duration;
  final bool skipBreak;

  Preset({
    required this.id,
    required this.userId,
    required this.name,
    required this.goal,
    required this.duration,
    required this.skipBreak,
  });

  factory Preset.fromMap(String id, Map<String, dynamic> data) {
    return Preset(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Unnamed',
      goal: data['goal'] ?? 'Other',
      duration: Duration(minutes: data['duration'] ?? 25),
      skipBreak: data['skipBreak'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'goal': goal,
      'duration': duration.inMinutes,
      'skipBreak': skipBreak,
      'timestamp': DateTime.now(),
    };
  }
}
