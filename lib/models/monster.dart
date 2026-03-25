// lib/models/monster.dart

class Monster {
  final int monsterId;
  final String monsterName;
  final String monsterType;
  final double spawnLatitude;
  final double spawnLongitude;
  final double spawnRadiusMeters;

  Monster({
    required this.monsterId,
    required this.monsterName,
    required this.monsterType,
    required this.spawnLatitude,
    required this.spawnLongitude,
    required this.spawnRadiusMeters,
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      monsterId: int.tryParse(json['monster_id'].toString()) ?? 0,
      monsterName: json['monster_name'] ?? '',
      monsterType: json['monster_type'] ?? '',
      spawnLatitude: double.tryParse(json['spawn_latitude'].toString()) ?? 0.0,
      spawnLongitude: double.tryParse(json['spawn_longitude'].toString()) ?? 0.0,
      spawnRadiusMeters:
          double.tryParse(json['spawn_radius_meters'].toString()) ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'monster_id': monsterId,
        'monster_name': monsterName,
        'monster_type': monsterType,
        'spawn_latitude': spawnLatitude,
        'spawn_longitude': spawnLongitude,
        'spawn_radius_meters': spawnRadiusMeters,
      };

  /// Type emoji helper for UI
  static String typeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'fire':    return '🔥';
      case 'water':   return '💧';
      case 'grass':   return '🌿';
      case 'electric':return '⚡';
      case 'psychic': return '🔮';
      case 'dark':    return '🌑';
      case 'ice':     return '❄️';
      case 'dragon':  return '🐉';
      case 'ghost':   return '👻';
      case 'rock':    return '🪨';
      case 'ground':  return '🌍';
      case 'flying':  return '🦅';
      default:        return '⭐';
    }
  }

  static const List<String> types = [
    'Normal', 'Fire', 'Water', 'Grass', 'Electric',
    'Ice', 'Fighting', 'Poison', 'Ground', 'Flying',
    'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon',
    'Dark', 'Steel', 'Fairy',
  ];
}
