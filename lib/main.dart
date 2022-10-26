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
    return PhysicalModel(
      shape: BoxShape.rectangle,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.zero,
      elevation: 0,
      color: Color(0xffffffff),
      shadowColor: const Color(0x00000000),
      child:
          SizedBox.fromSize(size: Size(131.80952380952382, 131.80952380952382)),
    );
  }
}
