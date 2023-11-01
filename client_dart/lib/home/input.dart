import 'package:flutter/material.dart';

class InputTablePage extends StatefulWidget {
  final String formattedDate;

  const InputTablePage({super.key, required this.formattedDate});

  @override
  InputTablePageState createState() => InputTablePageState();
}

class InputTablePageState extends State<InputTablePage> {
  String? selectedPlace;
  String? selectedCity;
  int? selectedHour;
  int? selectedMinute;
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.formattedDate),
        Row(
          children: [
            DropdownButton<String>(
              value: selectedPlace,
              items: <String>['日本', 'その他'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedPlace = newValue;
                  selectedCity = null; // Reset city when country changes
                });
              },
              hint: Text('場所を選択'),
            ),
            if (selectedPlace == '日本') ...[
              DropdownButton<String>(
                value: selectedCity,
                items: <String>['東京', '大阪', '名古屋'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
                hint: Text('都市を選択'),
              ),
            ]
          ],
        ),
        Row(
          children: [
            DropdownButton<int>(
              value: selectedHour,
              items: List<int>.generate(25, (int index) => index).map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedHour = newValue;
                });
              },
              hint: Text('時'),
            ),
            DropdownButton<int>(
              value: selectedMinute,
              items: List<int>.generate(61, (int index) => index).map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedMinute = newValue;
                });
              },
              hint: Text('分'),
            ),
          ],
        ),
        TextField(
          controller: messageController,
          maxLines: 5, // Set the maximum lines to 5
          decoration: InputDecoration(labelText: 'メッセージを入力'),
        ),
      ],
    );
  }
}
