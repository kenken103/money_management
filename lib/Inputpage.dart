import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Inputpage extends StatelessWidget {
  const Inputpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('貯金額入力'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('This is the next page'),
      ),
    );
  }
}