import 'package:flutter/material.dart';

class MemberTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shape: const RoundedRectangleBorder(
          /*borderRadius: BorderRadius.all(Radius.circular(0.1))*/),
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
