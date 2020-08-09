import 'package:Dayflect/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      title: 'Dayflect',
      theme: ThemeData.dark().copyWith(primaryColor: kPastelBlue),
    );
  }
}
