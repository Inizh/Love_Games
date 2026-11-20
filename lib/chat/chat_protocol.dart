/// WebSocket address and message rules shared with the JavaFX chat client.
library;

const defaultChatServer = 'localhost:8080';

enum IncomingKind { echo, system, received }

class IncomingMessage {
  const IncomingMessage(this.kind, this.text);

  final IncomingKind kind;
  final String text;

  /// Mirrors [ChatController.handleIncoming] in the JavaFX app.
  static IncomingMessage parse(String raw, String userName) {
    var payload = raw;
    const receivedPrefix = 'Message received: ';
    if (raw.startsWith(receivedPrefix)) {
      payload = raw.substring(receivedPrefix.length);
    }

    if (payload.startsWith('$userName: ')) {
      return const IncomingMessage(IncomingKind.echo, '');
    }

    if (raw.toLowerCase().contains('disconnected')) {
      return IncomingMessage(IncomingKind.system, raw);
    }

    return IncomingMessage(IncomingKind.received, payload);
  }
}

class ChatPayload {
  const ChatPayload({required this.sender, required this.body});

  final String? sender;
  final String body;
}

ChatPayload splitChatPayload(String payload) {
  final index = payload.indexOf(': ');
  if (index <= 0) {
    return ChatPayload(sender: null, body: payload);
  }
  final body = payload.substring(index + 2);
  if (body.isEmpty) {
    return ChatPayload(sender: null, body: payload);
  }
  return ChatPayload(sender: payload.substring(0, index), body: body);
}

/// Turns a typed host into `host:port`, stripping a scheme or path.
String normalizeServer(String input) {
  var value = input.trim();
  if (value.isEmpty) {
    return defaultChatServer;
  }
  value = value.replaceFirst(
    RegExp(r'^(?:ws|wss|http|https)://', caseSensitive: false),
    '',
  );
  final slash = value.indexOf('/');
  if (slash >= 0) {
    value = value.substring(0, slash);
  }
  if (!value.contains(':')) {
    value = '$value:8080';
  }
  return value;
}

final RegExp _hostPort = RegExp(r'^[^/\s]+:\d+$');

/// `ws://host:port/ws/{name}` with spaces in the name folded to underscores.
String? tryChatWebSocketUrl(String server, String displayName) {
  final host = normalizeServer(server);
  if (!_hostPort.hasMatch(host)) {
    return null;
  }
  final safe = displayName.trim().replaceAll(RegExp(r'\s+'), '_');
  final name = safe.isEmpty ? 'guest' : safe;
  return 'ws://$host/ws/${Uri.encodeComponent(name)}';
}

enum ChatPresence { offline, connecting, online, error }

ChatPresence presenceFor(String status) {
  final lower = status.toLowerCase();
  if (lower.contains('fail') ||
      lower.contains('error') ||
      lower == 'disconnected') {
    return ChatPresence.error;
  }
  if (lower.startsWith('connected')) {
    return ChatPresence.online;
  }
  if (lower.startsWith('connecting')) {
    return ChatPresence.connecting;
  }
  return ChatPresence.offline;
}
