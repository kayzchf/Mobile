import 'package:flutter_test/flutter_test.dart';
import 'package:finalproject/main.dart';

void main() {
  testWidgets('Arcanova smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ArcanovaApp());
    expect(find.text('KARTU HARI INI'), findsOneWidget);
  });
}
