import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'lan_protocol.dart';

/// Wraps a TCP [Socket] with newline-delimited JSON framing,
/// heartbeat keep-alive, and a typed message stream.
class LanGameConnection {
  final Socket _socket;
  final _messageController = StreamController<LanMessage>.broadcast();
  StringBuffer _buffer = StringBuffer();
  Timer? _heartbeat;
  Timer? _heartbeatTimeout;
  bool _closed = false;

  /// Called when the remote end disconnects or an error occurs.
  void Function()? onDisconnect;

  LanGameConnection(this._socket) {
    _socket.listen(
      _onData,
      onError: (_) => _handleDisconnect(),
      onDone: _handleDisconnect,
      cancelOnError: true,
    );
  }

  /// Incoming message stream.
  Stream<LanMessage> get messages => _messageController.stream;

  /// Remote address for display purposes.
  String get remoteAddress => _socket.remoteAddress.address;

  /// Send a typed message over the connection.
  void send(LanMessage message) {
    if (_closed) return;
    try {
      _socket.add(utf8.encode(message.toLine()));
    } catch (_) {
      _handleDisconnect();
    }
  }

  /// Start periodic heartbeat pings.
  void startHeartbeat({
    int intervalMs = 5000,
    int timeoutMs = 10000,
  }) {
    _heartbeat = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) {
        send(LanMessage(
          type: LanMessageType.ping,
          data: {'t': DateTime.now().millisecondsSinceEpoch},
        ));
        _resetHeartbeatTimeout(timeoutMs);
      },
    );
  }

  void _resetHeartbeatTimeout(int timeoutMs) {
    _heartbeatTimeout?.cancel();
    _heartbeatTimeout = Timer(Duration(milliseconds: timeoutMs), () {
      _handleDisconnect();
    });
  }

  /// Close the connection and clean up.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _heartbeat?.cancel();
    _heartbeatTimeout?.cancel();
    try {
      await _socket.close();
    } catch (_) {}
    if (!_messageController.isClosed) {
      await _messageController.close();
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────

  void _onData(dynamic data) {
    _buffer.write(utf8.decode(data as List<int>));
    final content = _buffer.toString();
    final lines = content.split('\n');

    // All complete lines except the last (which may be partial)
    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      try {
        final msg = LanMessage.fromLine(line);

        // Handle pong internally to reset timeout
        if (msg.type == LanMessageType.pong) {
          _heartbeatTimeout?.cancel();
          continue;
        }

        // Auto-reply to pings
        if (msg.type == LanMessageType.ping) {
          send(LanMessage(type: LanMessageType.pong, data: msg.data));
          continue;
        }

        _messageController.add(msg);
      } catch (_) {
        // Malformed message — skip
      }
    }

    // Keep the incomplete last fragment
    _buffer = StringBuffer(lines.last);
  }

  void _handleDisconnect() {
    if (_closed) return;
    _closed = true;
    _heartbeat?.cancel();
    _heartbeatTimeout?.cancel();
    try {
      _socket.destroy();
    } catch (_) {}
    if (!_messageController.isClosed) {
      _messageController.close();
    }
    onDisconnect?.call();
  }
}
