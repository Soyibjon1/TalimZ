import 'package:flutter_test/flutter_test.dart';
import 'package:maktab/main.dart';
import 'package:provider/provider.dart';
import 'package:maktab/core/providers/app_provider.dart';

void main() {
  testWidgets('TalimZ app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const TalimZApp(),
      ),
    );
    expect(find.byType(TalimZApp), findsOneWidget);
  });
}
