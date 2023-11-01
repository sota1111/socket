import 'package:flutter/material.dart';
import 'api.dart';

class DataTablePage extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String formattedDate;

  const DataTablePage({super.key, required this.data, required this.formattedDate});

  @override
  DataTablePageState createState() => DataTablePageState();
}

class DataTablePageState extends State<DataTablePage> {
  late String selectedRow = "";
  List<bool> selectedRows = [];
  List<String> selectedRowsOrderID = [];
  late List<Map<String, dynamic>> currentData;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    currentData = widget.data;
    selectedRows = List<bool>.generate(widget.data.length, (index) => false);
  }

  Future<bool> confirmSelectedRows() async {
    int selectedRowCount = 0;

    for (int i = 0; i < selectedRows.length; i++) {
      if (selectedRows[i]) {
        selectedRowCount++;
      }
    }

    if (selectedRowCount == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Waning"),
            content: const Text("No data selected"),
            actions: [
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return false;
    }
    else if (selectedRowCount >= 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Waning"),
            content: const Text("Two or more data are selected"),
            actions: [
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return false; // Exit the function.
    }else{
      selectedRow = selectedRowsOrderID[0];
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLeftColumn(context),
      ],
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width * 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.green.shade700,
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    List<Map<String, dynamic>> newData = await fetchDataFromLambda(widget.formattedDate);
                    setState(() {
                      currentData = newData;
                      selectedRows = List<bool>.generate(currentData.length, (index) => false);
                      isLoading = false;
                    });
                  },
                  child: const Icon(Icons.refresh_outlined),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Date: ${widget.formattedDate}", style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height * 0.8, maxWidth: width * 0.85),
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 200,
                      headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                        return Colors.deepPurple;
                      }),
                      columns: [
                        DataColumn(
                          label: Container(
                            color: Colors.deepPurple,
                            width: width * 0.1,
                            child: const Text('Number',style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            color: Colors.deepPurple,
                            width: width * 0.45,
                            child: const Text('Robot',style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            color: Colors.deepPurple,
                            width: width * 0.3,
                            child: const Text('Time',style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                      rows: currentData.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return DataRow(
                          selected: selectedRows[index],
                          onSelectChanged: (bool? value) {
                            setState(() {
                              if (value != null) {
                                selectedRows[index] = value;
                                if (value) {
                                  selectedRowsOrderID.add(item['OrderID'].toString());
                                } else {
                                  selectedRowsOrderID.remove(item['OrderID'].toString());
                                }
                              }
                            });
                          },
                          cells: [
                            DataCell(Text(item['OrderID'].toString())),
                            DataCell(Text(item['Message'].toString())),
                            DataCell(Text(item['log_csv'].toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 1.0,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 1.0,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 1.0,
                    color: Colors.black,
                  ),
                ),
              ],
             ),
          ),
        ],
    );
  }
}
