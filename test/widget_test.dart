import 'package:flutter_test/flutter_test.dart';
import 'package:rumidays/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const RumiDaysApp());
    expect(find.text('RumiDays'), findsOneWidget);
  });
}
