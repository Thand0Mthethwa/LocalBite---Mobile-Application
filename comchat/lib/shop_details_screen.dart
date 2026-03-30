import 'package:comchat/models/shop.dart';
import 'package:flutter/material.dart';

class ShopDetailsScreen extends StatelessWidget {
  final Shop shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shop.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shop.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        shop.imageUrls[index],
                        width: MediaQuery.of(context).size.width * 0.8,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              shop.name,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(shop.rating.toString(), style: theme.textTheme.titleMedium),
                const SizedBox(width: 16),
                Text(shop.category, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text('Address', style: theme.textTheme.titleLarge),
            Text(shop.address, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Contact', style: theme.textTheme.titleLarge),
            Text(shop.contact, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Hours', style: theme.textTheme.titleLarge),
            Text('${shop.openingTime} - ${shop.closingTime}', style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
