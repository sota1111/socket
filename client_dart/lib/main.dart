import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket/com.dart';
import 'socket/log.dart';

import 'socket/sender.dart';
import 'socket/receiver.dart';
import '../home/table.dart';
import '../home/input.dart';
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
  int _currentIndex = 0;
  String? _selectedDrawerIndex = 'home';

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

  Widget _getBottomItemWidget(int index) {
    switch(index) {
      case 0:
        return InputTablePage(formattedDate: formattedDate ?? '2023-10-1');
      case 1:
        return _buildDataColumn();
      case 2:
        return const Text('Map Page');
      default:
        return const Text('Error');
    }
  }

  Widget getSelectedWidget() {
    if (_selectedDrawerIndex != 'home') {
      return _getDrawerItemWidget(_selectedDrawerIndex!);
    } else {
      return _getBottomItemWidget(_currentIndex);
    }
  }

  Widget _getDrawerItemWidget(String pos) {
    switch (pos) {
      case 'home':
        return _buildDataColumn();
      case 'mode':
        return const Text('mode setting');
      case 'position':
        return const Text('position setting');
      case 'map':
        return const Text('map setting');
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
              return Container();
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
                  _selectedDrawerIndex = 'home';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('set mode'),
              leading: const Icon(Icons.settings),
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = 'mode';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('set initial position'),
              leading: const Icon(Icons.location_on),
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = 'position';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('renew map'),
              leading: const Icon(Icons.refresh),
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = 'map';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('socket communication'),
              leading: const Icon(Icons.wifi_tethering),
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = 'socket';
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
          getSelectedWidget(),
        ],
      ),
      bottomNavigationBar: _selectedDrawerIndex == 'home'
          ? BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.input),
            label: 'Input',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
      )
          : null, // Return null to hide BottomNavigationBar
    );
  }
}
