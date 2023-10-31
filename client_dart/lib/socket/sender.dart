import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'com.dart';

class SendArea extends ConsumerWidget {
  SendArea({super.key});

  final TextEditingController keyController0 = TextEditingController(text: 'key0');
  final TextEditingController valueController0 = TextEditingController(text: 'value0');

  final TextEditingController keyController1 = TextEditingController(text: 'key1');
  final TextEditingController valueController1 = TextEditingController(text: 'value1');

  final TextEditingController keyController2 = TextEditingController(text: 'key2');
  final TextEditingController valueController2 = TextEditingController(text: 'value2');

  final TextEditingController keyController3 = TextEditingController(text: 'key3');
  final TextEditingController valueController3 = TextEditingController(text: 'value3');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var socketComInstance = SocketCom.instance;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: keyController0,
                  decoration: InputDecoration(labelText: "key0"),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: valueController0,
                  decoration: InputDecoration(labelText: "value0"),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: keyController1,
                  decoration: InputDecoration(labelText: "key1"),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: valueController1,
                  decoration: InputDecoration(labelText: "value1"),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: keyController2,
                  decoration: InputDecoration(labelText: "key2"),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: valueController2,
                  decoration: InputDecoration(labelText: "value2"),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: keyController3,
                  decoration: InputDecoration(labelText: "key3"),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: valueController3,
                  decoration: InputDecoration(labelText: "value3"),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height:10),
        ElevatedButton(
          onPressed: () {
            String statusKey = keyController0.text;
            String statusValue = valueController0.text;

            String greetingKey = keyController1.text;
            String greetingValue = valueController1.text;

            String inquiryKey = keyController2.text;
            String inquiryValue = valueController2.text;

            String additionalInfoKey = keyController3.text;
            String additionalInfoValue = valueController3.text;

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
