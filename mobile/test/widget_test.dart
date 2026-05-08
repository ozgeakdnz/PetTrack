import 'package:flutter_test/flutter_test.dart';
import 'package:pettrack_mobile/main.dart';

void main() {
  testWidgets('PetTrack başlığı görünür', (WidgetTester tester) async {
    await tester.pumpWidget(const PetTrackApp());
    expect(find.text('PetTrack'), findsWidgets);
  });
}
