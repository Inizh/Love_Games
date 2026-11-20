import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:loves_games/chat/chat_client.dart';

void main() {
  test('sends text and reads the server broadcast', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen((data) {
        socket.add('Message received: $data');
      });
    });
    addTearDown(() => server.close(force: true));

    final client = ChatClient();
    final incoming = Completer<String>();
    final statuses = <String>[];
    final connected = await client.connect(
      url: 'ws://127.0.0.1:${server.port}/ws/Ann',
      connectedStatus: 'Connected as Ann',
      onMessage: (message) {
        if (!incoming.isCompleted) {
          incoming.complete(message);
        }
      },
      onStatus: statuses.add,
      onError: (error) => fail('$error'),
    );

    expect(connected, isTrue);
    expect(client.isConnected, isTrue);
    expect(statuses, contains('Connected as Ann'));
    expect(client.send('Ann: hi'), isTrue);
    expect(
      await incoming.future.timeout(const Duration(seconds: 2)),
      'Message received: Ann: hi',
    );

    await client.disconnect();
    expect(client.isConnected, isFalse);
  });
}
