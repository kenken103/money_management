import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 月別表示画面
class Monthlyview extends StatelessWidget {
  const Monthlyview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('月別貯金額'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: Text('その他のページの内容'),
      ),
    );
  }
}