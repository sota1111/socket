import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'com.dart';

class SendArea extends ConsumerWidget {
  SendArea({super.key});

  final TextEditingController statusKeyController = TextEditingController(text: 'key0');
  final TextEditingController statusValueController = TextEditingController(text: 'value0');

  final TextEditingController greetingKeyController = TextEditingController(text: 'key2');
  final TextEditingController greetingValueController = TextEditingController(text: 'value2');

  final TextEditingController inquiryKeyController = TextEditingController(text: 'key2');
  final TextEditingController inquiryValueController = TextEditingController(text: 'value2');

  final TextEditingController additionalInfoKeyController = TextEditingController(text: 'key3');
  final TextEditingController additionalInfoValueController = TextEditingController(text: 'value3');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var socketComInstance = SocketCom.instance;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: statusKeyController,
                decoration: InputDecoration(labelText: "key0"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: statusValueController,
                decoration: InputDecoration(labelText: "value0"),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: greetingKeyController,
                decoration: InputDecoration(labelText: "key1"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: greetingValueController,
                decoration: InputDecoration(labelText: "value1"),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: inquiryKeyController,
                decoration: InputDecoration(labelText: "key2"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: inquiryValueController,
                decoration: InputDecoration(labelText: "value2"),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: additionalInfoKeyController,
                decoration: InputDecoration(labelText: "key3"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: additionalInfoValueController,
                decoration: InputDecoration(labelText: "value3"),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            String statusKey = statusKeyController.text;
            String statusValue = statusValueController.text;

            String greetingKey = greetingKeyController.text;
            String greetingValue = greetingValueController.text;

            String inquiryKey = inquiryKeyController.text;
            String inquiryValue = inquiryValueController.text;

            String additionalInfoKey = additionalInfoKeyController.text;
            String additionalInfoValue = additionalInfoValueController.text;

            Map<String, dynamic> newMessage = {
              statusKey: statusValue,
              'message': {
                greetingKey: greetingValue,
                inquiryKey: inquiryValue,
                additionalInfoKey: additionalInfoValue,
              },
            };

            socketComInstance.setMessage(newMessage);
            socketComInstance.socketSend(socketComInstance.messageToSend);
          },
          child: const Text('Send Custom Message'),
        ),
      ],
    );
  }
}
