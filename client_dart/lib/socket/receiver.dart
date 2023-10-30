import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider.dart';

class JsonResponseDisplay extends ConsumerWidget {
  const JsonResponseDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketData = ref.watch(socketDataProvider);

    // JSON Encoderを使って整形
    final JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String receivedDataStr;
    try {
      receivedDataStr = encoder.convert(socketData.receivedData);
    } catch (e) {
      receivedDataStr = "Error encoding JSON: $e";
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Received JSON Data:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(receivedDataStr),
        ],
      ),
    );
  }
}
