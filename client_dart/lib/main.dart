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
  int selectedDrawerIndex = 0;

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
      });
    }
  }

  Widget getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return const Text('reservation');
      case 1:
        return Column(
          children: [
            env == 'linux' ? SendArea() : const Text('This function is only use in linux'),
            env == 'linux' ? const ReceiveArea() : Container(),
          ],
        );

      default:
        return const Text('not implemented');
    }
  }


  final drawerHeader = const UserAccountsDrawerHeader(
    accountName: Text("user name"),
    accountEmail: Text("user@email.com"),
    currentAccountPicture: CircleAvatar(
      child: FlutterLogo(size: 42.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Robot予約"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("user name"),
              accountEmail: Text("user@email.com"),
              currentAccountPicture: CircleAvatar(
                child: FlutterLogo(size: 42.0),
              ),
            ),
            ListTile(
              title: const Text('reservation'),
              leading: const Icon(Icons.access_time),
              onTap: () {
                setState(() {
                  selectedDrawerIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('socket communication'),
              leading: const Icon(Icons.add_ic_call_outlined),
              onTap: () {
                setState(() {
                  selectedDrawerIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          env == 'linux' ? const SocketWidget() : Container(),
          getDrawerItemWidget(selectedDrawerIndex),
        ],
      ),
    );
  }
}
