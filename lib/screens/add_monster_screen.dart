// lib/screens/add_monster_screen.dart
// Uses flutter_map + OpenStreetMap — NO Google Maps API key required.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';
import '../models/monster.dart';
import '../services/monster_service.dart';

class AddMonsterScreen extends StatefulWidget {
  const AddMonsterScreen({super.key});
  @override
  State<AddMonsterScreen> createState() => _AddMonsterScreenState();
}

class _AddMonsterScreenState extends State<AddMonsterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _radiusCtrl   = TextEditingController(text: '100');
  String _selectedType = 'Normal';
  LatLng? _spawnPoint;
  bool _loading       = false;
  final MapController _mapController = MapController();

  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    setState(() => _spawnPoint = latLng);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_spawnPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📍 Tap on the map to set spawn point')));
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await MonsterService.addMonster({
        'monster_name': _nameCtrl.text.trim(),
        'monster_type': _selectedType,
        'spawn_latitude': _spawnPoint!.latitude,
        'spawn_longitude': _spawnPoint!.longitude,
        'spawn_radius_meters': double.tryParse(_radiusCtrl.text) ?? 100.0,
      });
      if (mounted) {
        if (result['monster_id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${_nameCtrl.text.trim()} added! ID: ${result['monster_id']}'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to add monster'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connection error. Check VPN.')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Monster', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Form Fields ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Monster Name
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Monster Name *',
                      prefixIcon: Icon(Icons.catching_pokemon),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter monster name'
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // Monster Type dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Monster Type *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: Monster.types
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text('${Monster.typeEmoji(t)} $t')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                  const SizedBox(height: 10),

                  // Spawn radius
                  TextFormField(
                    controller: _radiusCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Spawn Radius (meters)',
                      prefixIcon: Icon(Icons.radio_button_unchecked),
                    ),
                    validator: (v) {
                      final d = double.tryParse(v ?? '');
                      if (d == null || d <= 0) return 'Enter a valid radius';
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),

                  // Spawn point indicator
                  if (_spawnPoint != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Lat: ${_spawnPoint!.latitude.toStringAsFixed(6)}  '
                            'Lng: ${_spawnPoint!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app, color: Colors.orange, size: 16),
                          SizedBox(width: 6),
                          Text('Tap the map below to set spawn point',
                              style: TextStyle(fontSize: 12, color: Colors.orange)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ── OpenStreetMap ────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(AppConfig.defaultLat, AppConfig.defaultLng),
                      initialZoom: 15,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.hau.pokemon',
                      ),
                      if (_spawnPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _spawnPoint!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.deepPurple,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Hint overlay
                  if (_spawnPoint == null)
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('👆 Tap to place spawn point',
                              style: TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                      ),
                    ),
                  // OSM attribution (required by OSM license)
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
            ),

            // ── Save button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SAVE MONSTER',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}