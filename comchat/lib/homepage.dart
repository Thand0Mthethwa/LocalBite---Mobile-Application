import 'package:flutter/material.dart';
import 'package:comchat/meal_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  bool _isShrunk = false;
  double _budgetTotal = 150.0;
  double _spent = 65.0; // For now, hardcoded spent
  String _userName = 'Guest User';
  String _userEmail = 'guest@example.com';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBudget();
    _loadUserProfile();
    _loadSpentAmount();
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

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budgetTotal = prefs.getDouble('budgetTotal') ?? 150.0;
    });
  }

  Future<void> _loadSpentAmount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _spent = prefs.getDouble('spentAmount') ?? 65.0;
    });
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Guest User';
      _userEmail = prefs.getString('userEmail') ?? 'guest@example.com';
    });
  }

  Future<void> _saveUserProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  Future<void> _saveBudget(double newBudget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budgetTotal', newBudget);
    setState(() {
      _budgetTotal = newBudget;
    });
  }

  void _adjustBudget() {
    final TextEditingController controller = TextEditingController(
      text: _budgetTotal.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Budget (R)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newBudget =
                  double.tryParse(controller.text) ?? _budgetTotal;
              _saveBudget(newBudget);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _editProfileDetails() {
    final TextEditingController nameController = TextEditingController(
      text: _userName,
    );
    final TextEditingController emailController = TextEditingController(
      text: _userEmail,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _saveUserProfile(nameController.text, emailController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editProfilePicture() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: const Text(
          'You can add functionality here to pick an image from your gallery or take a photo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(),
      body: Column(
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
                image: const AssetImage('assets/images/Boerewors Rolls.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(
                    0.5,
                  ), // Dark overlay for text readability
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

                    _buildSectionHeader("Your Local Favorites"),
                    const SizedBox(height: 15),
                    _buildMealList(),

                    // I want the boxes to have space for another section below, so I added extra space at the bottom of the scroll view to prevent bouncing when the user scrolls to the end of the list. This way, they can see the last item without it bouncing back up.
                    const SizedBox(height: 100),

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
    final remaining = _budgetTotal - _spent;
    final progress = _spent / _budgetTotal;
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
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    color: Colors.orange,
                  ),
                ),
                Text(
                  '\R${_budgetTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Food Budget",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Remaining: \R${remaining.toStringAsFixed(0)}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _adjustBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      "Adjust Budget",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        const Text(
          "See All",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
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
        "description":
            "A perfect combination of your favorite local dishes including pap, wors, and chakalaka. Served with a side of vegetables.",
        "quantity": "15 servings",
        "additionalInfo":
            "This combo meal is our most popular item, made fresh daily with locally sourced ingredients. Great for lunch or dinner.",
      },
      {
        "name": "Braai Platter",
        "price": "R120.00",
        "image": "assets/images/Braai Platter.jfif",
        "description":
            "A generous platter featuring grilled meats, boerewors, chicken, and lamb chops. Served with pap and tomato relish.",
        "quantity": "8 servings",
        "additionalInfo":
            "Our signature braai platter is perfect for family gatherings or special occasions. All meats are marinated and grilled to perfection.",
      },
      {
        "name": "Boerewors Rolls",
        "price": "R30.00",
        "image": "assets/images/Boerewors Rolls.jfif",
        "description":
            "Fresh boerewors sausage grilled and served in a soft roll with onions, tomato, and our special sauce.",
        "quantity": "20 rolls",
        "additionalInfo":
            "Made with traditional South African boerewors recipe. These rolls are a quick and tasty snack option.",
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
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF388E3C)),
            accountName: Text(_userName),
            accountEmail: Text(_userEmail),
            currentAccountPicture: GestureDetector(
              onTap: _editProfilePicture,
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Credentials'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _editProfileDetails();
            },
          ),
        ],
      ),
    );
  }
}
