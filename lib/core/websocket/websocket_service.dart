import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/models/robot_commands.dart';

enum WebSocketStatus { disconnected, connecting, connected, error }

class WebSocketState {
  final WebSocketStatus status;
  final int latencyMs;
  final int messagesSent;
  final int messagesReceived;

  WebSocketState({
    this.status = WebSocketStatus.disconnected,
    this.latencyMs = 0,
    this.messagesSent = 0,
    this.messagesReceived = 0,
  });

  WebSocketState copyWith({
    WebSocketStatus? status,
    int? latencyMs,
    int? messagesSent,
    int? messagesReceived,
  }) {
    return WebSocketState(
      status: status ?? this.status,
      latencyMs: latencyMs ?? this.latencyMs,
      messagesSent: messagesSent ?? this.messagesSent,
      messagesReceived: messagesReceived ?? this.messagesReceived,
    );
  }
}

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  WebSocketNotifier() : super(WebSocketState());

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  DateTime? _lastPingTime;
  
  Function(Map<String, dynamic>)? onMessageReceived;
  
  final String _url = 'ws://192.168.4.1:81';

  void connect() {
    if (state.status == WebSocketStatus.connected) return;
    
    state = state.copyWith(status: WebSocketStatus.connecting);
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      
      _channel!.stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onDone: () => _handleDisconnect(),
        onError: (error) => _handleError(error),
        cancelOnError: true,
      );
      
      state = state.copyWith(status: WebSocketStatus.connected);
      _startHeartbeat();
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleIncomingMessage(dynamic message) {
    state = state.copyWith(messagesReceived: state.messagesReceived + 1);
    
    try {
      final data = jsonDecode(message as String);
      
      if (data['type'] == 'pong' && _lastPingTime != null) {
        final latency = DateTime.now().difference(_lastPingTime!).inMilliseconds;
        state = state.copyWith(latencyMs: latency);
      }
      
      onMessageReceived?.call(data);
      
    } catch (_) {
      // Ignorar mensajes malformados
    }
  }

  void sendCommand(RobotCommand command) {
    if (_channel != null && state.status == WebSocketStatus.connected) {
      final jsonStr = jsonEncode(command.toJson());
      _channel!.sink.add(jsonStr);
      state = state.copyWith(messagesSent: state.messagesSent + 1);
    }
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state.status == WebSocketStatus.connected) {
        _lastPingTime = DateTime.now();
        _channel?.sink.add(jsonEncode({"type": "ping"}));
      }
    });
  }

  void _handleDisconnect() {
    state = state.copyWith(status: WebSocketStatus.disconnected);
    _cleanup();
    _scheduleReconnect();
  }

  void _handleError(dynamic error) {
    state = state.copyWith(status: WebSocketStatus.error);
    _cleanup();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), connect);
  }

  void _cleanup() {
    _pingTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _cleanup();
    state = state.copyWith(status: WebSocketStatus.disconnected);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

final webSocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
  return WebSocketNotifier();
});