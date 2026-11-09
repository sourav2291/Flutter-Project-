// screens/login_screen.dart

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/glass_card.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool obscurePassword = true;
  bool isLoading = false;

  final siteController = TextEditingController(
    text: "https://solar.m.frappe.cloud",
  );

  final userController = TextEditingController();
  final passController = TextEditingController();

  late AnimationController _animationController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();

    siteController.dispose();
    userController.dispose();
    passController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    print("===== LOGIN BUTTON CLICKED =====");
    print("Site: ${siteController.text.trim()}");
    print("Email: ${userController.text.trim()}");
    print("Password Length: ${passController.text.length}");

    if (userController.text.trim().isEmpty ||
        passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Email and Password"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    print("Calling AuthService...");

    bool success = await AuthService().login(
      site: siteController.text.trim(),
      username: userController.text.trim(),
      password: passController.text,
    );

    print("Login Success: $success");

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A1F),

      body: Stack(
        children: [
          _buildAnimatedBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),

                child: Column(
                  children: [
                    _buildLogo(),

                    const SizedBox(height: 20),

                    _buildLoginCard(),

                    const SizedBox(height: 25),

                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,

          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),

            shape: BoxShape.circle,

            border: Border.all(
              color: const Color(0xFF7EE787).withValues(alpha: 0.45),
              width: 2,
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DB954).withValues(alpha: 0.30),
                blurRadius: 30,
                spreadRadius: 3,
              ),
            ],
          ),

          child: Image.asset('assets/Madathilogo.png', fit: BoxFit.contain),
        ),

        const SizedBox(height: 15),

        const Text(
          "Madathil Solar ERP",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Powering a brighter and greener future",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard() {
    return GlassCard(
      radius: 28,
      blur: 18,
      opacity: 0.13,
      tint: Colors.white,

      padding: const EdgeInsets.all(22),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------
          const Text(
            "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Sign in to continue to your ERP",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 25),

          // ------------------------------------------------------
          // EMAIL
          // ------------------------------------------------------
          _buildField(
            controller: userController,
            label: "Email",
            hint: "Enter your email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------------
          // PASSWORD
          // ------------------------------------------------------
          _buildField(
            controller: passController,
            label: "Password",
            hint: "Enter your password",
            icon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },

              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,

                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ------------------------------------------------------
          // LOGIN BUTTON
          // ------------------------------------------------------
          _buildLoginButton(),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // SECURITY TEXT
          // ------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: const Color(0xFF7EE787).withValues(alpha: 0.75),
              ),

              const SizedBox(width: 6),

              Text(
                "Secure ERP Login",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 7),

        Container(
          height: 56,

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),

            borderRadius: BorderRadius.circular(17),

            border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
          ),

          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),

            cursorColor: const Color(0xFF7EE787),

            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF7EE787), size: 21),

              suffixIcon: suffix,

              hintText: hint,

              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
              ),

              border: InputBorder.none,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,

      child: ElevatedButton(
        onPressed: isLoading ? null : login,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),

          disabledBackgroundColor: const Color(
            0xFF1DB954,
          ).withValues(alpha: 0.35),

          foregroundColor: Colors.white,

          elevation: 0,

          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: isLoading
            ? const SizedBox(
                width: 23,
                height: 23,

                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Icon(Icons.login_rounded, size: 21),

                  const SizedBox(width: 9),

                  const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.wb_sunny_outlined,
              color: Color(0xFFFFD166),
              size: 17,
            ),

            const SizedBox(width: 7),

            Text(
              "Solar Business Management",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.40),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          "Madathil Solar ERP",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ANIMATED BACKGROUND
  // ============================================================

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,

      builder: (context, child) {
        final value = _animationController.value;

        return Stack(
          children: [
            // ----------------------------------------------------
            // MAIN BACKGROUND
            // ----------------------------------------------------
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Color(0xFF041A1F),
                    Color(0xFF073D3A),
                    Color(0xFF0B5E4D),
                    Color(0xFF102F2D),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // GREEN GLOW
            // ----------------------------------------------------
            Positioned(
              top: -120 + (value * 35),
              left: -130,

              child: _buildGlow(size: 330, color: const Color(0xFF1DB954)),
            ),

            // ----------------------------------------------------
            // GOLD GLOW
            // ----------------------------------------------------
            Positioned(
              top: 170 - (value * 30),
              right: -140,

              child: _buildGlow(size: 320, color: const Color(0xFFFFD166)),
            ),

            // ----------------------------------------------------
            // GREEN BOTTOM GLOW
            // ----------------------------------------------------
            Positioned(
              bottom: -170 + (value * 25),
              left: -80,

              child: _buildGlow(size: 350, color: const Color(0xFF7EE787)),
            ),

            // ----------------------------------------------------
            // SOLAR CIRCLE
            // ----------------------------------------------------
            Positioned(
              top: 80 + (value * 15),
              right: 25,

              child: Container(
                width: 110,
                height: 110,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: const Color(0xFFFFD166).withValues(alpha: 0.08),
                    width: 2,
                  ),
                ),

                child: Center(
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 42,

                    color: const Color(0xFFFFD166).withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------
            // FLOATING LEAF
            // ----------------------------------------------------
            Positioned(
              bottom: 110 + (value * 30),
              right: 10,

              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),

                child: Icon(
                  Icons.eco_rounded,
                  size: 70,

                  color: const Color(0xFF7EE787).withValues(alpha: 0.10),
                ),
              ),
            ),

            // ----------------------------------------------------
            // SECOND LEAF
            // ----------------------------------------------------
            Positioned(
              top: 330 - (value * 25),
              left: -10,

              child: Transform.rotate(
                angle: 0.3 - (value * 0.12),

                child: Icon(
                  Icons.eco_rounded,
                  size: 55,

                  color: const Color(0xFFFFD166).withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GLOW
  // ============================================================

  Widget _buildGlow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.22),

              color.withValues(alpha: 0.07),

              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
