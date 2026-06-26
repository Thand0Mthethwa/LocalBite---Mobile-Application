import 'package:comchat/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:comchat/meal_details_screen.dart';

class GuestHomepage extends StatefulWidget {
  const GuestHomepage({super.key});

  @override
  State<GuestHomepage> createState() => _GuestHomepageState();
}

class _GuestHomepageState extends State<GuestHomepage> {
  final ScrollController _scrollController = ScrollController();
  bool _isShrunk = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
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

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(),
      body: Column(
        children: [
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
                image: const AssetImage('assets/images/Boerewors Rolls.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
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
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: _navigateToLogin,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
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
                    const SizedBox(height: 25),
                    _buildSectionHeader("Meal Recommendations"),
                    const SizedBox(height: 15),
                    _buildMealList(),
                    _buildSectionHeader("Your Local Favorites"),
                    const SizedBox(height: 15),
                    _buildMealList(),
                    const SizedBox(height: 100),
                    _buildSectionHeader("Local Offers & Deals"),
                    const SizedBox(height: 15),
                    _buildLocalDeals(),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: _navigateToLogin,
          child: const Text(
            "See All",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildMealList() {
    final List<Map<String, String>> meals = [
      {
        "name": "Combo Meal",
        "price": "R45.00",
        "image": "assets/images/Combo Meal.jfif",
        "description": "A perfect combination of your favorite local dishes including pap, wors, and chakalaka. Served with a side of vegetables.",
        "quantity": "15 servings",
        "additionalInfo": "This combo meal is our most popular item, made fresh daily with locally sourced ingredients. Great for lunch or dinner.",
      },
      {
        "name": "Braai Platter",
        "price": "R120.00",
        "image": "assets/images/Braai Platter.jfif",
        "description": "A generous platter featuring grilled meats, boerewors, chicken, and lamb chops. Served with pap and tomato relish.",
        "quantity": "8 servings",
        "additionalInfo": "Our signature braai platter is perfect for family gatherings or special occasions. All meats are marinated and grilled to perfection.",
      },
      {
        "name": "Boerewors Rolls",
        "price": "R30.00",
        "image": "assets/images/Boerewors Rolls.jfif",
        "description": "Fresh boerewors sausage grilled and served in a soft roll with onions, tomato, and our special sauce.",
        "quantity": "20 rolls",
        "additionalInfo": "Made with traditional South African boerewors recipe. These rolls are a quick and tasty snack option.",
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailsScreen(meal: meal),
                ),
              );
            },
            child: Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.asset(meal["image"]!, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      meal["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      meal["price"]!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocalDeals() {
    return GestureDetector(
      onTap: _navigateToLogin,
      child: Container(
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
                  Text(
                    "Neighbor's Special",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Get 20% off on all home-cooked meals today!"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF388E3C)),
            accountName: const Text('Guest User'),
            accountEmail: const Text(''),
            currentAccountPicture: GestureDetector(
              onTap: _navigateToLogin,
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login or Sign Up'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _navigateToLogin();
            },
          ),
        ],
      ),
    );
  }
}
