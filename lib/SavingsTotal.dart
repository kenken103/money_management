import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 合計貯金額表示画面
class SavingTotal extends StatelessWidget {
  const SavingTotal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('貯金総額'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: Text('ウィジェットページの内容'),
      ),
    );
  }
}