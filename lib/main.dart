import 'package:flutter/material.dart';

void main() {
  runApp(const ThaliApp());
}

class ThaliApp extends StatelessWidget {
  const ThaliApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 20,
        itemBuilder: (context, index) => MemberTile(),
      ),
    );
  }
}

class MemberTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      // shape: const RoundedRectangleBorder(
      // /*borderRadius: BorderRadius.all(Radius.circular(0.1))*/),
      child: Builder(
        builder: (BuildContext context) {
          return const Material(
            color: Colors.transparent,
          );
        },
      ),
    );
  }
}
