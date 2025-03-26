import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // intlパッケージをインポート

class Monthlyview extends StatefulWidget {
  final int? userId; // オプショナル型

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

    // userIdが提供されている場合にデータを取得
    if (widget.userId != null) {
      _fetchData(widget.userId!);
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

            // userIdが渡されている場合、自動的に選択
            if (widget.userId != null) {
              final matchedMember = members.firstWhere(
                    (member) => member['id'] == widget.userId,
                orElse: () => {}, // 空のマップ
              );
              if (matchedMember.isNotEmpty) {
                selectedName = matchedMember['name'];
                selectedUserId = matchedMember['id'];
              }
            }
          });
        } else {
          throw Exception('無効なレスポンス形式: リスト形式が期待されます。');
        }
      } else {
        throw Exception('メンバー情報の取得に失敗しました。ステータスコード: ${response.statusCode}');
      }
    } catch (e) {
      print('メンバー情報の取得中にエラーが発生しました: $e');
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
        final decodedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedResponse);

        setState(() {
          fetchedData = data.map((item) {
            // 金額を安全に処理
            final money = item['money'];
            final int parsedMoney = money is String
                ? int.tryParse(money.replaceAll(',', '')) ?? 0
                : money ?? 0;

            return {
              'date': item['date'],
              'money': _formatCurrency(parsedMoney), // カンマ区切りを適用
            };
          }).toList();
          isFetchingData = false;
        });
      } else {
        setState(() {
          fetchedData = [];
          isFetchingData = false;
        });
      }
    } catch (e) {
      print('データ取得中にエラーが発生しました: $e');
      setState(() {
        isFetchingData = false;
        fetchedData = [];
      });
    }
  }

  // カンマ区切りフォーマット関数
  String _formatCurrency(int value) {
    final formatter = NumberFormat('#,###'); // カンマ区切り
    return formatter.format(value) + "円";
  }

  // 日付フォーマット関数
  String formatDate(String? isoDate) {
    if (isoDate == null) {
      return '日付未登録';
    }
    final DateTime parsedDate = DateTime.parse(isoDate);
    return '${parsedDate.year}年${parsedDate.month}月${parsedDate.day}日';
  }

  int calculateTotalSavings() {
    return fetchedData.fold(0, (sum, item) {
      final moneyStr = item['money'].replaceAll(RegExp(r'[^\d-]'), ''); // マイナス記号を含む数字を許可
      final moneyValue = int.tryParse(moneyStr) ?? 0;
      return sum + moneyValue; // マイナス値はそのまま減算される
    });
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
                  '合計貯金額: ${_formatCurrency(calculateTotalSavings())}',
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
                            item['money'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: item['money'].startsWith('-')
                                  ? Colors.red // マイナスの場合は赤文字
                                  : Colors.black, // それ以外は黒文字
                            ),
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
