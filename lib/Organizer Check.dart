import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Widget.dart';

class OrganaizerCheck extends StatefulWidget {
  const OrganaizerCheck({Key? key}) : super(key: key);

  @override
  _OrganaizerCheck createState() => _OrganaizerCheck();
}

class _OrganaizerCheck extends State<OrganaizerCheck> {
  List<Map<String, dynamic>> items = [];
  String? organizerName; // 幹事名を保持する変数
  String? organizerday; // 幹事名を保持する変数
  int? organizeruserid;
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
          items = data.map((item) => {
            'name': item['name'],
            'userid': item['id'], // userid を含める
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }


  Future<void> _fetchOrganizerHistory() async {
    try {
      final response = await http.get(Uri.parse('https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/organaizerhistory'));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(body);

        setState(() {
          if (data.isNotEmpty) {
            organizerName = data[0]['name']; // APIから取得した最初の名前を幹事名に設定
            organizerday=data[0]['day']; //APIから取得した開催日時を設定
            organizeruserid=data[0]['userid'];
          }
        });
      } else {
        throw Exception('Failed to load organizer history');
      }
    } catch (e) {
      print('Error fetching organizer history: $e');
    }
  }




  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ja'), // 日本語のロケールを設定
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveData() async {
    if (selectedCheckboxIndex != null && selectedDate != null) {
      final selectedUserId = items[selectedCheckboxIndex!]['userid'];
      final date =
          '${selectedDate!.toLocal().year}-${selectedDate!.toLocal().month.toString().padLeft(2, '0')}-${selectedDate!.toLocal().day.toString().padLeft(2, '0')}';

      final Map<String, dynamic> requestBody = {
        'user_id': selectedUserId,
        'day': date,
      };

      try {
        final response = await http.post(
          Uri.parse(
              'https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/organaizerhistory'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('データが正常に保存されました: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('データが正常に保存されました！')),
          );

          // データを再読み込みして画面を更新
          _initializeData();
        } else {
          print('保存に失敗しました: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存に失敗しました。エラー: ${response.statusCode}')),
          );
        }
      } catch (e) {
        print('エラーが発生しました: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました。もう一度試してください。')),
        );
      }
    } else {
      print('データが完全に選択されていません');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('幹事と開催日を選択してください。')),
      );
    }
  }



  void _initializeData() {
    setState(() {
      isLoading = true; // 初期化処理中のローディング状態を設定
    });

    _fetchMembers().then((_) {
      _fetchOrganizerHistory().then((_) {
        setState(() {
          selectedCheckboxIndex = items.indexWhere((item) => item['userid'] == organizeruserid);
          isLoading = false; // 初期化が完了したらローディング状態を解除
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData(); // 初期化メソッドを呼び出し
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
                  '$organizerdayの幹事: $organizerName',
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
            Table(
              border: TableBorder.all(color: Colors.black),
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.yellow),
                  children: [
                    SizedBox(
                      height: 30.0,
                      child: Center(
                        child: Text(
                          '名前',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                      child: Center(
                        child: Text(
                          '幹事選択',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                // ループ内でTableRowを生成
                for (int i = 0; i < items.length; i++)
                  TableRow(
                    children: [
                      SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(
                            items[i]['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Checkbox(
                            value: selectedCheckboxIndex == i, // 選択状態を反映
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
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: 20),
            Row(
              children: [
                CustomButton(
                  backcolor: Colors.blue,
                  forecolor: Colors.white,
                  height: 60.0,
                  width: 100.0,
                  onPressed: _pickDate,
                  child: Text('開催日選択',textAlign: TextAlign.center) // テキスト中央揃え),

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
              child: CustomButton(
                backcolor: Colors.blue,
                forecolor: Colors.white,
                height: 30.0,
                width: 200.0,
                onPressed: _saveData,
                child: Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



