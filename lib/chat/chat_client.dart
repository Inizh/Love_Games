import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket client for the FastAPI room at `/ws/{name}`.
class ChatClient {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _connected = false;
  int _attempt = 0;

  bool get isConnected => _connected;

  Future<bool> connect({
    required String url,
    required String connectedStatus,
    required void Function(String message) onMessage,
    required void Function(String status) onStatus,
    required void Function(Object error) onError,
  }) async {
    final attempt = ++_attempt;
    await _closeSocket();
    if (attempt != _attempt) {
      return false;
    }
    onStatus('Connecting…');

    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready.timeout(const Duration(seconds: 8));
      if (attempt != _attempt) {
        await channel.sink.close();
        return false;
      }
      _channel = channel;
      _connected = true;
      _subscription = channel.stream.listen(
        (event) {
          if (attempt == _attempt) {
            onMessage(event.toString());
          }
        },
        onError: (Object error) {
          if (attempt != _attempt) {
            return;
          }
          _connected = false;
          onError(error);
          onStatus('Connection error: $error');
        },
        onDone: () {
          if (attempt != _attempt) {
            return;
          }
          _connected = false;
          onStatus('Disconnected');
        },
        cancelOnError: true,
      );
      onStatus(connectedStatus);
      return true;
    } catch (error) {
      await channel?.sink.close();
      if (attempt != _attempt) {
        return false;
      }
      _connected = false;
      _channel = null;
      onError(error);
      onStatus('Connection failed — is the chat server running?');
      return false;
    }
  }

  bool send(String message) {
    final channel = _channel;
    if (!_connected || channel == null) {
      return false;
    }
    channel.sink.add(message);
    return true;
  }

  Future<void> disconnect({void Function(String status)? onStatus}) async {
    final hadSocket = _connected || _channel != null || _subscription != null;
    _attempt++;
    _connected = false;
    await _closeSocket();
    if (hadSocket) {
      onStatus?.call('Disconnected');
    }
  }

  Future<void> _closeSocket() async {
    final subscription = _subscription;
    final channel = _channel;
    _subscription = null;
    _channel = null;
    _connected = false;
    await subscription?.cancel();
    await channel?.sink.close();
  }
}
