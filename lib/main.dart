import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/members_screen.dart';

Future<void> main() async {
  runApp(const ThaliApp());
}

class ThaliApp extends StatelessWidget {
  const ThaliApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MembersScreen(),
    );
  }
}
