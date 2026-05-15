import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:auto_datetime/auto_datetime.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('isAutomaticDateTimeEnabled returns a bool', (WidgetTester tester) async {
    final AutoDatetime plugin = AutoDatetime();
    final bool result = await plugin.isAutomaticDateTimeEnabled();
    // Result must be a valid bool regardless of actual device setting
    expect(result, isA<bool>());
  });
}
