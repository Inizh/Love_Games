import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'chat/chat_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await ChatConfig.load(
    persist: (server) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ChatConfig.storageKey, server);
    },
  );
  runApp(LoveGamesApp(config: config));
}
