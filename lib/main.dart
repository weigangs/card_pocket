import 'package:flutter/material.dart';
import './ui/doclist.dart';

void main() => runApp(const DocExpiryApp());

class DocExpiryApp extends StatelessWidget {
  const DocExpiryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocExpire',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true
      ),
      home: const DocList(),
    );
  }
}
