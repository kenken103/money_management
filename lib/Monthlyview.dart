import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Monthlyview extends StatefulWidget {
  final int? userId; // オプショナル型に変更

  const Monthlyview({Key? key, this.userId}) : super(key: key);

  @override
  _MonthlyviewState createState() => _MonthlyviewState();
}

class _MonthlyviewState extends State<Monthlyview> {
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> fetchedData = [];
  String? selectedName;
  int? selectedUserId;
  bool isLoadingMembers = true;
  bool isFetchingData = false;

  @override
  void initState() {
    super.initState();

    // メンバー情報を取得
    _fetchMembers();

    // userIdが渡されてきた場合、データを取得
    if (widget.userId != null) {
      _fetchData(widget.userId!); // userIdがnullでない場合に_fetchDataを呼び出す
    } else {
      print('userIdが提供されていません');
    }
  }

  Future<void> _fetchMembers() async {
    try {
      final response = await http.get(
        Uri.parse('https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/MenberName'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // デバッグ用ログ
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // UTF-8としてデコードして文字化けを回避
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);

        if (data is List<dynamic>) {
          setState(() {
            members = data.map((item) {
              return {
                'name': item['name'],
                'id': item['id'],
              };
            }).toList();
            isLoadingMembers = false;

            // userIdが渡されている場合、自動的に選択する
            if (widget.userId != null) {
              final matchedMember = members.firstWhere(
                    (member) => member['id'] == widget.userId,
                orElse: () => {}, // 一致するメンバーがいない場合は空のマップ
              );
              if (matchedMember.isNotEmpty) {
                selectedName = matchedMember['name'];
                selectedUserId = matchedMember['id'];
              }
            }
          });
        } else {
          throw Exception('Invalid response format: expected a list.');
        }
      } else {
        throw Exception('Failed to load members with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching members: $e');
      setState(() {
        isLoadingMembers = false;
        members = [];
      });
    }
  }


  Future<void> _fetchData(int userId) async {
    setState(() {
      isFetchingData = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/data?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8としてデコードして文字化けを回避
        final decodedResponse = utf8.decode(response.bodyBytes); // 修正ポイント
        final List<dynamic> data = json.decode(decodedResponse);

        setState(() {
          fetchedData = data
              .map((item) => {
            'date': item['date'],
            'money': item['money'],
          })
              .toList();
          isFetchingData = false;
        });
      } else {
        setState(() {
          fetchedData = [];
          isFetchingData = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isFetchingData = false;
        fetchedData = [];
      });
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) {
      return '日付未登録';
    }
    final DateTime parsedDate = DateTime.parse(isoDate);
    return '${parsedDate.year}年${parsedDate.month}月${parsedDate.day}日';
  }

  int calculateTotalSavings() {
    return fetchedData.fold(0, (sum, item) => sum + (item['money'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('月別貯金額'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : isLoadingMembers
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DropdownButton<String>(
            isExpanded: true,
            hint: const Text('名前を選択'),
            value: selectedName,
            items: members.map((member) {
              return DropdownMenuItem<String>(
                value: member['name'],
                child: Text(member['name']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedName = newValue;
                fetchedData = [];
                selectedUserId = members
                    .firstWhere((member) => member['name'] == newValue)['id'];
              });
              if (selectedUserId != null) {
                _fetchData(selectedUserId!);
              }
            },
          ),
          const SizedBox(height: 20),
          if (fetchedData.isNotEmpty)
            Column(
              children: [
                Text(
                  '合計貯金額: ${calculateTotalSavings()}円',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          Expanded(
            child: fetchedData.isNotEmpty
                ? SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          '日付',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          '貯金額',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  for (var item in fetchedData)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formatDate(item['date']),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${item['money']}円',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )
                : const Center(
              child: Text(
                'データがありません',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
