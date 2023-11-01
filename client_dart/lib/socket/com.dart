import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'log.dart';
import 'config.dart';
import 'receiver.dart';
import 'provider.dart';

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
  Map<String, dynamic> messageToSend = {'message': 'default_message'};

  Future<void> socketConnect(BuildContext context, WidgetRef ref) async {
    final serverAddress = InternetAddress(socketConfig.address);
    final serverPort = socketConfig.port;

    try {
      socket = await Socket.connect(serverAddress, serverPort, timeout: Duration(milliseconds: socketConfig.connectionTimeout));
      debugPrint('socket connected');
      logManager?.logToFile('socket connected');
      socket!.listen(
            (data) => _onDataReceived(data, context, ref),
        onDone: () {
          socket = null;
        },
      );
    } catch (e) {
      debugPrint('Connection Error: $e');
      logManager?.logToFile('Connection Error: $e');
    }
  }

  void socketSend(Map<String, dynamic> messageMap) {
    final socket = this.socket;
    String jsonMessage = jsonEncode(messageMap);
    if (socket == null) {
      debugPrint('Socket is not connected.');
      logManager?.logToFile('Socket is not connected.');
      return;
    }
    socket.write(jsonMessage);
    debugPrint('Send Message: $jsonMessage');
    logManager?.logToFile('Send Message: $jsonMessage');
  }

  void setMessage(Map<String, dynamic> newMessage) {
    messageToSend = newMessage;
  }

  void _onDataReceived(List<int> data, BuildContext context, WidgetRef ref) {
    var response = utf8.decode(data);
    try {
      var jsonResponse = jsonDecode(response);
      debugPrint("Received JSON data: $jsonResponse");
      logManager?.logToFile('Received Message: $jsonResponse');

      // receivedDataを更新
      ref.read(socketDataProvider.notifier).updateReceivedData(jsonResponse);
    } catch (e) {
      debugPrint("The received data is not in JSON format: $e");
      logManager?.logToFile('Error Message: $e');
    }
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
      await socketCom.socketConnect(context, ref);
      Future.delayed(Duration(milliseconds: socketConfig.waitTimeAfterConnecting), () async {
        socketCom.compInitComm = true;
        startTimer();
      });
    });
  }

  Future<void> timerAction() async {
    final socketCom = this.socketCom;
    if( (socketCom.socket != null) && (socketCom.compInitComm == true)) {
      socketCom.socketSend(socketCom.messageToSend);
    } else {
      stopTimer();
      await socketCom.socketConnect(context, ref);
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
