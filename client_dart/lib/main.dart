import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket/com.dart';
import 'socket/log.dart';

import 'socket/sender.dart';
import 'socket/receiver.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logManager = LogManager();
  await logManager.initLogFile();
  SocketCom.instance.logManager = logManager;

  runApp(
    MaterialApp(
      home: ProviderScope(
        child: Builder(
          builder: (context) => const FleetManagePage(),
        ),
      ),
    ),
  );
}

class FleetManagePage extends StatefulWidget {
  const FleetManagePage({super.key});

  @override
  FleetManageState createState() => FleetManageState();
}

class FleetManageState extends State<FleetManagePage> {
  DateTime? selectedDate;
  String? formattedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    formattedDate = formatDate(selectedDate!);
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString()}-${date.day.toString()}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day);
        formattedDate = formatDate(selectedDate!);
        //debugPrint(formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: ProviderScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("表示"),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  _selectDate(context);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              env == 'linux' ? const SocketWidget() : Container(),
              env == 'linux' ? SendArea() : Container(),
              env == 'linux' ? const ReceiveArea() : Container(),
            ],
          ),
        ),
      )
    );
  }
}