import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Monthlyview extends StatefulWidget {
  const Monthlyview({Key? key}) : super(key: key);

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
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final response =
    await http.get(Uri.parse('http://localhost:3000/MenberName'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        members = data
            .map((item) => {
          'name': item['name'],
          'id': item['id'],
        })
            .toList();
        isLoadingMembers = false;
      });
    } else {
      throw Exception('Failed to load members');
    }
  }

  Future<void> _fetchData(int userId) async {
    setState(() {
      isFetchingData = true;
    });

    final response =
    await http.get(Uri.parse('http://localhost:3000/data?user_id=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
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
        title: Text('月別貯金額'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: isLoadingMembers
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButton<String>(
              isExpanded: true,
              hint: Text('名前を選択'),
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
                      .firstWhere(
                          (member) => member['name'] == newValue)['id'];
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
                  // 合計金額表示（グリッドの上部）
                  Text(
                    '合計貯金額: ${calculateTotalSavings()}円',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            if (isFetchingData)
              Center(child: CircularProgressIndicator())
            else if (fetchedData.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
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
                            child: Text(
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
                ),
              )
            else
              Center(
                child: Text(
                  'データがありません',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
