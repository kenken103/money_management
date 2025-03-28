import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // intlパッケージをインポート

import 'Monthlyview.dart';

class SavingTotal extends StatefulWidget {
  const SavingTotal({Key? key}) : super(key: key);

  @override
  _SavingTotalState createState() => _SavingTotalState();
}

class _SavingTotalState extends State<SavingTotal> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    print('Fetching items...');
    try {
      final response = await http.get(
        Uri.parse('https://z6l2uosz0l.execute-api.ap-northeast-1.amazonaws.com/dev/totalmoney'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('Data received: $data'); // レスポンスデータをログに出力
        setState(() {
          items = data.map((item) {
            // 'total_money'の型がStringの場合も処理する
            final totalMoney = item['total_money'];
            final int parsedMoney = totalMoney is String
                ? int.tryParse(totalMoney) ?? 0
                : totalMoney ?? 0;

            return {
              'name': item['name'],
              'money': _formatCurrency(parsedMoney), // カンマ区切りのフォーマットを適用
              'id': item['user_id'],
            };
          }).toList();
        });
      } else {
        print('Failed to load items. Status code: ${response.statusCode}');
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }


  // カンマ区切りのフォーマットを適用する関数
  String _formatCurrency(int value) {
    final formatter = NumberFormat('#,###'); // カンマ区切りのフォーマット
    return formatter.format(value) + "円";
  }

  // 合計貯金額を計算する関数
  int _calculateTotalSavings() {
    return items.fold(0, (sum, item) {
      final moneyStr = item['money'].replaceAll(RegExp(r'[^\d]'), ''); // 数字以外を除去
      final moneyValue = int.tryParse(moneyStr) ?? 0; // 文字列から数値に変換。失敗した場合は0を返す
      return sum + moneyValue; // 合計に加算
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSavings = _calculateTotalSavings(); // 合計を計算

    return Scaffold(
      appBar: AppBar(
        title: Text('貯金総額'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左上に詰める
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0), // 上部マージンを調整
              child: Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.yellow, // ヘッダーカラムの背景色を設定
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '名前',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // ヘッダーテキストの色を設定
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
                            color: Colors.black, // ヘッダーテキストの色を設定
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  for (var item in items) // シングルループにする
                    TableRow(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final userId = item['id']; // itemsから直接useridを取得
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Monthlyview(userId: userId), // userIdを渡す
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blue, // タップ可能であることを示す色
                                decoration: TextDecoration.underline, // 下線を追加
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['money'].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // 合計金額表示
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '合計貯金額: ${_formatCurrency(totalSavings)}', // 合計金額にカンマ区切りを適用
                  style: TextStyle(
                    fontSize: 20, // テキストサイズ
                    fontWeight: FontWeight.bold, // 太字
                    color: Colors.blue, // テキスト色を青色に変更
                  ),
                  textAlign: TextAlign.center, // 中央揃え
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
