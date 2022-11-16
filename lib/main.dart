import 'package:flutter/material.dart';

void main() {
  runApp(const ThaliApp());
}

class ThaliApp extends StatefulWidget {
  final String? initialRoute;
  const ThaliApp({this.initialRoute});

  @override
  State<ThaliApp> createState() => _ThaliAppState();
}

class _ThaliAppState extends State<ThaliApp> {
  @override
  Widget build(BuildContext context) {
    const imagelink1 =
        'https://upload.wikimedia.org/wikipedia/commons/7/7b/Image_in_Glossographia.png';

    return FadeInImage.assetNetwork(
      placeholder: 'assets/img/photo_placeholder.png',
      image: imagelink1,
      fit: BoxFit.cover,
    );
  }
}
