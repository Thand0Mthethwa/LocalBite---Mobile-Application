import 'package:comchat/repositories/shop_repository.dart';
import 'package:comchat/shop_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:comchat/models/shop.dart';

class ShopList extends StatelessWidget {
  const ShopList({super.key});

  @override
  Widget build(BuildContext context) {
    final shopRepository = ShopRepository();
    return StreamBuilder<List<Shop>>(
      stream: shopRepository.getShops(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No shops found.'));
        }

        final shops = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: shop.imageUrls.isNotEmpty
                    ? Image.network(shop.imageUrls.first, width: 80, height: 80, fit: BoxFit.cover)
                    : Container(width: 80, height: 80, color: Colors.grey[200]),
                title: Text(shop.name),
                subtitle: Text(shop.address),
                trailing: Text(shop.rating.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopDetailsScreen(shop: shop),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
