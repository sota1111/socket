import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket/com.dart';
import 'socket/log.dart';

import 'socket/sender.dart';
import 'socket/receiver.dart';
import '../home/table.dart';
import '../home/api.dart';
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
  String? selectedDrawerIndex = 'home';

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

  Widget getDrawerItemWidget(String pos) {
    switch (pos) {
      case 'home':
        return _buildDataColumn();
      case 'socket':
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

  Widget _buildDataColumn() {
    return Column(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchDataFromLambda(formattedDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();  // Empty container
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return DataTablePage(
                    data: snapshot.data!, formattedDate: formattedDate ?? '2023-10-1'
              );
            }
          },
        ),
      ],
    );
  }


  final drawerHeader = const UserAccountsDrawerHeader(
    accountName: Text("user name"),
    accountEmail: Text("user@email.com"),
    currentAccountPicture: CircleAvatar(
      child: FlutterLogo(size: 40.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Robot Fleet System"),
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
                  selectedDrawerIndex = 'home';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('socket communication'),
              leading: const Icon(Icons.add_ic_call_outlined),
              onTap: () {
                setState(() {
                  selectedDrawerIndex = 'socket';
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
          getDrawerItemWidget(selectedDrawerIndex!),
        ],
      ),
    );
  }
}
