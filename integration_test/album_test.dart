import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reaxit/main.dart' as app;

const imagelink1 =
    'https://upload.wikimedia.org/wikipedia/commons/7/7b/Image_in_Glossographia.png';

WidgetTesterCallback getTestMethod() {
  return (tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(
      find.image(
        const NetworkImage(imagelink1),
      ),
      findsOneWidget,
    );
  };
}

void main() {
  final _ = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Album',
    () {
      testWidgets(
        'able to load an album',
        getTestMethod(),
      );
    },
  );
}
