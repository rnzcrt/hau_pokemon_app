// lib/screens/leaderboard_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List _leaders = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await http.get(Uri.parse(AppConfig.leaderboard));
      final data = jsonDecode(res.body);
      setState(() {
        _leaders = data['leaderboard'] ?? [];
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Failed to load leaderboard. Check VPN.';
      });
    }
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // gold
    if (rank == 2) return const Color(0xFFC0C0C0); // silver
    if (rank == 3) return const Color(0xFFCD7F32); // bronze
    return Colors.blueGrey;
  }

  String _rankEmoji(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '$rank';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header banner ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
            ),
          ),
          child: const Column(
            children: [
              Text('🏆', style: TextStyle(fontSize: 32)),
              Text('Top 10 Monster Hunters',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),

        // ── Body ─────────────────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(_error,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: _loadLeaderboard,
                              child: const Text('Retry')),
                        ],
                      ),
                    )
                  : _leaders.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🏆',
                                  style: TextStyle(fontSize: 60)),
                              SizedBox(height: 8),
                              Text('No catches yet.\nBe the first hunter!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadLeaderboard,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            itemCount: _leaders.length,
                            itemBuilder: (ctx, i) {
                              final p = _leaders[i];
                              final rank =
                                  int.tryParse(p['rank'].toString()) ??
                                      (i + 1);
                              final isTop3 = rank <= 3;
                              return Card(
                                margin:
                                    const EdgeInsets.only(bottom: 8),
                                elevation: isTop3 ? 4 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: isTop3
                                      ? BorderSide(
                                          color: _rankColor(rank)
                                              .withOpacity(0.6),
                                          width: 1.5)
                                      : BorderSide.none,
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _rankColor(rank),
                                    radius: 22,
                                    child: Text(
                                      _rankEmoji(rank),
                                      style: const TextStyle(
                                          fontSize: 18),
                                    ),
                                  ),
                                  title: Text(
                                    p['player_name'] ?? 'Unknown',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTop3 ? 16 : 14),
                                  ),
                                  subtitle: Text(
                                      '@${p['username'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 12)),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${p['total_catches']}',
                                        style: TextStyle(
                                            fontSize: isTop3 ? 26 : 22,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(
                                                0xFF1A237E)),
                                      ),
                                      const Text('caught',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
