import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../utils/constants.dart';
import 'lan_protocol.dart';
import 'lan_connection.dart';

/// Discovers LAN game hosts via UDP and connects to them via TCP.
class LanClient {
  final int udpPort;

  RawDatagramSocket? _udpSocket;
  bool _disposed = false;

  /// Stream of discovered game beacons (may emit duplicates).
  final _beaconController = StreamController<LanBeacon>.broadcast();
  Stream<LanBeacon> get discoveredGames => _beaconController.stream;

  LanClient({this.udpPort = Constants.lanUdpPort});

  /// Start listening for UDP beacon broadcasts from hosts.
  Future<void> startDiscovery() async {
    _udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      udpPort,
    );
    _udpSocket!.broadcastEnabled = true;
    _udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _udpSocket!.receive();
        if (datagram == null) return;
        try {
          final json =
              jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
          if (json['type'] == 'pente_lan_beacon') {
            _beaconController.add(LanBeacon.fromJson(json));
          }
        } catch (_) {
          // Ignore malformed packets
        }
      }
    });
  }

  /// Stop discovery (frees the UDP port).
  void stopDiscovery() {
    _udpSocket?.close();
    _udpSocket = null;
  }

  /// Connect to a discovered host and wait for the welcome message.
  /// Returns the [LanGameConnection] ready for gameplay.
  Future<LanGameConnection> joinGame(
    LanBeacon beacon, {
    String playerName = 'Player 2',
  }) async {
    stopDiscovery();

    final socket = await Socket.connect(
      beacon.hostIp,
      beacon.tcpPort,
      timeout: const Duration(seconds: 5),
    );

    final connection = LanGameConnection(socket);

    // Wait for welcome, then send join
    final completer = Completer<LanGameConnection>();
    late StreamSubscription<LanMessage> sub;
    sub = connection.messages.listen((msg) {
      if (msg.type == LanMessageType.welcome) {
        connection.send(LanMessage(
          type: LanMessageType.join,
          data: {'playerName': playerName},
        ));
        sub.cancel();
        completer.complete(connection);
      }
    });

    // Timeout if welcome is not received
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        sub.cancel();
        connection.close();
        throw TimeoutException('Host did not respond');
      },
    );
  }

  /// Connect directly by IP address (fallback when UDP discovery fails).
  Future<LanGameConnection> joinByIp(
    String ip, {
    int port = Constants.lanTcpPort,
    String playerName = 'Player 2',
  }) async {
    final beacon = LanBeacon(
      hostName: ip,
      hostIp: ip,
      tcpPort: port,
      version: Constants.lanProtocolVersion,
    );
    return joinGame(beacon, playerName: playerName);
  }

  /// Clean up all resources.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    stopDiscovery();
    if (!_beaconController.isClosed) {
      await _beaconController.close();
    }
  }
}
