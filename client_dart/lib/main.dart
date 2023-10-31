import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket/com.dart';
import 'socket/log.dart';

import 'socket/sender.dart';
import 'socket/receiver.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // LogManager インスタンスを作成してログファイルを初期化
  final logManager = LogManager();
  await logManager.initLogFile();

  // LogManager インスタンスを SocketCom にセット
  SocketCom.instance.logManager = logManager;
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProviderScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: const Text('Socket Send App')),
          body: Column(
            children: [
              envSocket == 'true' ? const SocketWidget() : Container(),
              envSocket == 'true' ? SendArea() : Container(),
              envSocket == 'true' ? const ReceiveArea() : Container(),
            ],
          ),
        ),
      )
    );
  }
}