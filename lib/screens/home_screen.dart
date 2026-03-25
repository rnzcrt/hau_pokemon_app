// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'monsters_list_screen.dart';
import 'catch_monsters_screen.dart';
import 'leaderboard_screen.dart';
import 'ec2_control_screen.dart';
import 'about_us_screen.dart';
import 'monster_map_screen.dart';
import 'add_monster_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _playerName;

  final List<Widget> _screens = const [
    MonstersListScreen(),
    CatchMonstersScreen(),
    LeaderboardScreen(),
    EC2ControlScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getPlayerName();
    setState(() => _playerName = name);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text('HAUPokemon',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      // ── Side Drawer ─────────────────────────────────────────────────────
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1A237E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.catching_pokemon,
                      size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text('HAUPokemon',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  if (_playerName != null)
                    Text('👤 $_playerName',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Color(0xFF1A237E)),
              title: const Text('Add Monster'),
              onTap: () async {
                Navigator.pop(context);
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMonsterScreen()),
                );
                if (created == true) setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF1A237E)),
              title: const Text('Monsters List'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Color(0xFF1A237E)),
              title: const Text('Monster Map'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MonsterMapScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.radar, color: Color(0xFF1A237E)),
              title: const Text('Catch Monsters'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Color(0xFF1A237E)),
              title: const Text('Top Monster Hunters'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud, color: Color(0xFF1A237E)),
              title: const Text('EC2 Control'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.grey),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: _screens[_currentIndex],

      // ── FAB (Add Monster shortcut on Monsters tab) ────────────────────
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1A237E),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Monster',
                  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddMonsterScreen()),
                );
                if (created == true) setState(() {});
              },
            )
          : null,

      // ── Bottom Navigation Bar ─────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.catching_pokemon), label: 'Monsters'),
          BottomNavigationBarItem(
              icon: Icon(Icons.radar), label: 'Catch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.cloud), label: 'EC2'),
        ],
      ),
    );
  }
}
