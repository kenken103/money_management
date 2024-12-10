import 'package:flutter/material.dart';
import 'Inputpage.dart';
import 'SavingsTotal.dart';
import 'Monthlyview.dart';
import 'Widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '貯金会メニュー',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '貯金会メインメニュー'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _passwordController = TextEditingController();
  final String correctPassword = "3150"; // 正しいパスワードをここに設定

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('パスワード入力'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'パスワード',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                // パスワード検証ロジック
                if (_passwordController.text == correctPassword) {
                  Navigator.of(context).pop();
                  _navigateToPage(context, const Inputpage());
                } else {
                  // パスワードが間違っている場合の処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('パスワードが間違っています'),
                    ),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50),
            CustomButton(
              backcolor: Colors.blue,
              forecolor: Colors.white,
              height: 50.0,
              width: 150.0,
              onPressed: () => _navigateToPage(context, const SavingTotal()), // 仮のページ
              child: const Text('貯金総額'),
            ),
            SizedBox(height: 30),
            CustomButton(
              backcolor: Colors.blue,
              forecolor: Colors.white,
              height: 50.0,
              width: 150.0,
              onPressed: () => _navigateToPage(context, const Monthlyview()), // 仮のページ
              child: const Text('月別貯金額表示'),
            ),
            SizedBox(height: 30),
            CustomButton(
              backcolor: Colors.blue,
              forecolor: Colors.white,
              height: 50.0,
              width: 150.0,
              onPressed: () => _showPasswordDialog(context),
              child: const Text('貯金額入力'),
            ),
          ],
        ),
      ),
    );
  }
}
