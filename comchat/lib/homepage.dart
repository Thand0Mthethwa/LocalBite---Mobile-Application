import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  bool _isShrunk = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Increased shrink threshold to prevent bouncing when the budget card disappears
    if (_scrollController.offset > 150 && !_isShrunk) {
      setState(() {
        _isShrunk = true;
      });
    } else if (_scrollController.offset <= 10 && _isShrunk) {
      setState(() {
        _isShrunk = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100], 
      child: Column(
        children: [
          // 1. CUSTOM HEADER (Matches your Mockup)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 50, 
              left: 20, 
              right: 20, 
              bottom: _isShrunk ? 20 : 60,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/Plate.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), // Dark overlay for text readability
                  BlendMode.darken,
                ),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_isShrunk ? 20 : 40),
                bottomRight: Radius.circular(_isShrunk ? 20 : 40),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isShrunk ? 10 : 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isShrunk ? 24 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                      child: const Text('LocalBite'),
                    ),
                    if (!_isShrunk)
                      const Text(
                        'Discover and buy local food with ease.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 2. SCROLLABLE CONTENT AREA
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(0, _isShrunk ? 0 : -40, 0),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOOD BUDGET CARD
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isShrunk
                          ? const SizedBox(width: double.infinity)
                          : Column(
                              children: [
                                _buildBudgetCard(),
                                const SizedBox(height: 25),
                              ],
                            ),
                    ),
                    
                    _buildSectionHeader("Meal Recommendations"),
                    const SizedBox(height: 15),
                    _buildMealList(),

                    const SizedBox(height: 25),
                    _buildSectionHeader("Local Offers & Deals"),
                    const SizedBox(height: 15),
                    _buildLocalDeals(),
                    
                    // Extra space at the bottom to ensure smooth scrolling without bouncing
                    const SizedBox(height: 100),
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
                const Text("\R150", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Food Budget", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Remaining: \R85", style: TextStyle(color: Colors.grey[600])),
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
    final List<Map<String, String>> meals = [
      {
        "name": "Combo Meal",
        "price": "R45.00",
        "image": "assets/images/Combo Meal.jfif"
      },
      {
        "name": "Braai Platter",
        "price": "R120.00",
        "image": "assets/images/Braai Platter.jfif"
      },
      {
        "name": "Boerewors Rolls",
        "price": "R30.00",
        "image": "assets/images/Boerewors Rolls.jfif"
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.asset(
                      meal["image"]!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(meal["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(meal["price"]!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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