import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loves_games/app.dart';
import 'package:loves_games/chat/chat_client.dart';
import 'package:loves_games/chat/chat_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(
    WidgetTester tester, {
    ChatClient? chatClient,
    Size size = const Size(390, 844),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      LoveGamesApp(config: ChatConfig(), chatClient: chatClient),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home leads into FLAMES and shows affection', (tester) async {
    await pumpApp(tester);

    expect(find.text('Love Games'), findsOneWidget);
    expect(
      find.text('Super-fast love games optimised to find your life partner'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('open-flames')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('her-name')), 'Nayanthara');
    await tester.enterText(find.byKey(const Key('his-name')), 'Vignesh');
    await tester.tap(find.byKey(const Key('calculate')));
    await tester.pumpAndSettle();

    expect(find.text('AFFECTION'), findsOneWidget);
    expect(find.text('Nayanthara  ×  Vignesh'), findsOneWidget);
    expect(
      find.text("There's a soft affection drawing you closer."),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('clear')));
    await tester.pumpAndSettle();
    expect(find.text('AFFECTION'), findsNothing);
    expect(
      find.text('Enter two names and discover your fate.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('calculate')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter both names.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Love Games'), findsOneWidget);
  });

  testWidgets('FLAMES fits a small phone', (tester) async {
    await pumpApp(tester, size: const Size(320, 568));
    await tester.tap(find.byKey(const Key('open-flames')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('her-name')), 'AA');
    await tester.enterText(find.byKey(const Key('his-name')), 'A');
    await tester.ensureVisible(find.byKey(const Key('calculate')));
    await tester.tap(find.byKey(const Key('calculate')));
    await tester.pumpAndSettle();
    expect(find.text('SISTER'), findsOneWidget);
  });

  testWidgets('chat asks for a name before connecting', (tester) async {
    await pumpApp(tester, size: const Size(320, 640));
    await tester.tap(find.byKey(const Key('open-chat')));
    await tester.pumpAndSettle();

    expect(find.text('Join the chat'), findsOneWidget);
    expect(find.text('localhost:8080'), findsWidgets);

    await tester.tap(find.byKey(const Key('chat-connect')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('chat-name')), 'Priya');
    await tester.enterText(find.byKey(const Key('chat-server')), ':::');
    await tester.tap(find.byKey(const Key('chat-connect')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a server like 192.168.1.20:8080.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Love Games'), findsOneWidget);
  });

  testWidgets('chat room shows sent, received, and system messages', (
    tester,
  ) async {
    final room = ScriptedChatClient();
    await pumpApp(tester, chatClient: room);

    await tester.tap(find.byKey(const Key('open-chat')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('chat-name')), 'Priya');
    await tester.tap(find.byKey(const Key('chat-connect')));
    await tester.pumpAndSettle();

    expect(find.text('Connected. Say hi to the room!'), findsOneWidget);
    expect(find.text('Connected as Priya'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('chat-message')), 'hello');
    await tester.pump();
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(room.sent, ['Priya: hello']);
    expect(find.text('hello'), findsOneWidget);

    room.emit('Message received: Priya: hello');
    room.emit('Message received: Alex: hi there');
    room.emit('Client Alex disconnected');
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('hi there'), findsOneWidget);
    expect(find.text('Client Alex disconnected'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('chat-message')), 'exit');
    await tester.pump();
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();
    expect(find.text('Love Games'), findsOneWidget);
    expect(room.disconnects, greaterThanOrEqualTo(1));
  });
}

class ScriptedChatClient extends ChatClient {
  void Function(String message)? _onMessage;
  final sent = <String>[];
  var online = false;
  var disconnects = 0;

  void emit(String message) => _onMessage?.call(message);

  @override
  bool get isConnected => online;

  @override
  Future<bool> connect({
    required String url,
    required String connectedStatus,
    required void Function(String message) onMessage,
    required void Function(String status) onStatus,
    required void Function(Object error) onError,
  }) async {
    online = true;
    _onMessage = onMessage;
    onStatus(connectedStatus);
    return true;
  }

  @override
  bool send(String message) {
    sent.add(message);
    return true;
  }

  @override
  Future<void> disconnect({void Function(String status)? onStatus}) async {
    disconnects += 1;
    online = false;
    onStatus?.call('Disconnected');
  }
}
