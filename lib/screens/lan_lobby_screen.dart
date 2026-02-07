import 'dart:async';
import 'package:flutter/material.dart';
import '../network/lan_host.dart';
import '../network/lan_client.dart';
import '../network/lan_connection.dart';
import '../network/lan_protocol.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

class LanLobbyScreen extends StatefulWidget {
  const LanLobbyScreen({super.key});

  @override
  State<LanLobbyScreen> createState() => _LanLobbyScreenState();
}

class _LanLobbyScreenState extends State<LanLobbyScreen> {
  // ── State ──────────────────────────────────────────────────────────
  _LobbyState _state = _LobbyState.choosingRole;
  String _statusMessage = '';

  // Host state
  LanHost? _host;
  TimeControl _timeControl = TimeControl.none;

  // Client state
  LanClient? _client;
  final List<LanBeacon> _discoveredGames = [];
  final _ipController = TextEditingController();
  bool _isConnecting = false;

  @override
  void dispose() {
    _host?.dispose();
    _client?.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // ── Host Flow ──────────────────────────────────────────────────────

  Future<void> _startHosting() async {
    setState(() {
      _state = _LobbyState.hosting;
      _statusMessage = 'Starting server...';
    });

    try {
      _host = LanHost(
        hostName: 'Pente Game',
        timeControl: _timeControl,
      );
      await _host!.startHosting();

      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Waiting for opponent...\nYour IP: ${_host!.localIp ?? 'unknown'}';
      });

      // Wait for a client to join
      _host!.onClientJoined.listen((connection) {
        if (!mounted) return;
        _startLanGame(
          connection: connection,
          localPlayer: StoneType.player1,
        );
      });
    } catch (e) {
      if (!mounted) return;
      final errMsg = e.toString();
      String userMessage;
      if (errMsg.contains('Operation not permitted') ||
          errMsg.contains('Permission denied')) {
        userMessage =
            'Network permission denied.\nPlease reinstall the app to grant network permissions.';
      } else if (errMsg.contains('Address already in use')) {
        userMessage = 'Port already in use. Another game may be running.';
      } else {
        userMessage = 'Failed to start server:\n$errMsg';
      }
      setState(() {
        _statusMessage = userMessage;
        _state = _LobbyState.choosingRole;
      });
    }
  }

  // ── Join Flow ──────────────────────────────────────────────────────

  bool _discoveryFailed = false;

  Future<void> _startDiscovery() async {
    setState(() {
      _state = _LobbyState.joining;
      _statusMessage = 'Searching for games...';
      _discoveredGames.clear();
      _discoveryFailed = false;
    });

    try {
      _client = LanClient();
      await _client!.startDiscovery();

      _client!.discoveredGames.listen((beacon) {
        if (!mounted) return;
        setState(() {
          // Update or add beacon (no duplicates by IP+port)
          _discoveredGames.removeWhere((b) => b == beacon);
          _discoveredGames.add(beacon);
        });
      });
    } catch (e) {
      // UDP discovery failed (common on Android) — fall back to manual IP
      if (!mounted) return;
      _client = LanClient(); // keep client for joinByIp()
      setState(() {
        _discoveryFailed = true;
        _statusMessage =
            'Auto-discovery unavailable.\nUse the IP address shown on the host device to connect.';
      });
    }
  }

  Future<void> _joinGame(LanBeacon beacon) async {
    if (_isConnecting) return;
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting to ${beacon.hostName}...';
    });

    try {
      final connection = await _client!.joinGame(beacon);
      if (!mounted) return;
      _startLanGame(
        connection: connection,
        localPlayer: StoneType.player2,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _statusMessage = 'Connection failed: $e';
      });
    }
  }

  Future<void> _joinByIp() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting to $ip...';
    });

    try {
      _client ??= LanClient();
      final connection = await _client!.joinByIp(ip);
      if (!mounted) return;
      _startLanGame(
        connection: connection,
        localPlayer: StoneType.player2,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _statusMessage = 'Connection failed: $e';
      });
    }
  }

  // ── Launch Game ────────────────────────────────────────────────────

  void _startLanGame({
    required LanGameConnection connection,
    required StoneType localPlayer,
  }) {
    connection.startHeartbeat();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          difficulty: AIDifficulty.medium, // unused in LAN mode
          mode: GameMode.lan,
          timeControl: _timeControl,
          lanConnection: connection,
          localPlayer: localPlayer,
        ),
      ),
    );
  }

  void _goBack() {
    if (_state == _LobbyState.choosingRole) {
      Navigator.pop(context);
    } else {
      _host?.dispose();
      _host = null;
      _client?.dispose();
      _client = null;
      setState(() {
        _state = _LobbyState.choosingRole;
        _statusMessage = '';
        _discoveredGames.clear();
        _isConnecting = false;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: NeonTheme.darkerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NeonTheme.neonCyan),
          onPressed: _goBack,
        ),
        title: Text(
          'LAN PLAY',
          style: TextStyle(
            color: NeonTheme.neonBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: switch (_state) {
              _LobbyState.choosingRole => _buildRoleChooser(),
              _LobbyState.hosting => _buildHostWaiting(),
              _LobbyState.joining => _buildJoinBrowser(),
            },
          ),
        ),
      ),
    );
  }

  // ── Role Chooser ──────────────────────────────────────────────────

  Widget _buildRoleChooser() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.wifi, color: NeonTheme.neonBlue, size: 48),
          const SizedBox(height: 16),
          Text(
            'LOCAL NETWORK PLAY',
            style: TextStyle(
              color: NeonTheme.neonBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play against a friend on the same WiFi network',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NeonTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 40),

          // Time control selector for host
          _buildTimeControlSection(),
          const SizedBox(height: 32),

          // HOST button
          _buildBigButton(
            label: 'HOST GAME',
            subtitle: 'Create a game and wait for opponent',
            icon: Icons.dns,
            color: NeonTheme.neonGreen,
            onTap: _startHosting,
          ),
          const SizedBox(height: 16),

          // JOIN button
          _buildBigButton(
            label: 'JOIN GAME',
            subtitle: 'Find and join a game on your network',
            icon: Icons.search,
            color: NeonTheme.neonCyan,
            onTap: _startDiscovery,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer, color: NeonTheme.textSecondary, size: 14),
            const SizedBox(width: 6),
            Text(
              'TIME CONTROL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: NeonTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TimeControl.values.map((tc) {
            final isSelected = _timeControl == tc;
            final color = tc == TimeControl.none
                ? NeonTheme.textSecondary
                : NeonTheme.neonYellow;
            final label = switch (tc) {
              TimeControl.none => 'Unlimited',
              TimeControl.min5 => '5 min',
              TimeControl.min10 => '10 min',
              TimeControl.min15 => '15 min',
              TimeControl.min30 => '30 min',
              TimeControl.min60 => '60 min',
            };
            return GestureDetector(
              onTap: () => setState(() => _timeControl = tc),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(20) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color.withAlpha(180)
                        : NeonTheme.textSecondary.withAlpha(40),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? color : NeonTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBigButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100)),
          boxShadow: [NeonTheme.neonGlow(color, blur: 8, spread: 0)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: NeonTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withAlpha(150)),
          ],
        ),
      ),
    );
  }

  // ── Host Waiting Screen ───────────────────────────────────────────

  Widget _buildHostWaiting() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated pulsing icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Icon(
                Icons.wifi_tethering,
                color: NeonTheme.neonGreen.withAlpha((255 * value).round()),
                size: 64,
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'HOSTING GAME',
            style: TextStyle(
              color: NeonTheme.neonGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          if (_host?.localIp != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: NeonTheme.cardBg,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: NeonTheme.neonGreen.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lan, color: NeonTheme.neonGreen, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _host!.localIp!,
                    style: TextStyle(
                      color: NeonTheme.neonGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share this IP with your opponent',
              style: TextStyle(
                color: NeonTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(NeonTheme.neonGreen),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Waiting for opponent to connect...',
            style: TextStyle(
              color: NeonTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: _goBack,
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: NeonTheme.neonRed,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Join Browser ──────────────────────────────────────────────────

  Widget _buildJoinBrowser() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.search, color: NeonTheme.neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'AVAILABLE GAMES',
                style: TextStyle(
                  color: NeonTheme.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              if (!_isConnecting)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(NeonTheme.neonCyan),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Discovered games list
          if (!_discoveryFailed) ...[
            if (_discoveredGames.isEmpty && !_isConnecting)
              _buildEmptyDiscovery()
            else
              ...(_discoveredGames.map(_buildGameTile)),
            const SizedBox(height: 24),
            Divider(color: NeonTheme.textSecondary.withAlpha(40)),
          ],

          const SizedBox(height: 16),
          Text(
            _discoveryFailed ? 'CONNECT BY IP' : 'OR CONNECT BY IP',
            style: TextStyle(
              color: NeonTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  style: TextStyle(
                    color: NeonTheme.textPrimary,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: '192.168.1.xxx',
                    hintStyle: TextStyle(
                        color: NeonTheme.textSecondary.withAlpha(80)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: NeonTheme.neonCyan.withAlpha(60)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: NeonTheme.neonCyan),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _joinByIp(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isConnecting ? null : _joinByIp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeonTheme.neonCyan.withAlpha(30),
                  foregroundColor: NeonTheme.neonCyan,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: NeonTheme.neonCyan.withAlpha(100)),
                  ),
                ),
                child: const Text('CONNECT'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status message
          if (_statusMessage.isNotEmpty)
            Text(
              _statusMessage,
              style: TextStyle(
                color: _isConnecting
                    ? NeonTheme.neonCyan
                    : NeonTheme.neonOrange,
                fontSize: 12,
              ),
            ),

          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _goBack,
              child: Text(
                'BACK',
                style: TextStyle(
                  color: NeonTheme.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDiscovery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NeonTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NeonTheme.textSecondary.withAlpha(20)),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_find,
              color: NeonTheme.textSecondary.withAlpha(80), size: 32),
          const SizedBox(height: 8),
          Text(
            'Searching for games...',
            style: TextStyle(
              color: NeonTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Make sure the host is on the same WiFi network',
            style: TextStyle(
              color: NeonTheme.textSecondary.withAlpha(120),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTile(LanBeacon beacon) {
    return GestureDetector(
      onTap: _isConnecting ? null : () => _joinGame(beacon),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: NeonTheme.neonCyan.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NeonTheme.neonCyan.withAlpha(80)),
        ),
        child: Row(
          children: [
            Icon(Icons.sports_esports,
                color: NeonTheme.neonCyan, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beacon.hostName,
                    style: TextStyle(
                      color: NeonTheme.neonCyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    beacon.hostIp,
                    style: TextStyle(
                      color: NeonTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow,
                color: NeonTheme.neonGreen, size: 24),
          ],
        ),
      ),
    );
  }
}

enum _LobbyState { choosingRole, hosting, joining }
