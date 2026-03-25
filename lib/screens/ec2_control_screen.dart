// lib/screens/ec2_control_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class EC2ControlScreen extends StatefulWidget {
  const EC2ControlScreen({super.key});
  @override
  State<EC2ControlScreen> createState() => _EC2ControlScreenState();
}

class _EC2ControlScreenState extends State<EC2ControlScreen> {
  String _state      = 'unknown';
  String _publicIp   = 'N/A';
  String _privateIp  = 'N/A';
  bool   _loading    = false;
  Timer? _timer;
  String _lastUpdated = 'Never';

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Auto-refresh every 30 s
    _timer = Timer.periodic(
        const Duration(seconds: 30), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await http
          .get(Uri.parse(AppConfig.ec2Status))
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      final now  = TimeOfDay.now();
      setState(() {
        _state      = data['state']      ?? 'unknown';
        _publicIp   = data['public_ip']  ?? 'N/A';
        _privateIp  = data['private_ip'] ?? 'N/A';
        _lastUpdated = '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}';
      });
    } catch (_) {
      setState(() => _state = 'error');
    }
  }

  Future<void> _control(String action) async {
    setState(() => _loading = true);
    try {
      await http.post(
        Uri.parse(AppConfig.ec2Control),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
      // Wait briefly for AWS to register the state change
      await Future.delayed(const Duration(seconds: 3));
      await _fetchStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(action == 'start'
              ? '▶️ Start command sent'
              : '⏹️ Stop command sent'),
          backgroundColor:
              action == 'start' ? Colors.green : Colors.red,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Command failed. Check VPN.')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Color get _stateColor {
    switch (_state) {
      case 'running':  return Colors.green;
      case 'stopped':  return Colors.red;
      case 'stopping': return Colors.orange;
      case 'pending':  return Colors.orange;
      case 'error':    return Colors.grey;
      default:         return Colors.grey;
    }
  }

  IconData get _stateIcon {
    switch (_state) {
      case 'running':  return Icons.check_circle;
      case 'stopped':  return Icons.cancel;
      case 'stopping': return Icons.pending;
      case 'pending':  return Icons.pending;
      default:         return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Server Status Card ───────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Cloud icon with state color
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Icon(Icons.dns_rounded,
                          size: 72, color: const Color(0xFF1A237E)),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(_stateIcon,
                            color: _stateColor, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Web Server (Paris)',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('AWS EC2 · eu-west-3',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 14),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: _stateColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: _stateColor.withOpacity(0.6),
                          width: 1.5),
                    ),
                    child: Text(
                      _state.toUpperCase(),
                      style: TextStyle(
                          color: _stateColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // IP details
                  _infoRow(Icons.public, 'Public IP', _publicIp),
                  const SizedBox(height: 4),
                  _infoRow(Icons.vpn_key, 'Private IP', _privateIp),
                  const SizedBox(height: 4),
                  _infoRow(Icons.schedule, 'Last updated', _lastUpdated),
                  const SizedBox(height: 20),

                  // START / STOP buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        label: 'START',
                        icon: Icons.play_arrow,
                        color: Colors.green,
                        onPressed: (_loading ||
                                _state == 'running' ||
                                _state == 'pending')
                            ? null
                            : () => _control('start'),
                      ),
                      _actionButton(
                        label: 'STOP',
                        icon: Icons.stop,
                        color: Colors.red,
                        onPressed: (_loading ||
                                _state == 'stopped' ||
                                _state == 'stopping')
                            ? null
                            : () => _control('stop'),
                      ),
                    ],
                  ),

                  if (_loading) ...[
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(),
                  ],

                  const SizedBox(height: 14),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                    onPressed: _loading ? null : _fetchStatus,
                  ),
                  const Text('Auto-refreshes every 30 seconds',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Info box ─────────────────────────────────────────────────
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Text('How it works',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _infoText('START triggers a Lambda function that '
                      'calls ec2.start_instances() on AWS.'),
                  _infoText('STOP triggers ec2.stop_instances() '
                      'via the same Lambda.'),
                  _infoText('Status is fetched from a separate Lambda '
                      'via API Gateway.'),
                  _infoText(
                      'Stopping the EC2 will disconnect the app until restarted.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.3),
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text('$label: ',
            style:
                const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(color: Colors.blue, fontSize: 13)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.blueGrey))),
        ],
      ),
    );
  }
}
