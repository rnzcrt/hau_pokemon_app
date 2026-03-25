// lib/config/app_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// UPDATE baseUrl to your Tailscale IP after Phase 5 setup.
// The EC2 Lambda URLs come from Phase 8 (API Gateway Invoke URL).
// No Google Maps API key needed — app uses OpenStreetMap (free).
// ─────────────────────────────────────────────────────────────────────────────

class AppConfig {
  // Tailscale IP of the web server (update after Phase 5)
  static const String baseUrl = 'http://100.85.32.48/api/';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String registerUrl = '$baseUrl/auth/register.php';
  static const String loginUrl    = '$baseUrl/auth/login.php';

  // ── Monsters CRUD ─────────────────────────────────────────────────────────
  static const String monstersUrl   = '$baseUrl/monsters/read.php';
  static const String createMonster = '$baseUrl/monsters/create.php';
  static const String updateMonster = '$baseUrl/monsters/update.php';
  static const String deleteMonster = '$baseUrl/monsters/delete.php';

  // ── Catch ─────────────────────────────────────────────────────────────────
  static const String detectMonster = '$baseUrl/catches/detect.php';
  static const String catchMonster  = '$baseUrl/catches/catch.php';

  // ── Leaderboard ───────────────────────────────────────────────────────────
  static const String leaderboard = '$baseUrl/leaderboard/top10.php';

  // ── Lambda / EC2 (from API Gateway – update after Phase 8) ───────────────
  static const String ec2Status  =
      'https://hbwzb094n4.execute-api.eu-west-3.amazonaws.com/prod/ec2-status';
  static const String ec2Control =
      'https://hbwzb094n4.execute-api.eu-west-3.amazonaws.com/prod/stop-ec2';

  // ── Default spawn location (Holy Angel University, Angeles City) ──────────
  static const double defaultLat = 15.1636;
  static const double defaultLng = 120.5860;
}