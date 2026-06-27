import 'package:comchat/models/shop.dart';
import 'package:comchat/ad_reels_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdReelsScreen shows ad content for active businesses', (
    tester,
  ) async {
    final shops = [
      Shop(
        id: 'shop-1',
        name: 'Sunny Bites',
        address: '1 Main Road',
        contact: '0123456789',
        openingTime: '08:00',
        closingTime: '20:00',
        rating: 4.8,
        imageUrls: const [],
        category: 'Fast Food',
        statusText: 'Fresh lunch deals all week long!',
        statusDurationSeconds: 45,
        isStatusAdActive: true,
      ),
    ];

    await tester.pumpWidget(MaterialApp(home: AdReelsScreen(ads: shops)));

    expect(find.text('Weekly specials'), findsOneWidget);
    expect(find.text('Sunny Bites'), findsOneWidget);
    expect(find.textContaining('Fresh lunch deals'), findsOneWidget);
    expect(find.text('Order now'), findsOneWidget);
    expect(find.textContaining('Featured'), findsOneWidget);
    expect(find.text('Swipe up to view shop'), findsOneWidget);
    expect(find.textContaining('Budget'), findsOneWidget);
  });
}
