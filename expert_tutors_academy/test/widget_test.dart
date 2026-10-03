import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expert_tutors_academy/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ExpertTutorsApp(),
      ),
    );
    expect(find.byType(ExpertTutorsApp), findsOneWidget);
  });
}
