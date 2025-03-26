import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> fetchedData = [];
  String? selectedName;
  int? selectedUserId;
  bool isLoadingMembers = true;
  bool isFetchingData = false;
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final response = await http.get(Uri.parse('https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/MenberName'));

      if (response.statusCode == 200) {
        // UTF-8デコードを適用
        final body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(body);
        setState(() {
          members = data.map((item) => {
            'name': item['name'],
            'id': item['id'],
          }).toList();
          isLoadingMembers = false;
        });
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  Future<void> _fetchData(int userId) async {
    setState(() {
      isFetchingData = true;
    });

    try {
      final response = await http.get(Uri.parse('https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/data?user_id=$userId'));

      if (response.statusCode == 200) {
        // UTF-8デコードを適用
        final body = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(body);
        setState(() {
          fetchedData = data.map((item) => {
            'date': item['date'],
            'money': item['money'],
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
      print('Error fetching data: $e');
      setState(() {
        isFetchingData = false;
      });
    }
  }


  Future<void> _submitTransaction() async {
    // 入力バリデーション
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ユーザーを選択してください'),
      ));
      return;
    }

    if (amountController.text.isEmpty || double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('金額を正確に入力してください'),
      ));
      return;
    }

    try {
      // 送信データを表示してデバッグ確認
      final requestData = {
        'user_id': selectedUserId,
        'amount': amountController.text, // 数値形式である必要があります
      };

      final response = await http.post(
        Uri.parse('https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/Input'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData), // JSON形式でエンコード
      );


      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('登録完了'),
        ));
        amountController.clear(); // 入力内容をクリア
      } else {
        // サーバー側エラー表示
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('エラーが発生しました: ${response.body}'),
        ));
        print('レスポンスヘッダー: ${response.headers}');
        print('レスポンスボディ: ${response.body}');

      }
    } catch (e) {
      // 通信エラーのキャッチ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('通信エラーが発生しました'),
      ));
      print('Error submitting transaction: $e');
    }
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
                      .firstWhere((member) => member['name'] == newValue)['id'];
                });
                if (selectedUserId != null) {
                  _fetchData(selectedUserId!);
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: '金額を入力',
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[\-\d]+')), // マイナスと数字を許可
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTransaction,
              child: Text('確定'),
            ),
          ],
        ),
      ),
    );
  }
}
