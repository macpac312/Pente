import 'dart:convert';

/// Message types for the LAN game protocol.
enum LanMessageType {
  welcome,
  join,
  gameStart,
  move,
  moveAck,
  resign,
  rematchRequest,
  rematchAccept,
  ping,
  pong,
  error,
}

/// A single protocol message sent/received over the LAN connection.
class LanMessage {
  final LanMessageType type;
  final Map<String, dynamic> data;

  const LanMessage({required this.type, this.data = const {}});

  /// Serialize to a newline-terminated JSON string.
  String toLine() {
    return '${jsonEncode({'type': type.name, ...data})}\n';
  }

  /// Parse a single JSON line into a LanMessage.
  factory LanMessage.fromLine(String line) {
    final json = jsonDecode(line.trim()) as Map<String, dynamic>;
    final typeName = json.remove('type') as String;
    final type = LanMessageType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => LanMessageType.error,
    );
    return LanMessage(type: type, data: json);
  }
}

/// Beacon broadcast by the host for LAN discovery.
class LanBeacon {
  final String hostName;
  final String hostIp;
  final int tcpPort;
  final String version;

  const LanBeacon({
    required this.hostName,
    required this.hostIp,
    required this.tcpPort,
    required this.version,
  });

  Map<String, dynamic> toJson() => {
        'type': 'pente_lan_beacon',
        'version': version,
        'hostName': hostName,
        'hostIp': hostIp,
        'tcpPort': tcpPort,
      };

  String encode() => jsonEncode(toJson());

  factory LanBeacon.fromJson(Map<String, dynamic> json) {
    return LanBeacon(
      hostName: json['hostName'] as String? ?? 'Unknown',
      hostIp: json['hostIp'] as String? ?? '',
      tcpPort: json['tcpPort'] as int? ?? 0,
      version: json['version']?.toString() ?? '1',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LanBeacon && other.hostIp == hostIp && other.tcpPort == tcpPort;

  @override
  int get hashCode => hostIp.hashCode ^ tcpPort.hashCode;
}
