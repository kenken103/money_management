import 'package:flutter/material.dart';

import 'Inputpage.dart';
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: CustomButton(
          backcolor: Colors.green,
          forecolor: Colors.black,
          height: 50.0,
          width: 150.0,
          onPressed: ()=> _navigateToInputpage(context),
          child: const Text('貯金額入力'),
        ),
      ),
    );
  }
}

void _navigateToInputpage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Inputpage()),
  );
}