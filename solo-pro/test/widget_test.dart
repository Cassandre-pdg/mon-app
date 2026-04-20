import 'package:flutter_test/flutter_test.dart';
import 'package:solopro/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloProApp());
    expect(find.byType(SoloProApp), findsOneWidget);
  });
}
