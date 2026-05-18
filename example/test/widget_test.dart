import 'package:flutter_test/flutter_test.dart';
import 'package:stories_example/main.dart';

void main() {
  testWidgets('app loads', (tester) async {
    await tester.pumpWidget(const StoriesExampleApp());
    expect(find.text('Stories'), findsOneWidget);
  });
}
