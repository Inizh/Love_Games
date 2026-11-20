import 'package:flutter_test/flutter_test.dart';
import 'package:loves_games/chat/chat_protocol.dart';

void main() {
  test('builds the JavaFX websocket url', () {
    expect(
      tryChatWebSocketUrl('localhost:8080', 'Ann Marie'),
      'ws://localhost:8080/ws/Ann_Marie',
    );
    expect(
      tryChatWebSocketUrl('http://10.0.2.2:8080/ws/ignored', 'Ann'),
      'ws://10.0.2.2:8080/ws/Ann',
    );
    expect(tryChatWebSocketUrl('10.0.2.2', 'Ann'), 'ws://10.0.2.2:8080/ws/Ann');
    expect(tryChatWebSocketUrl('   ', ''), 'ws://localhost:8080/ws/guest');
    expect(tryChatWebSocketUrl(':::', 'Ann'), isNull);
  });

  test('classifies room messages the way the desktop client does', () {
    expect(
      IncomingMessage.parse('Message received: Ann: hi', 'Ann').kind,
      IncomingKind.echo,
    );
    final received = IncomingMessage.parse('Message received: Bob: hi', 'Ann');
    expect(received.kind, IncomingKind.received);
    expect(received.text, 'Bob: hi');

    final notice = IncomingMessage.parse(
      'Message received: Client Bob disconnected',
      'Ann',
    );
    expect(notice.kind, IncomingKind.system);
    expect(notice.text, 'Message received: Client Bob disconnected');
  });

  test('splits a sender prefix off a received payload', () {
    final named = splitChatPayload('Bob: hi there');
    expect(named.sender, 'Bob');
    expect(named.body, 'hi there');
    expect(splitChatPayload('hello').sender, isNull);
    expect(splitChatPayload('hello').body, 'hello');
  });

  test('maps status text onto the presence dot', () {
    expect(presenceFor('Connected as Ann'), ChatPresence.online);
    expect(presenceFor('Connecting…'), ChatPresence.connecting);
    expect(
      presenceFor('Connection failed — is the chat server running?'),
      ChatPresence.error,
    );
    expect(presenceFor('Disconnected'), ChatPresence.error);
    expect(presenceFor('Connection error: reset'), ChatPresence.error);
    expect(presenceFor('Offline'), ChatPresence.offline);
  });
}
