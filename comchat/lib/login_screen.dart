import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  late final AnimationController _motionController;
  late final AnimationController _pulseController;

  final _rng = Random();
  final List<_Sphere> _spheres = [];

  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Create a larger set of decorative spheres with random positions and sizes
    // Increasing the count and variation gives a richer background.
    final sphereCount = 14;
    for (var i = 0; i < sphereCount; i++) {
      _spheres.add(_Sphere(
        offset: Offset(_rng.nextDouble(), _rng.nextDouble()),
        // sizes from ~40px up to ~180px for variation
        size: 40 + _rng.nextDouble() * 140,
        // vary speed so some move slower and some faster
        speedFactor: 0.3 + _rng.nextDouble() * 1.6,
        phase: _rng.nextDouble() * pi * 2,
        colorSeed: i,
      ));
    }

    // trigger a small pulse on appear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pulseController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _motionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.message}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created and signed in')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.message}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out')),
    );
  }

  void _pulse() {
    _pulseController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _pulse,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Stack(
          children: [
            // Animated spheres background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_motionController, _pulseController]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SpheresPainter(
                      spheres: _spheres,
                      motionValue: _motionController.value,
                      pulseValue: Curves.elasticOut.transform(_pulseController.value),
                      theme: theme,
                    ),
                  );
                },
              ),
            ),

            // Centered login card
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        if (user != null) ...[
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user.email ?? user.uid),
                            subtitle: const Text('You are signed in'),
                            trailing: TextButton(
                              onPressed: _signOut,
                              child: const Text('Sign out'),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _signIn,
                          child: _loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sign in'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _loading ? null : _register,
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sphere {
  final Offset offset; // 0..1 fractional offset
  final double size;
  final double speedFactor;
  final double phase;
  final int colorSeed;

  _Sphere({
    required this.offset,
    required this.size,
    required this.speedFactor,
    required this.phase,
    required this.colorSeed,
  });
}

class _SpheresPainter extends CustomPainter {
  final List<_Sphere> spheres;
  final double motionValue; // 0..1
  final double pulseValue; // 0..1
  final ThemeData theme;

  _SpheresPainter({
    required this.spheres,
    required this.motionValue,
    required this.pulseValue,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var s in spheres) {
      final dx = (sin((motionValue * 2 * pi * s.speedFactor) + s.phase) * 0.03) * size.width;
      final dy = (cos((motionValue * 2 * pi * s.speedFactor) + s.phase) * 0.03) * size.height;

      final cx = s.offset.dx * size.width + dx;
      final cy = s.offset.dy * size.height + dy;

      final scale = 1.0 + 0.15 * pulseValue * (1.0 - (s.speedFactor - 0.5) / 2.0);
      final radius = (s.size * 0.5) * scale;

      paint.color = _colorForSeed(s.colorSeed).withOpacity(0.14 + 0.06 * pulseValue);
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  Color _colorForSeed(int seed) {
    // pick harmonious colors tied to theme
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.primary.withOpacity(0.9),
      theme.colorScheme.secondary.withOpacity(0.9),
    ];
    return colors[seed % colors.length];
  }

  @override
  bool shouldRepaint(covariant _SpheresPainter old) {
    return old.motionValue != motionValue || old.pulseValue != pulseValue || old.spheres != spheres;
  }
}

