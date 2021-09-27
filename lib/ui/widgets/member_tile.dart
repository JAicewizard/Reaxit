import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';

class MemberTile extends StatelessWidget {
  final ListMember member;

  const MemberTile({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      routeSettings: RouteSettings(name: 'Profile(${member.pk})'),
      transitionType: ContainerTransitionType.fadeThrough,
      closedShape: const RoundedRectangleBorder(),
      closedBuilder: (context, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            FadeInImage.assetNetwork(
              placeholder: 'assets/img/default-avatar.jpg',
              image: member.photo.medium,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 200),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                color: Colors.black,
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
              child: Text(
                member.displayName,
                style: Theme.of(context).primaryTextTheme.bodyText2,
              ),
            )
          ],
        );
      },
      openBuilder: (_, __) => ProfileScreen(pk: member.pk, member: member),
    );
  }
}
