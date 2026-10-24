import 'package:flutter_test/flutter_test.dart';

import 'package:nav_app/main.dart';

void main() {
  testWidgets('app starts with splash screen and reaches welcome screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('University Indoor Navigation System'), findsOneWidget);
    expect(find.text('جامعة مؤتة'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Student Login'), findsOneWidget);
  });
}
