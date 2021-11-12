import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class PushNotificationDialog extends StatelessWidget {
  final RemoteMessage message;
  PushNotificationDialog(this.message) : super(key: ObjectKey(message));

  @override
  Widget build(BuildContext context) {
    Uri? uri;
    if (message.data.containsKey('url') && message.data['url'] is String) {
      uri = Uri.tryParse(message.data['url'] as String);
    }

    return AlertDialog(
      title: Text(message.notification!.title!),
      content: Text(
        message.notification!.body!,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
        if (uri != null)
          Link(
            uri: uri,
            builder: (context, followLink) => OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                followLink?.call();
              },
              child: const Text('OPEN'),
            ),
          ),
      ],
    );
  }
}
