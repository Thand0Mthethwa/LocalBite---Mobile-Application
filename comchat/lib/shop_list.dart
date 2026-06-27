import 'package:comchat/repositories/shop_repository.dart';
import 'package:comchat/shop_details_screen.dart';
import 'package:comchat/widgets/business_status_ad_card.dart';
import 'package:flutter/material.dart';
import 'package:comchat/models/shop.dart';

class ShopList extends StatefulWidget {
  const ShopList({super.key});

  @override
  State<ShopList> createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Fast Food',
    'Braai',
    'Home-cooked',
    'Bakery',
    'Healthy',
  ];

  final List<Shop> _sampleShops = [
    Shop(
      id: 'sample-1',
      name: 'Quick Bites Fast Food',
      address: '12 Market Street',
      contact: '+27 82 555 1234',
      openingTime: '08:00',
      closingTime: '22:00',
      rating: 4.5,
      imageUrls: ['assets/images/shop_images/Quick bites/Plate.jpg'],
      category: 'Fast Food',
      statusText: 'Fresh lunch deals and combo specials all week long!',
      statusDurationSeconds: 45,
      statusMusicUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      isStatusAdActive: true,
    ),
    Shop(
      id: 'sample-2',
      name: 'Grill & Chill Braai',
      address: '45 Riverside Drive',
      contact: '+27 82 555 5678',
      openingTime: '10:00',
      closingTime: '23:00',
      rating: 4.8,
      imageUrls: [
        'assets/images/shop_images/grill and chill braai/African food.jpg',
      ],
      category: 'Braai',
    ),
    Shop(
      id: 'sample-3',
      name: 'Mama Nandi’s Kitchen',
      address: '88 Heritage Lane',
      contact: '+27 82 555 9012',
      openingTime: '07:30',
      closingTime: '20:00',
      rating: 4.7,
      imageUrls: [
        'assets/images/shop_images/Nandi\'s kitchen/Nandi\'s Beef Pepper Soup.jpg',
        'assets/images/shop_images/Nandi\'s kitchen/Nandi\'s Dumblings and Beefstew.jpg',
        'assets/images/shop_images/Nandi\'s kitchen/Nandi\'s Meatball Spagetti Recipe.jpg',
        'assets/images/shop_images/Nandi\'s kitchen/Nandi\'s Muhodu dish.jpg',
        'assets/images/shop_images/Nandi\'s kitchen/Nandi\'s Spagetti Paranran.jpg',
      ],
      category: 'Home-cooked',
    ),
    Shop(
      id: 'sample-4',
      name: 'Bakery Bliss',
      address: '7 Main Road',
      contact: '+27 82 555 3456',
      openingTime: '06:00',
      closingTime: '18:00',
      rating: 4.6,
      imageUrls: [
        'assets/images/shop_images/Bakery Bliss/Combo.jpg',
        'assets/images/shop_images/Bakery Bliss/Bread.jpg',
        'assets/images/shop_images/Bakery Bliss/Donuts.jpg',
        'assets/images/shop_images/Bakery Bliss/Smooth Shiny Sweet Buns.jpg',
      ],
      category: 'Bakery',
    ),
    Shop(
      id: 'sample-5',
      name: 'Green Leaf Café',
      address: '21 Wellness Avenue',
      contact: '+27 82 555 7890',
      openingTime: '09:00',
      closingTime: '21:00',
      rating: 4.9,
      imageUrls: ['assets/images/shop_images/Grean Leaf Cafe/Latte.jpg'],
      category: 'Healthy',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final shopRepository = ShopRepository();
    return Column(
      children: [
        // Category Filter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return FilterChip(
                  selected: isSelected,
                  label: Text(category),
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
        // Shops List
        Expanded(
          child: StreamBuilder<List<Shop>>(
            stream: shopRepository.getShops(),
            builder: (context, snapshot) {
              final bool useSampleShops =
                  snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty;
              final shops = useSampleShops ? _sampleShops : snapshot.data!;
              final filteredShops = selectedCategory == 'All'
                  ? shops
                  : shops
                        .where((shop) => shop.category == selectedCategory)
                        .toList();

              if (filteredShops.isEmpty) {
                return Center(
                  child: Text('No shops found for "$selectedCategory"'),
                );
              }

              return Column(
                children: [
                  if (useSampleShops)
                    Container(
                      width: double.infinity,
                      color: Colors.yellow[100],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      itemCount: filteredShops.length,
                      itemBuilder: (context, index) {
                        final shop = filteredShops[index];
                        return _buildShopCard(context, shop);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopCard(BuildContext context, Shop shop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailsScreen(shop: shop),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                color: Colors.grey[300],
              ),
              child: shop.imageUrls.isNotEmpty
                  ? Image.network(shop.imageUrls.first, fit: BoxFit.cover)
                  : Icon(Icons.fastfood, size: 60, color: Colors.grey[500]),
            ),
            // Shop Details
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shop.isStatusAdActive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BusinessStatusAdCard(shop: shop),
                    ),
                  // Shop Name and Category Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          shop.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          shop.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Hours
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${shop.openingTime} - ${shop.closingTime}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Rating and Contact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.amber[700]),
                          const SizedBox(width: 5),
                          Text(
                            shop.rating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // Copy contact or dial
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Contact: ${shop.contact}')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.phone, size: 14, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Call',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
