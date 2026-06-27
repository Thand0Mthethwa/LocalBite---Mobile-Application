import 'package:comchat/models/shop.dart';
import 'package:comchat/widgets/business_status_ad_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BusinessStatusAdCard shows the status message and duration', (
    tester,
  ) async {
    final shop = Shop(
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
      statusMusicUrl: 'https://example.com/music.mp3',
      isStatusAdActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BusinessStatusAdCard(shop: shop)),
      ),
    );

    expect(find.text('Business status ad'), findsOneWidget);
    expect(
      find.textContaining('Fresh lunch deals all week long!'),
      findsOneWidget,
    );
    expect(find.textContaining('45s'), findsOneWidget);
  });
}
