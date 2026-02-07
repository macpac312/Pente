import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../utils/constants.dart';
import 'lan_protocol.dart';
import 'lan_connection.dart';

/// Hosts a LAN game by broadcasting a UDP beacon and accepting
/// one TCP client connection.
class LanHost {
  final String hostName;
  final int tcpPort;
  final int udpPort;
  final TimeControl timeControl;

  ServerSocket? _server;
  RawDatagramSocket? _udpSocket;
  Timer? _beaconTimer;
  LanGameConnection? _clientConnection;
  String? _localIp;
  bool _disposed = false;

  /// Fires when a client connects and sends a join message.
  final _clientJoinedController = StreamController<LanGameConnection>.broadcast();
  Stream<LanGameConnection> get onClientJoined => _clientJoinedController.stream;

  /// The currently connected client, if any.
  LanGameConnection? get client => _clientConnection;

  /// The local IP address of this host.
  String? get localIp => _localIp;

  LanHost({
    this.hostName = 'Pente Game',
    this.tcpPort = Constants.lanTcpPort,
    this.udpPort = Constants.lanUdpPort,
    this.timeControl = TimeControl.none,
  });

  /// Start hosting: bind TCP server and begin UDP beacon broadcast.
  /// TCP server is required; UDP beacon is best-effort (may fail on Android).
  Future<void> startHosting() async {
    _localIp = await _getLocalIp();

    // Bind TCP server (required)
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, tcpPort);
    _server!.listen(_onClientConnect);

    // Start UDP beacon (best-effort — may fail on some platforms)
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _udpSocket!.broadcastEnabled = true;
      _sendBeacon(); // send immediately
      _beaconTimer = Timer.periodic(
        const Duration(milliseconds: Constants.lanBeaconIntervalMs),
        (_) => _sendBeacon(),
      );
    } catch (_) {
      // UDP broadcast not available; clients must connect by IP
    }
  }

  /// Stop hosting and clean up server resources.
  /// Does NOT close the client connection — ownership is transferred to
  /// GameScreen via the onClientJoined stream.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _beaconTimer?.cancel();
    _udpSocket?.close();
    await _server?.close();
    if (!_clientJoinedController.isClosed) {
      await _clientJoinedController.close();
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────

  void _sendBeacon() {
    if (_disposed || _udpSocket == null || _localIp == null) return;
    final beacon = LanBeacon(
      hostName: hostName,
      hostIp: _localIp!,
      tcpPort: tcpPort,
      version: Constants.lanProtocolVersion,
    );
    final bytes = utf8.encode(beacon.encode());
    try {
      _udpSocket!.send(
        bytes,
        InternetAddress('255.255.255.255'),
        udpPort,
      );
    } catch (_) {
      // broadcast may fail on some networks
    }
  }

  void _onClientConnect(Socket clientSocket) {
    if (_disposed) {
      clientSocket.destroy();
      return;
    }

    // Only accept one client (2-player game)
    if (_clientConnection != null) {
      clientSocket.destroy();
      return;
    }

    // Stop broadcasting — game is full
    _beaconTimer?.cancel();

    _clientConnection = LanGameConnection(clientSocket);
    _clientConnection!.onDisconnect = () {
      _clientConnection = null;
    };

    // Send welcome
    _clientConnection!.send(LanMessage(
      type: LanMessageType.welcome,
      data: {
        'hostName': hostName,
        'version': Constants.lanProtocolVersion,
      },
    ));

    // Wait for join message, then notify
    late StreamSubscription<LanMessage> sub;
    sub = _clientConnection!.messages.listen((msg) {
      if (msg.type == LanMessageType.join) {
        sub.cancel();
        _clientJoinedController.add(_clientConnection!);
      }
    });
  }

  static Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
        includeLoopback: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return null;
  }
}
