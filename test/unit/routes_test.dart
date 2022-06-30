import 'package:flutter_test/flutter_test.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/config.dart' as config;

void main() {
  group('isDeepLink', () {
    test('returns true if uri is a deep link', () {
      const apiHost = config.apiHost;
      final validUris = [
        'https://$apiHost/events/1/',
        'https://$apiHost/events/1',
        'http://$apiHost/events/1/',
        'https://$apiHost/',
        'https://$apiHost/pizzas/',
        'https://$apiHost/members/photos/some-album-1/',
      ];

      for (final uri in validUris) {
        expect(isDeepLink(Uri.parse(uri)), true, reason: '$uri is a deep link');
      }
    });

    test('returns false if uri is not a deep link', () {
      const apiHost = config.apiHost;
      final invalidUris = [
        'https://$apiHost/contact',
        'https://example.org/events/1/',
        'https://subdomain.$apiHost/events/1/',
      ];

      for (final uri in invalidUris) {
        expect(isDeepLink(Uri.parse(uri)), false);
      }
    });
  });
}
