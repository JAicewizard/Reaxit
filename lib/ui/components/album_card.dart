import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/ui/screens/album_detail.dart';
import 'package:reaxit/models/album.dart';

class AlbumCard extends StatelessWidget {
  final Album _album;
  AlbumCard(this._album);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetail(this._album.pk, this._album),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            // TODO: separate hero tags everywhere by type, to prevent shared tag between for example members and albums
            tag: _album.pk,
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/img/default-avatar.jpg',
              image: _album.cover.full,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _album.title,
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
                Text(
                  DateFormat("d MMMM y").format(_album.date),
                  style: Theme.of(context).primaryTextTheme.caption,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.5),
                ],
                stops: [0.4, 1.0],
              ),
            ),
          )
        ],
      ),
    );
  }
}
