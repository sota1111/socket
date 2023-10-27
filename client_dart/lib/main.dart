import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'socket.dart';
import 'socket_log.dart';

const env = String.fromEnvironment('ENV', defaultValue: 'dev');

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
    return const MaterialApp(
      home: ProviderScope(
        child: Scaffold(
          backgroundColor: Colors.blue,
          appBar: null,
          body: Column(
            children: [
              SocketWidget(),
              //env == 'dev' ? const DebugArea() : Container(),
            ],
          ),
          //bottomNavigationBar: buildBottomNavigationBar(),
        ),
      )
    );
  }
}