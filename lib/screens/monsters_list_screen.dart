// lib/screens/monsters_list_screen.dart

import 'package:flutter/material.dart';
import '../models/monster.dart';
import '../services/monster_service.dart';
import 'edit_monster_screen.dart';

class MonstersListScreen extends StatefulWidget {
  const MonstersListScreen({super.key});
  @override
  State<MonstersListScreen> createState() => _MonstersListScreenState();
}

class _MonstersListScreenState extends State<MonstersListScreen> {
  List<Monster> _monsters  = [];
  List<Monster> _filtered  = [];
  bool _loading            = true;
  String _searchQuery      = '';
  final _searchCtrl        = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await MonsterService.getAllMonsters();
      setState(() {
        _monsters = list;
        _applyFilter();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
      _showError('Failed to load monsters. Check VPN connection.');
    }
  }

  void _applyFilter() {
    final q = _searchQuery.toLowerCase();
    _filtered = q.isEmpty
        ? List.from(_monsters)
        : _monsters
            .where((m) =>
                m.monsterName.toLowerCase().contains(q) ||
                m.monsterType.toLowerCase().contains(q))
            .toList();
  }

  void _onSearch(String val) {
    setState(() { _searchQuery = val; _applyFilter(); });
  }

  Future<void> _delete(Monster monster) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Monster'),
        content: Text(
            'Delete "${monster.monsterName}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await MonsterService.deleteMonster(monster.monsterId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Deleted'),
            backgroundColor: Colors.red.shade600,
          ),
        );
        _load();
      }
    } catch (_) {
      _showError('Delete failed.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search bar ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search monsters…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearch('');
                      })
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),

        // ── Stats bar ─────────────────────────────────────────────────
        if (!_loading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Text('${_filtered.length} monster(s)',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

        // ── List / States ─────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) =>
                            _monsterCard(_filtered[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _monsterCard(Monster m) {
    final emoji = Monster.typeEmoji(m.monsterType);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
          radius: 26,
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          m.monsterName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                _typeChip(m.monsterType),
                const SizedBox(width: 6),
                Text('r: ${m.spawnRadiusMeters.toStringAsFixed(0)}m',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '📍 ${m.spawnLatitude.toStringAsFixed(5)}, ${m.spawnLongitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Color(0xFF1A237E)),
              tooltip: 'Edit',
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditMonsterScreen(monster: m)),
                );
                if (updated == true) _load();
              },
            ),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => _delete(m),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(type,
          style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.catching_pokemon,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No monsters match "$_searchQuery"'
                : 'No monsters yet.\nTap + to add the first one!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
