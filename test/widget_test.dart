import 'package:flutter_test/flutter_test.dart';

import 'package:touri/main.dart';

void main() {
  testWidgets('TouriApp boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TouriApp());
    expect(find.text('토우리 일기'), findsOneWidget);
  });
}
