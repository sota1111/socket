import 'dart:io';
import 'dart:async';
//import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
//import 'package:android_intent/android_intent.dart';

//import '../common/common_imports.dart';
//import '../viewmodel/view_provider.dart';

const env = String.fromEnvironment('ENV', defaultValue: 'dev');

class SocketCom extends StateNotifier {
  SocketCom._() : super(null);
  static final SocketCom _instance = SocketCom._();

  static SocketCom get instance => _instance;
  final _portController = '55001';
  Socket? socket;
  bool compInitComm = false;

  // コールバック関数を追加
  void _onDataReceived() {
  }

  bool dialogIsShown = false;
  Future<void> socketConnect() async {
    const addressController = (env == 'dev') ? '127.0.0.1':'192.168.42.100';
    final serverAddress = InternetAddress(addressController);
    final serverPort = int.parse(_portController);

    try {
      socket = await Socket.connect(serverAddress, serverPort,
          timeout: const Duration(seconds: 5));
      debugPrint('socket connected');
      logToFile('socket connected');
      socket!.listen(
            (data) => _onDataReceived(),
        onDone: () {
          socket = null;
        },
      );
    } catch (e) {
      debugPrint('Connection Error: $e');
      logToFile('Connection Error: $e');
      //await _displayInstructions(context);
    }
  }

  Future<void>  _displayInstructions(BuildContext context) async {
    dialogIsShown = true;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('USBテザリングを\n有効にして下さい。'),
            content: const Text(
                '「アクセスポイントとテザリング」\n▶︎「USBテザリング」\n▶︎"ON"\n\n解決しない場合は、\nUSB接続を確認して下さい。'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  //await _openNetworkSettings();
                  dialogIsShown = false;
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _openNetworkSettings() async {
    //const AndroidIntent intent = AndroidIntent(
      //action: 'android.settings.WIRELESS_SETTINGS',
    //);
    //await intent.launch();
  }

  Future<void> socketSend(String message) async {
    final socket = this.socket;
    if (socket == null) {
      debugPrint('Socket is not connected.');
      logToFile('Socket is not connected.');
      return;
    }
    logToFile('Send Message: $message');
    debugPrint('Send Message: $message');
    socket.write(message);
  }

  Future<void> socketDisconnect() async {
    final socket = this.socket;
    if (socket != null) {
      await socket.close();
      debugPrint("Socket closed.");
      logToFile('Socket closed.');
    }
  }
}

final socketComProvider = StateNotifierProvider<SocketCom, void>((ref) {
  return SocketCom.instance;
});

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
    Future.delayed(const Duration(seconds: 1), () async {
      await socketCom.socketConnect();
      Future.delayed(const Duration(seconds: 5), () async {
        socketCom.compInitComm = true;
        await socketCom.socketSend("Authentication,1");
        restartTimer();
      });
    });
  }


  Future<void> timerAction() async {
    final socketCom = this.socketCom;
    //print("socketCom.compInitComm:${socketCom.compInitComm}");
    if( (socketCom.socket != null) && (socketCom.compInitComm == true)) {
      socketCom.socketSend('send_message');
    } else {

      stopTimer();
      await socketCom.socketConnect();
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('retry connection');
      socketCom.socketSend("Authentication,1");
      restartTimer();
    }
  }

  // タイマを再開するメソッド
  void restartTimer() {
    _timer ??= Timer.periodic(
        const Duration(milliseconds: 1000), (timer) => timerAction());
  }

  // タイマを停止するメソッド
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel(); // null許容型のため、'!'でnullチェックを行います。
      _timer = null;
    }
  }
}

File? logFile;

Future<void> initLogFile() async {
  logFile = await _createLogFile();
}

Future<File> _createLogFile() async {
  final directory = await getExternalStorageDirectory();
  if (directory == null) {
    throw Exception('External storage directory not found');
  }
  final logDirectory = Directory('${directory.path}/YourAppName/logs');
  if (!await logDirectory.exists()) {
    await logDirectory.create(recursive: true);
  }

  final timestamp = DateFormat('yyyyMMdd_HHmm ss').format(DateTime.now());
  final logFile = File('${logDirectory.path}/app_$timestamp.log');

  if (!await logFile.exists()) {
    await logFile.create(recursive: true);
  }

  return logFile;
}

Future<void> logToFile(String message) async {
  if (logFile == null) {
    debugPrint('LogFile not initialized');
    return;
  }
  final timestamp =
      DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
  final logLine = '$timestamp - $message\n';

  await logFile!.writeAsString(logLine, mode: FileMode.append, flush: true);
  //print('Logged to file: ${file.path}');
}
