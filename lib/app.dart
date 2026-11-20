import 'package:flutter/material.dart';

import 'chat/chat_client.dart';
import 'chat/chat_config.dart';
import 'screens/home_screen.dart';
import 'theme/love_colors.dart';

class LoveGamesApp extends StatelessWidget {
  const LoveGamesApp({super.key, required this.config, this.chatClient});

  final ChatConfig config;

  /// When set, chat uses this client instead of opening a real socket.
  final ChatClient? chatClient;

  @override
  Widget build(BuildContext context) {
    return ChatConfigScope(
      config: config,
      child: MaterialApp(
        title: 'Love Games',
        debugShowCheckedModeBanner: false,
        theme: buildLoveTheme(),
        themeMode: ThemeMode.light,
        home: HomeScreen(chatClient: chatClient),
      ),
    );
  }
}
