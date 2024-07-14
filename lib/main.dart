import 'package:flutter/material.dart';
import 'package:my_grocery/view/StudentScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student List',
      home: StudentScreen()
    );
  }
}