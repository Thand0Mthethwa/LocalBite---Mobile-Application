import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100], 
      child: Column(
        children: [
          // 1. CUSTOM HEADER (Matches your Mockup)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 60),
            decoration: const BoxDecoration(
              color: Color(0xFF388E3C), // Rich Green
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
                const SizedBox(height: 30),
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

          // 2. SCROLLABLE CONTENT AREA
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -30), // Pulls the content up to overlap the header
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOOD BUDGET CARD
                    _buildBudgetCard(),
                    
                    const SizedBox(height: 25),
                    _buildSectionHeader("Meal Recommendations"),
                    const SizedBox(height: 15),
                    _buildMealList(),

                    const SizedBox(height: 25),
                    _buildSectionHeader("Local Offers & Deals"),
                    const SizedBox(height: 15),
                    _buildLocalDeals(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENT WIDGETS ---

  Widget _buildBudgetCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: 0.6, // 60% of budget used
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    color: Colors.orange,
                  ),
                ),
                const Text("\$150", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Food Budget", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Remaining: \$85", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      shape: StadiumBorder(),
                    ),
                    child: const Text("Adjust Budget", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("See All", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMealList() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Healthy Wrap", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("\$8.50", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocalDeals() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Neighbor's Special", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Get 20% off on all home-cooked meals today!"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}