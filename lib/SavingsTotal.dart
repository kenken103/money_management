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
        child: Container(
          width: 300, // コンテナの幅を指定
          height: 600, // コンテナの高さを指定
          margin: const EdgeInsets.only(top: 1000.0),
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true, // GridViewのサイズを子要素の内容に合わせて調整
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2列
              mainAxisSpacing: 5.0, // 垂直方向のスペース
              crossAxisSpacing: 5.0, // 水平方向のスペース
              childAspectRatio: 5 / 1, // 幅と高さの比率
            ),
            itemCount: 14, // 2列7行で合計14アイテム
            itemBuilder: (context, index) {
              List<String> items = [
                "名前", "貯金額", "", "", "", "", "",
                "", "", "", "", "", "", ""
              ];
              return Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: Text(
                  items[index],
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
