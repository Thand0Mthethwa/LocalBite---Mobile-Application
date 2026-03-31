import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. TOP SECTION (Header + Budget Card)
            Stack(
              clipBehavior: Clip.none, // Allows the card to overlap
              children: [
                // GREEN HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 80),
                  decoration: const BoxDecoration(
                    color: Color(0xFF388E3C),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.menu, color: Colors.white, size: 28),
                          Row(
                            children: [
                              const Icon(Icons.notifications_none, color: Colors.white),
                              const SizedBox(width: 15),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'LocalBite',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Discover and buy local food with ease.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // BUDGET CARD (Positioned to overlap)
                Positioned(
                  bottom: -60,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Circular Progress
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: CircularProgressIndicator(
                                value: 0.6, // 60% of budget spent
                                strokeWidth: 8,
                                color: Colors.orange,
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                            const Text("\$150", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Budget Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Your Food Budget", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Remaining: \$85", style: TextStyle(color: Colors.grey[600])),
                              const Text("Daily Average: \$12", style: TextStyle(color: Colors.blue, fontSize: 12)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF388E3C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Adjust", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80), // Space for the overlapping card

            // 2. MEAL RECOMMENDATIONS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Meal Recommendations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text("See All")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Horizontal List of Meals
                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildMealCard("Scrambled Eggs", "Breakfast (8:00 AM)", "8", "4.5"),
                        _buildMealCard("Lentil Soup", "Lunch (12:30 PM)", "10", "4.8"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. LOCAL DEALS SECTION
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Local Offers & Deals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildDealCard("Mama's Homemade Lasagna", "0.5 miles", "12"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Meal Cards
  Widget _buildMealCard(String name, String time, String price, String rating) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: const Center(child: Icon(Icons.fastfood, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$$price", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    Row(children: [const Icon(Icons.star, size: 12, color: Colors.orange), Text(rating, style: const TextStyle(fontSize: 12))]),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper Widget for Large Deal Cards
  Widget _buildDealCard(String title, String dist, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(height: 60, width: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_offer)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(dist, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text("\$$price", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
        ],
      ),
    );
  }
}