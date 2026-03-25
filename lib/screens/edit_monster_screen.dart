// lib/screens/edit_monster_screen.dart
// Uses flutter_map + OpenStreetMap — NO Google Maps API key required.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/monster.dart';
import '../services/monster_service.dart';

class EditMonsterScreen extends StatefulWidget {
  final Monster monster;
  const EditMonsterScreen({super.key, required this.monster});
  @override
  State<EditMonsterScreen> createState() => _EditMonsterScreenState();
}

class _EditMonsterScreenState extends State<EditMonsterScreen> {
  final _formKey    = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _radiusCtrl;
  late String _selectedType;
  late LatLng _spawnPoint;
  bool _loading = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    final m = widget.monster;
    _nameCtrl     = TextEditingController(text: m.monsterName);
    _radiusCtrl   = TextEditingController(text: m.spawnRadiusMeters.toStringAsFixed(0));
    _selectedType = m.monsterType;
    _spawnPoint   = LatLng(m.spawnLatitude, m.spawnLongitude);
  }

  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    setState(() => _spawnPoint = latLng);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = await MonsterService.updateMonster({
        'monster_id': widget.monster.monsterId,
        'monster_name': _nameCtrl.text.trim(),
        'monster_type': _selectedType,
        'spawn_latitude': _spawnPoint.latitude,
        'spawn_longitude': _spawnPoint.longitude,
        'spawn_radius_meters': double.tryParse(_radiusCtrl.text) ?? 100.0,
      });
      if (mounted) {
        if (result['message'] != null && !result.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${_nameCtrl.text.trim()} updated!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Update failed'),
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
        title: const Text('Edit Monster', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Form fields ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Monster ID (read-only)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tag, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Monster ID: ${widget.monster.monsterId}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

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

                  // Monster Type
                  DropdownButtonFormField<String>(
                    value: Monster.types.contains(_selectedType)
                        ? _selectedType
                        : Monster.types.first,
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
                  const SizedBox(height: 8),

                  // Spawn point coords
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Lat: ${_spawnPoint.latitude.toStringAsFixed(6)}  '
                          'Lng: ${_spawnPoint.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Tap map to move spawn point',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                      initialCenter: _spawnPoint,
                      initialZoom: 15,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.hau.pokemon',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _spawnPoint,
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
                      : const Text('UPDATE MONSTER',
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