// lib/screens/about_us_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// RUBRIC NOTE: This screen is required for 10/10 on "UI/UX Design (incl. About Us)"
// Update the team member names, roles, and photos before submission.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const List<_TeamMember> _team = [
    _TeamMember(
      name: 'Member 1',               // ← Replace with real name
      role: 'AWS DB Infrastructure',
      sub: 'North Virginia – RDS MySQL, VPC, Subnets',
      emoji: '🗄️',
      color: Color(0xFF7B2D8B),
    ),
    _TeamMember(
      name: 'Member 2',               // ← Replace with real name
      role: 'AWS Web Server Infrastructure',
      sub: 'Paris – EC2, VPC, Load Balancer',
      emoji: '🖥️',
      color: Color(0xFF1565C0),
    ),
    _TeamMember(
      name: 'Member 3',               // ← Replace with real name
      role: 'Backend API Developer',
      sub: 'PHP 8.x REST API, Apache, Auth & Endpoints',
      emoji: '⚙️',
      color: Color(0xFF2E7D32),
    ),
    _TeamMember(
      name: 'Member 4',               // ← Replace with real name
      role: 'Mobile App – Auth & Monsters CRUD',
      sub: 'Flutter, Login/Register, Map, Add/Edit/Delete',
      emoji: '📱',
      color: Color(0xFFE65100),
    ),
    _TeamMember(
      name: 'Member 5',               // ← Replace with real name
      role: 'Mobile App – Catch & Leaderboard',
      sub: 'GPS Detect, Alarm, Catch, Top 10, EC2 Control',
      emoji: '🎮',
      color: Color(0xFFAD1457),
    ),
    _TeamMember(
      name: 'Member 6',               // ← Replace with real name
      role: 'IAM, VPN, Lambda & Documentation',
      sub: 'Tailscale, Lambda EC2 Start/Stop, Network Diagram',
      emoji: '🔐',
      color: Color(0xFF00695C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar with gradient ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), Color(0xFF7B1FA2)],
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Icon(Icons.catching_pokemon,
                          size: 64, color: Colors.white),
                      SizedBox(height: 8),
                      Text('HAUPokemon',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                      Text("Monster's App",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              title: const Text('About Us',
                  style: TextStyle(color: Colors.white)),
            ),
          ),

          // ── Project info ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.school,
                              color: Color(0xFF1A237E), size: 20),
                          SizedBox(width: 8),
                          Text('Project Information',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                      const Divider(height: 20),
                      _projectRow('University',
                          'Holy Angel University'),
                      _projectRow('School',   'School of Computing'),
                      _projectRow('Course',   '6CloudCom'),
                      _projectRow('Project',  'HAUPokemon Monster\'s App'),
                      _projectRow('AY',       '2025–2026'),
                      const SizedBox(height: 12),
                      // Tech stack chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          'AWS EC2', 'RDS MySQL', 'VPC Peering',
                          'Tailscale VPN', 'Lambda', 'Flutter', 'PHP API',
                          'Load Balancer',
                        ]
                            .map((t) => Chip(
                                  label: Text(t,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF1A237E))),
                                  backgroundColor: const Color(0xFF1A237E)
                                      .withOpacity(0.08),
                                  side: const BorderSide(
                                      color: Color(0xFF1A237E),
                                      width: 0.5),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Team Members heading ───────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Text('👥 Our Team',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // ── Team member cards ─────────────────────────────────────────
          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _MemberCard(member: _team[i]),
                childCount: _team.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _projectRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final _TeamMember member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: member.color.withOpacity(0.15),
          child: Text(member.emoji,
              style: const TextStyle(fontSize: 26)),
        ),
        title: Text(
          member.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: member.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(member.role,
                  style: TextStyle(
                      color: member.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 11)),
            ),
            const SizedBox(height: 4),
            Text(member.sub,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final String sub;
  final String emoji;
  final Color color;
  const _TeamMember({
    required this.name,
    required this.role,
    required this.sub,
    required this.emoji,
    required this.color,
  });
}
