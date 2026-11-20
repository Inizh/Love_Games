import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../chat/chat_client.dart';
import '../chat/chat_config.dart';
import '../chat/chat_protocol.dart';
import '../theme/love_colors.dart';
import '../widgets/love_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.client});

  /// Optional client so tests can substitute a fake. Production uses a real socket.
  final ChatClient? client;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatClient _client = widget.client ?? ChatClient();
  final _nameController = TextEditingController();
  final _serverController = TextEditingController();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  bool _joining = true;
  bool _busy = false;
  bool _canSend = false;
  String _userName = 'You';
  String _status = '';
  String _loginStatus = '';
  final List<_Entry> _messages = [];
  var _serverReady = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final canSend = _messageController.text.trim().isNotEmpty;
      if (canSend != _canSend && mounted) {
        setState(() => _canSend = canSend);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_serverReady) {
      return;
    }
    _serverReady = true;
    _serverController.text = ChatConfigScope.of(context).server;
  }

  @override
  void dispose() {
    unawaited(_client.disconnect());
    _nameController.dispose();
    _serverController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _loginStatus = 'Please enter your name.');
      return;
    }
    final url = tryChatWebSocketUrl(_serverController.text, name);
    if (url == null) {
      setState(() => _loginStatus = 'Enter a server like 192.168.1.20:8080.');
      return;
    }

    setState(() {
      _busy = true;
      _userName = name;
      _loginStatus = 'Connecting…';
    });

    final connected = await _client.connect(
      url: url,
      connectedStatus: 'Connected as $name',
      onMessage: _handleIncoming,
      onStatus: _handleStatus,
      onError: _handleError,
    );
    if (!mounted) {
      return;
    }

    if (connected) {
      await ChatConfigScope.of(context).save(_serverController.text);
      if (!mounted) {
        return;
      }
      _serverController.text = ChatConfigScope.of(context).server;
      setState(() {
        _busy = false;
        _joining = false;
        _messages
          ..clear()
          ..add(const _Entry.system('Connected. Say hi to the room!'));
      });
      _scrollToEnd();
    } else {
      setState(() => _busy = false);
    }
  }

  void _handleStatus(String status) {
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
      _loginStatus = status;
    });
  }

  void _handleError(Object error) {
    if (!mounted) {
      return;
    }
    setState(() {
      _loginStatus = 'Could not connect: $error';
    });
  }

  void _handleIncoming(String raw) {
    if (!mounted) {
      return;
    }
    final incoming = IncomingMessage.parse(raw, _userName);
    switch (incoming.kind) {
      case IncomingKind.echo:
        return;
      case IncomingKind.system:
        _add(_Entry.system(incoming.text));
      case IncomingKind.received:
        final payload = splitChatPayload(incoming.text);
        _add(_Entry.received(sender: payload.sender, text: payload.body));
    }
  }

  void _add(_Entry entry) {
    setState(() => _messages.add(entry));
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    if (!_client.isConnected) {
      _add(const _Entry.system('Not connected. Go back and reconnect.'));
      return;
    }
    if (text.toLowerCase() == 'exit') {
      _leave();
      return;
    }
    _client.send('$_userName: $text');
    _messageController.clear();
    _add(_Entry.sent(text));
  }

  Future<void> _disconnectOnly() async {
    await _client.disconnect(onStatus: _handleStatus);
    if (!mounted) {
      return;
    }
    setState(() {
      _joining = true;
      _loginStatus = 'Disconnected. Enter your name to rejoin.';
      _status = 'Disconnected';
    });
  }

  void _leave() {
    unawaited(_client.disconnect());
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoveBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _joining
            ? AppBar(title: const Text('Chat'))
            : AppBar(
                toolbarHeight: 72,
                title: _ChatTitle(name: _userName, status: _status),
                actions: [
                  IconButton(
                    tooltip: 'Disconnect',
                    onPressed: _disconnectOnly,
                    icon: const Icon(Icons.link_off_rounded),
                  ),
                ],
              ),
        body: SafeArea(
          top: false,
          child: _joining ? _buildJoin() : _buildRoom(),
        ),
      ),
    );
  }

  Widget _buildJoin() {
    final presence = presenceFor(_loginStatus);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: LoveColors.shadow,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  const Icon(
                    Icons.chat_bubble_rounded,
                    color: LoveColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join the chat',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Message the Love Games room. The server listens on port 8080.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: LoveColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('chat-name'),
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      hintText: 'Your display name',
                    ),
                    onSubmitted: (_) => _connect(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('chat-server'),
                    controller: _serverController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Server',
                      hintText: 'localhost:8080',
                    ),
                    onSubmitted: (_) => _connect(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "On a phone, use your computer's IP address. Android emulator: 10.0.2.2:8080.",
                    style: TextStyle(
                      fontSize: 12,
                      color: LoveColors.muted,
                      height: 1.35,
                    ),
                  ),
                  if (_loginStatus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _loginStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            _loginStatus.startsWith('Please') ||
                                _loginStatus.startsWith('Enter a server')
                            ? LoveColors.danger
                            : _statusColor(presence),
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('chat-connect'),
                      onPressed: _busy ? null : _connect,
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Connect'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoom() {
    final enabled = presenceFor(_status) == ChatPresence.online;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _Bubble(entry: _messages[index]),
          ),
        ),
        Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('chat-message'),
                    controller: _messageController,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Message'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const Key('chat-send'),
                  tooltip: 'Send',
                  onPressed: enabled && _canSend ? _send : null,
                  style: IconButton.styleFrom(
                    backgroundColor: LoveColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: LoveColors.primary.withValues(
                      alpha: 0.35,
                    ),
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatTitle extends StatelessWidget {
  const _ChatTitle({required this.name, required this.status});

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    final presence = presenceFor(status);
    final label = status.isEmpty ? 'Offline' : status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LoveColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _statusColor(presence),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: LoveColors.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Color _statusColor(ChatPresence presence) {
  return switch (presence) {
    ChatPresence.online => LoveColors.success,
    ChatPresence.connecting => LoveColors.warning,
    ChatPresence.error => LoveColors.danger,
    ChatPresence.offline => LoveColors.offline,
  };
}

enum _Kind { sent, received, system }

class _Entry {
  const _Entry.sent(this.text) : kind = _Kind.sent, sender = null;

  const _Entry.received({required this.sender, required this.text})
    : kind = _Kind.received;

  const _Entry.system(this.text) : kind = _Kind.system, sender = null;

  final _Kind kind;
  final String? sender;
  final String text;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (entry.kind == _Kind.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width * 0.9),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: LoveColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Text(
                  entry.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: LoveColors.muted),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final sent = entry.kind == _Kind.sent;
    return Align(
      alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width * 0.78),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: sent ? LoveColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(sent ? 18 : 4),
                bottomRight: Radius.circular(sent ? 4 : 18),
              ),
              border: sent ? null : Border.all(color: LoveColors.fieldBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!sent && entry.sender != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        entry.sender!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: LoveColors.primary,
                        ),
                      ),
                    ),
                  Text(
                    entry.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: sent ? Colors.white : LoveColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
