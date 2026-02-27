import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app.dart';

void main() {
  testWidgets('shows auth screen after splash', (WidgetTester tester) async {
    await tester.pumpWidget(const SayeApp());

    expect(find.text('Giris1'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle();

    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.text('Kayıt Ol'), findsWidgets);
    expect(find.text('Otomatik Giriş (Demo)'), findsOneWidget);
  });
}
