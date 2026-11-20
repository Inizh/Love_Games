import 'package:flutter/material.dart';

import '../chat/chat_client.dart';
import '../theme/love_colors.dart';
import '../widgets/love_background.dart';
import 'chat_screen.dart';
import 'flames_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.chatClient});

  final ChatClient? chatClient;

  @override
  Widget build(BuildContext context) {
    return LoveBackground(
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 36).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _Hero(),
                          const SizedBox(height: 32),
                          _GameCard(
                            key: const Key('open-flames'),
                            icon: Icons.local_fire_department_rounded,
                            iconColor: LoveColors.flame,
                            iconBackground: const Color(0xFFFFF0EC),
                            title: 'FLAMES',
                            description: "Discover if it's Friends, Love, Affection, Marriage, Enemy or Sister.",
                            onTap: () => _open(context, const FlamesScreen()),
                          ),
                          const SizedBox(height: 14),
                          _GameCard(
                            key: const Key('open-chat'),
                            icon: Icons.chat_bubble_rounded,
                            iconColor: LoveColors.primary,
                            iconBackground: const Color(0xFFF3F0FF),
                            title: 'Chat',
                            description: 'Connect to the live room and message other players in real time.',
                            onTap: () =>
                                _open(context, ChatScreen(client: chatClient)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: LoveColors.blush,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 88,
            height: 88,
            child: Icon(
              Icons.favorite_rounded,
              color: LoveColors.heart,
              size: 42,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Love Games',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Super-fast love games optimised to find your life partner',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: LoveColors.muted, height: 1.4),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: LoveColors.shadow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LoveColors.cardBorder),
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(icon, color: iconColor, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: LoveColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: LoveColors.offline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
