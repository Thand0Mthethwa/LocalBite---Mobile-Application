
import 'package:comchat/feature_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FeatureCard displays title and icon and calls onTap', (WidgetTester tester) async {
    // Define a key for the FeatureCard to easily find it.
    const featureCardKey = Key('feature_card');

    // Define a mock onTap function.
    bool tapped = false;
    void onTap() {
      tapped = true;
    }

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureCard(
            key: featureCardKey,
            title: 'Test Title',
            icon: Icons.abc,
            onTap: onTap,
          ),
        ),
      ),
    );

    // Verify that the title and icon are displayed.
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.byIcon(Icons.abc), findsOneWidget);

    // Simulate a tap on the card.
    await tester.tap(find.byKey(featureCardKey));
    await tester.pump();

    // Verify that the onTap callback was called.
    expect(tapped, isTrue);
  });
}
