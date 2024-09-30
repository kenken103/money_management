import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Inputpage extends StatelessWidget {
  const Inputpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: const Center(
        child: Text('This is the next page'),
      ),
    );
  }
}