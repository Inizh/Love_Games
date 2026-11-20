import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_protocol.dart';

/// Remembers the chat server address between launches.
class ChatConfig {
  ChatConfig({this.server = defaultChatServer, this.persist});

  static const storageKey = 'chat_server';

  String server;
  final Future<void> Function(String server)? persist;

  static Future<ChatConfig> load({
    required Future<void> Function(String server) persist,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey)?.trim();
    return ChatConfig(
      server: (stored == null || stored.isEmpty) ? defaultChatServer : stored,
      persist: persist,
    );
  }

  Future<void> save(String value) async {
    server = normalizeServer(value);
    await persist?.call(server);
  }
}

class ChatConfigScope extends InheritedWidget {
  const ChatConfigScope({
    super.key,
    required this.config,
    required super.child,
  });

  final ChatConfig config;

  static ChatConfig of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ChatConfigScope>();
    assert(scope != null, 'ChatConfigScope is missing above this widget');
    return scope!.config;
  }

  @override
  bool updateShouldNotify(ChatConfigScope oldWidget) =>
      oldWidget.config != config;
}
