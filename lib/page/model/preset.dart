class Preset {
  final String id;
  final String name;
  final String goal;
  final Duration duration;
  final bool skipBreak;

  Preset({
    required this.id,
    required this.name,
    required this.goal,
    required this.duration,
    required this.skipBreak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'duration': duration.inSeconds,
      'skipBreak': skipBreak,
    };
  }

  factory Preset.fromMap(Map<String, dynamic> map) {
    return Preset(
      id: map['id'],
      name: map['name'],
      goal: map['goal'],
      duration: Duration(seconds: map['duration']),
      skipBreak: map['skipBreak'],
    );
  }
}
