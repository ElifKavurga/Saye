import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app.dart';
import 'package:frontend/screens/auth_screen.dart';
import 'package:frontend/screens/splash_screen.dart';

void main() {
  testWidgets('shows auth screen after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const SayeApp());

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Giriş Yap'), findsWidgets);
  });
}
