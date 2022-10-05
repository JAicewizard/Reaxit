import 'package:flutter/material.dart';
import 'package:reaxit/ui/widgets/member_tile.dart';

class MembersScreen extends StatefulWidget {
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MemberListScrollView(
      key: const PageStorageKey('members'),
      controller: _controller,
    );
  }
}

/// A ScrollView that shows a grid of [MemberTile]s.
///
/// This does not take care of communicating with a Cubit. The [controller]
/// should do that. The [listState] also must not have an exception.
class MemberListScrollView extends StatelessWidget {
  final ScrollController controller;

  const MemberListScrollView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => MemberTile(),
            childCount: 100,
          ),
        ),
      ],
    );
  }
}
