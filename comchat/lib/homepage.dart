import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:comchat/meal_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  bool _isShrunk = false;
  double _budgetTotal = 150.0;
  double _spent = 65.0;
  String _userName = 'Guest User';
  String _userEmail = 'guest@example.com';
  List<double> _dailySpends = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBudget();
    _loadUserProfile();
    _loadSpentAmount();
    _loadDailySpends();
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

  Future<void> _loadDailySpends() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().weekday - 1;

    setState(() {
      _dailySpends = List<double>.generate(7, (index) {
        return prefs.getDouble('dailySpend_$index') ?? 0.0;
      });

      if (_dailySpends[today] == 0 && _spent > 0) {
        _dailySpends[today] = _spent;
      }
    });
  }

  Future<void> _recordSpending(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().weekday - 1;

    final currentDaySpend = prefs.getDouble('dailySpend_$today') ?? 0.0;
    final newDaySpend = currentDaySpend + amount;

    setState(() {
      _dailySpends[today] = newDaySpend;
      _spent = _dailySpends.reduce((a, b) => a + b);
    });

    await prefs.setDouble('dailySpend_$today', newDaySpend);
    await prefs.setDouble('spentAmount', _spent);
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

    final today = DateTime.now().weekday - 1;
    final difference = newBudget - _budgetTotal;
    _dailySpends[today] = (_dailySpends[today] + difference).clamp(
      0,
      double.infinity,
    );

    setState(() {
      _budgetTotal = newBudget;
      _spent = _dailySpends.reduce((a, b) => a + b);
    });

    await prefs.setDouble('dailySpend_$today', _dailySpends[today]);
    await prefs.setDouble('spentAmount', _spent);
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
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
              bottom: _isShrunk ? 20 : 42,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.96),
                  AppColors.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_isShrunk ? 24 : 36),
                bottomRight: Radius.circular(_isShrunk ? 24 : 36),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isShrunk ? 10 : 16,
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isShrunk ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                  child: const Text('LocalBite'),
                ),
                if (!_isShrunk) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Crave it? Order it fresh from nearby cooks.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search meals or stalls',
                        hintStyle: const TextStyle(color: AppColors.muted),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      style: const TextStyle(color: AppColors.onSurface),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(0, _isShrunk ? 0 : -26, 0),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isShrunk
                          ? const SizedBox(width: double.infinity)
                          : Column(
                              children: [
                                _buildBudgetCard(),
                                const SizedBox(height: 16),
                              ],
                            ),
                    ),
                    _buildSectionHeader('Meal Recommendations'),
                    const SizedBox(height: 12),
                    _buildMealList(),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Your Local Favorites'),
                    const SizedBox(height: 12),
                    _buildMealList(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Local Offers & Deals'),
                    const SizedBox(height: 12),
                    _buildLocalDeals(),
                    const SizedBox(height: 80),
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
    final theme = Theme.of(context);
    final maxSpend = _dailySpends.isEmpty
        ? 1.0
        : (_dailySpends.reduce((a, b) => a > b ? a : b) as double).clamp(
            1.0,
            double.infinity,
          );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.4),
                  color: Colors.white,
                ),
              ),
              Text(
                '${((progress * 100).clamp(0.0, 100.0)).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Budget Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This week\'s spend',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'R${_spent.toStringAsFixed(0)} / R${_budgetTotal.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Left: R${remaining.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: _adjustBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB45309),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Adjust', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Weekly Bars
          _buildWeeklyBars(_dailySpends, maxSpend, progress),
        ],
      ),
    );
  }

  Widget _buildWeeklyBars(
    List<double> weeklySpends,
    double maxSpend,
    double progress,
  ) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1;

    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Row(
            children: List.generate(weeklySpends.length, (index) {
              final value = weeklySpends[index];
              final height = (value / maxSpend).clamp(0.2, 1.0) * 56;
              final isToday = index == today;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        height: 62,
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 10,
                          height: height,
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white70,
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Text(
              'Weekly trend ${((progress * 100).clamp(0.0, 100.0)).toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const Text(
          'See All',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMealList() {
    final theme = Theme.of(context);
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
      height: 220,
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
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.warmCream, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.warmCream,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Image.asset(meal['image']!, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                    child: Text(
                      meal['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      meal['price']!,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        const Text('4.8', style: TextStyle(fontSize: 12)),
                      ],
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Neighbor's Special",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text('Get 20% off on all home-cooked meals today!'),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.96),
                  AppColors.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
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
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: const Text('Edit Credentials'),
            onTap: () {
              Navigator.pop(context);
              _editProfileDetails();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.secondary),
            title: const Text('Sign out'),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
