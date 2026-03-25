// lib/screens/monster_map_screen.dart
// Uses flutter_map + OpenStreetMap — NO Google Maps API key required.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';
import '../models/monster.dart';
import '../services/monster_service.dart';

class MonsterMapScreen extends StatefulWidget {
  const MonsterMapScreen({super.key});
  @override
  State<MonsterMapScreen> createState() => _MonsterMapScreenState();
}

class _MonsterMapScreenState extends State<MonsterMapScreen> {
  final MapController _mapController = MapController();
  List<Monster> _monsters = [];
  bool _loading     = true;
  bool _showCircles = true;
  Monster? _selected;

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  Future<void> _loadMonsters() async {
    setState(() => _loading = true);
    try {
      final list = await MonsterService.getAllMonsters();
      setState(() { _monsters = list; _loading = false; });
      if (list.isNotEmpty) _fitBounds();
    } catch (_) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load monsters.')));
      }
    }
  }

  void _fitBounds() {
    if (_monsters.isEmpty) return;
    double minLat = _monsters.first.spawnLatitude;
    double maxLat = _monsters.first.spawnLatitude;
    double minLng = _monsters.first.spawnLongitude;
    double maxLng = _monsters.first.spawnLongitude;

    for (final m in _monsters) {
      if (m.spawnLatitude  < minLat) minLat = m.spawnLatitude;
      if (m.spawnLatitude  > maxLat) maxLat = m.spawnLatitude;
      if (m.spawnLongitude < minLng) minLng = m.spawnLongitude;
      if (m.spawnLongitude > maxLng) maxLng = m.spawnLongitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat - 0.005, minLng - 0.005),
      LatLng(maxLat + 0.005, maxLng + 0.005),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)));
    });
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':     return Colors.red;
      case 'water':    return Colors.blue;
      case 'grass':    return Colors.green;
      case 'electric': return Colors.yellow.shade700;
      case 'psychic':  return Colors.purple;
      case 'ice':      return Colors.cyan;
      case 'dark':     return Colors.deepPurple;
      case 'dragon':   return Colors.indigo;
      default:         return Colors.orange;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monster Map (${_monsters.length})',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Toggle spawn-radius circles
          IconButton(
            icon: Icon(
                _showCircles ? Icons.radio_button_checked : Icons.circle_outlined,
                color: Colors.white),
            tooltip: 'Toggle spawn circles',
            onPressed: () => setState(() => _showCircles = !_showCircles),
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadMonsters,
          ),
          // Fit all
          IconButton(
            icon: const Icon(Icons.fit_screen, color: Colors.white),
            tooltip: 'Fit all',
            onPressed: _fitBounds,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(AppConfig.defaultLat, AppConfig.defaultLng),
              initialZoom: 13,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              // Tile layer (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hau.pokemon',
              ),

              // Spawn radius circles
              if (_showCircles)
                CircleLayer(
                  circles: _monsters.map((m) => CircleMarker(
                    point: LatLng(m.spawnLatitude, m.spawnLongitude),
                    radius: m.spawnRadiusMeters,
                    useRadiusInMeter: true,
                    color: _colorForType(m.monsterType).withOpacity(0.15),
                    borderColor: _colorForType(m.monsterType).withOpacity(0.7),
                    borderStrokeWidth: 1.5,
                  )).toList(),
                ),

              // Monster markers
              MarkerLayer(
                markers: _monsters.map((m) {
                  final color = _colorForType(m.monsterType);
                  final emoji = Monster.typeEmoji(m.monsterType);
                  return Marker(
                    point: LatLng(m.spawnLatitude, m.spawnLongitude),
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = m),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Loading overlay
          if (_loading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Loading monsters…'),
                    ],
                  ),
                ),
              ),
            ),

          // Selected monster info card
          if (_selected != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _colorForType(_selected!.monsterType).withOpacity(0.15),
                        child: Text(Monster.typeEmoji(_selected!.monsterType),
                            style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selected!.monsterName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('${_selected!.monsterType} • radius: ${_selected!.spawnRadiusMeters.toStringAsFixed(0)}m',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('📍 ${_selected!.spawnLatitude.toStringAsFixed(5)}, ${_selected!.spawnLongitude.toStringAsFixed(5)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _selected = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Type legend
          if (!_loading && _monsters.isNotEmpty)
            Positioned(
              top: 12,
              left: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Types:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ..._monsters.map((m) => m.monsterType).toSet().map((t) =>
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  color: _colorForType(t), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${Monster.typeEmoji(t)} $t (${_monsters.where((m) => m.monsterType == t).length})',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Empty state
          if (!_loading && _monsters.isEmpty)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.catching_pokemon, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No monsters on map yet.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),

          // OSM attribution
          Positioned(
            bottom: 4,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('© OpenStreetMap',
                  style: TextStyle(fontSize: 10, color: Colors.black54)),
            ),
          ),
        ],
      ),
    );
  }
}