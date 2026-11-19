import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_projek/main.dart';
import 'package:ujian_projek/pages/dragonball_page.dart';

void main() {
  testWidgets('loading Dragon Ball tampil saat aplikasi dimulai', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(DragonballLoadingPage), findsOneWidget);
  });
}
