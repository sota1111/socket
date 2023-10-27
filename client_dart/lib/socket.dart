import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket_log.dart';
import 'socket_config.dart';

final socketComProvider = StateNotifierProvider<SocketCom, void>((ref) {
  return SocketCom.instance;
});
class SocketCom extends StateNotifier {
  Socket? socket;
  LogManager? logManager;
  SocketCom._(this.logManager) : super(null);
  static final SocketCom _instance = SocketCom._(null);
  static SocketCom get instance => _instance;

  bool compInitComm = false;
  bool dialogIsShown = false;

  Future<void> socketConnect() async {
    final serverAddress = InternetAddress(socketConfig.address);
    final serverPort = socketConfig.port;

    try {
      socket = await Socket.connect(serverAddress, serverPort, timeout: Duration(milliseconds: socketConfig.connectionTimeout));
      debugPrint('socket connected');
      logManager?.logToFile('socket connected');
      socket!.listen((data) => _onDataReceived(),
        onDone: () {
          socket = null;
        },
      );
    } catch (e) {
      debugPrint('Connection Error: $e');
      logManager?.logToFile('Connection Error: $e');
    }
  }

  Future<void> socketSend(String message) async {
    final socket = this.socket;
    if (socket == null) {
      debugPrint('Socket is not connected.');
      logManager?.logToFile('Socket is not connected.');
      return;
    }
    logManager?.logToFile('Send Message: $message');
    debugPrint('Send Message: $message');
    socket.write(message);
  }

  void _onDataReceived() {
  }

  Future<void> socketDisconnect() async {
    final socket = this.socket;
    if (socket != null) {
      await socket.close();
      debugPrint("Socket closed.");
      logManager?.logToFile('Socket closed.');
    }
  }
}

class SocketWidget extends ConsumerStatefulWidget {
  const SocketWidget({super.key});

  @override
  SocketWidgetState createState() => SocketWidgetState();
}

class SocketWidgetState extends ConsumerState<SocketWidget> {
  late SocketCom socketCom;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    socketCom = ref.read(socketComProvider.notifier);
    startSending(socketCom);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void startSending(SocketCom socketCom) {
    Future.delayed(Duration(milliseconds: socketConfig.waitTimeBeforeConnecting), () async {
      await socketCom.socketConnect();
      Future.delayed(Duration(milliseconds: socketConfig.waitTimeAfterConnecting), () async {
        socketCom.compInitComm = true;
        startTimer();
      });
    });
  }

  Future<void> timerAction() async {
    final socketCom = this.socketCom;
    if( (socketCom.socket != null) && (socketCom.compInitComm == true)) {
      socketCom.socketSend('send_message');
    } else {
      stopTimer();
      await socketCom.socketConnect();
      await Future.delayed(Duration(milliseconds: socketConfig.retryInterval));
      debugPrint('retry connection');
      startTimer();
    }
  }

  // タイマを再開するメソッド
  void startTimer() {
    _timer ??= Timer.periodic(
        Duration(milliseconds: socketConfig.sendInterval), (timer) => timerAction());
  }

  // タイマを停止するメソッド
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
}
