import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const SocketServerApp());
}

class SocketServerApp extends StatelessWidget {
  const SocketServerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Server Example')),
        body: const SocketServerPage(),
      ),
    );
  }
}

class SocketServerPage extends StatefulWidget {
  const SocketServerPage({super.key});

  @override
  SocketServerPageState createState() => SocketServerPageState();
}

class SocketServerPageState extends State<SocketServerPage> {
  final TextEditingController _controller = TextEditingController(text: '0000');
  @override
  void initState() {
    super.initState();
    startServer();
  }

  void startServer() async {
    final serverAddress = InternetAddress('127.0.0.1');
    const port = 55001;
    const bufferSize = 1024;

    final serverSocket = await ServerSocket.bind(serverAddress, port);
    debugPrint('サーバーが待ち受け状態です...');

    await for (Socket client in serverSocket) {
      debugPrint('${client.remoteAddress} から接続要求がありました。');
      handleClient(client, bufferSize);
    }
  }

  void handleClient(Socket client, int bufferSize) {
    client.listen((List<int> data) {
      if (data.isNotEmpty) {
        var decodedData = utf8.decode(data);
        Map<String, dynamic> receivedJson;

        try {
          receivedJson = jsonDecode(decodedData); // 文字列をJSONに変換
        } catch (e) {
          debugPrint("JSONのデコードに失敗しました: $e");
          client.close();
          return;
        }

        //debugPrint("受信したJSON: $receivedJson");

        var responseMap = {
          'status': 'success',
          'message': {
            'greeting': 'Hello, Client!',
            'inquiry': 'How are you?',
            'additionalInfo': 'This is another message.',
          }
        };

        var jsonResponse = jsonEncode(responseMap); // MapをJSON形式にエンコード
        //debugPrint("Sending JSON: $jsonResponse");

        final responseData = utf8.encode(jsonResponse);
        client.add(responseData);
      } else {
        client.close();
      }
    }, onError: (error) {
      debugPrint('エラー: $error');
      client.close();
    }, onDone: () {
      debugPrint('${client.remoteAddress} からの接続が終了しました。');
      client.close();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Enter respData'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('Update respData'),
          ),
        ],
      ),
    );
  }
}
