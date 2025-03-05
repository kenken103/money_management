import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(Uri.parse('http://localhost:3000/MenberName'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
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
  }

  Future<void> _fetchData(int userId) async {
    setState(() {
      isFetchingData = true;
    });

    final response = await http.get(Uri.parse('http://localhost:3000/data?user_id=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
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
  }

  Future<void> _submitTransaction() async {
    if (selectedUserId != null && amountController.text.isNotEmpty) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/Input?user_id=$selectedUserId&amount=${amountController.text}'),
      );

      if (response.statusCode != 400) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('登録完了'),
        ));
        amountController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('エラーが発生しました'),
        ));
      }
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
              keyboardType: TextInputType.number,
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
