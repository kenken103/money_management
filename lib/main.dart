import 'package:flutter/material.dart';
import 'package:money_management/Organizer%20Check.dart';
import 'Inputpage.dart';
import 'SavingsTotal.dart';
import 'Monthlyview.dart';
import 'Widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // 必要に応じて
      ],
      supportedLocales: [
        const Locale('ja', 'JP'), // 日本語
      ],
      locale: const Locale('ja', 'JP'), // アプリ全体のロケールを日本語に設定
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
                if (_passwordController.text == correctPassword) {
                  Navigator.of(context).pop();
                  _navigateToPage(context, AddTransactionPage());
                } else {
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
            const SizedBox(height: 30),
            CustomButton(
              backcolor: Colors.blue,
              forecolor: Colors.white,
              height: 50.0,
              width: 150.0,
              onPressed: () => _navigateToPage(context, const SavingTotal()),
              child: const Text('貯金総額'),
            ),
            const SizedBox(height: 30),
            CustomButton(
              backcolor: Colors.blue,
              forecolor: Colors.white,
              height: 50.0,
              width: 150.0,
              onPressed: () => _navigateToPage(context, const Monthlyview()),
              child: const Text('月別貯金額表示'),
            ),
            const SizedBox(height: 30),
            CustomButton(
              backcolor: Colors.blue,
              forecolor: Colors.white,
              height: 50.0,
              width: 150.0,
              onPressed: () => _showPasswordDialog(context),
              child: const Text('貯金額入力'),
            ),
            const SizedBox(height: 30),
            CustomButton(
              backcolor: Colors.blue,
              forecolor: Colors.white,
              height: 50.0,
              width: 150.0,
              onPressed: () => _navigateToPage(context, const OrganaizerCheck()),
              child: const Text('幹事確認'),
            ),
          ],
        ),
      ),
    );
  }
}
