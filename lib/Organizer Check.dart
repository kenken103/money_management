import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrganaizerCheck extends StatefulWidget {
  const OrganaizerCheck({Key? key}) : super(key: key);

  @override
  _OrganaizerCheck createState() => _OrganaizerCheck();
}

class _OrganaizerCheck extends State<OrganaizerCheck> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  int? selectedCheckboxIndex; // 選択されたチェックボックスのインデックス
  DateTime? selectedDate; // 選択された日付

  Future<void> _fetchMembers() async {
    try {
      final response = await http.get(Uri.parse('https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/MenberName'));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(body);
        setState(() {
          items = data
              .map((item) => {
            'name': item['name'],
          })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveData() {
    // 保存ボタンが押されたときの処理を記述
    if (selectedCheckboxIndex != null && selectedDate != null) {
      final selectedName = items[selectedCheckboxIndex!]['name'];
      final date = '${selectedDate!.toLocal().year}-${selectedDate!.toLocal().month}-${selectedDate!.toLocal().day}';
      print('保存されたデータ: 名前=$selectedName, 日付=$date');
    } else {
      print('データが完全に選択されていません');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('幹事確認'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '○○の幹事: けんたろう',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.yellow),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '名前',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '幹事選択',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < items.length; i++)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              items[i]['name'],
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Checkbox(
                              value: selectedCheckboxIndex == i,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedCheckboxIndex = i;
                                  } else {
                                    selectedCheckboxIndex = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('次回の開催日を選択'),
                ),
                SizedBox(width: 20),
                Text(
                  selectedDate == null
                      ? '未選択'
                      : '次回開催日: ${selectedDate!.toLocal().year}-${selectedDate!.toLocal().month}-${selectedDate!.toLocal().day}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              selectedCheckboxIndex == null
                  ? '次回の幹事：未選択'
                  : '次回の幹事: ${items[selectedCheckboxIndex!]['name']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
