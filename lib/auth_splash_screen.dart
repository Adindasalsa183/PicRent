import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homepage.dart'; // Diubah untuk mengarahkan ke HomePage

class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen>
    with TickerProviderStateMixin {
  // PALET WARNA
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFDDD6FE);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  // ANIMASI CONTROLLER
  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _bgController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;

  // FORM CONTROLLER
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  // URL BACKEND LARAVEL (OTOMATIS SESUAI PLATFORM)
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _cardOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _cardScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FUNGSI SUBMIT FORM KE LARAVEL API (PHP)
  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final inputEmail = _emailController.text.trim();
    final inputPassword = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    final endpoint = _isLogin ? '/login' : '/register';
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': inputEmail,
          'password': inputPassword,
          'name': inputEmail.split('@')[0], // Mengisi kolom name otomatis
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        if (!_isLogin) {
          // JIKA BERHASIL DAFTAR (DATA BERHASIL MASUK KE MYSQL DATABASE)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pendaftaran berhasil & masuk ke database! Silakan klik Masuk Sekarang.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: primaryPurple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          setState(() {
            _isLogin = true; // Pindah tab ke Masuk
          });
        } else {
          // JIKA BERHASIL LOGIN -> PINDAH KELANGSUNG KE HOMEPAGE
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Berhasil masuk! Selamat datang.'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(), // Diubah ke HomePage
            ),
          );
        }
      } else {
        if (!mounted) return;
        String errorMessage = data['message'] ?? 'Terjadi kesalahan';
        if (data['errors'] != null) {
          errorMessage = data['errors'].toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung ke Laravel API. Pastikan php artisan serve jalan! ($e)'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        final glowBlur = 20.0 + (pulseValue * 15.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [primaryPurple, Color(0xFF9333EA), cyanAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.35 + (pulseValue * 0.15)),
                    blurRadius: glowBlur,
                    spreadRadius: 2 + (pulseValue * 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: lightPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.face_5_rounded,
                          size: 40,
                          color: primaryPurple,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryPurple,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'pic',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'rent',
                    style: TextStyle(
                      color: primaryPurple,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'CAPTURE THE WORLD',
              style: TextStyle(
                color: textGray.withOpacity(0.8),
                fontSize: 10,
                letterSpacing: 4.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final val = _bgController.value * 2 * math.pi;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -60 + math.sin(val) * 25,
              right: -70 + math.cos(val) * 25,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lightPurple.withOpacity(0.4),
                ),
              ),
            ),
            Positioned(
              bottom: -90 + math.cos(val) * 30,
              left: -80 + math.sin(val) * 30,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cyanAccent.withOpacity(0.12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: primaryPurple,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryPurple,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.8,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabItem('Masuk', true),
          _buildTabItem('Daftar', false),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isLoginTab) {
    final isSelected = _isLogin == isLoginTab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isLogin = isLoginTab;
            _formKey.currentState?.reset();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [primaryPurple, Color(0xFF9333EA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : textGray,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabs(),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Column(
              key: ValueKey(_isLogin),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLogin ? 'Selamat Datang!' : 'Buat Akun Baru',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLogin
                      ? 'Masuk untuk mulai sewa kamera favoritmu.'
                      : 'Daftar sekarang dan temukan perlengkapan motretmu.',
                  style: const TextStyle(
                    color: textGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Alamat Email',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Email wajib diisi.';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Format email tidak valid.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Kata Sandi',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitForm(),
            decoration: _inputDecoration(
              hint: 'Masukkan kata sandi',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) return 'Password wajib diisi.';
              if (password.length < 8) return 'Password minimal 8 karakter.';
              return null;
            },
          ),
          if (_isLogin) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _rememberMe = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ingat saya',
                  style: TextStyle(
                    fontSize: 12,
                    color: textGray,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: primaryPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryPurple, Color(0xFF9333EA), cyanAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? 'Masuk Sekarang' : 'Daftar Akun',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 440 : 460,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: SlideTransition(
                          position: _logoSlide,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _buildLogo(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight < 700 ? 20 : 32,
                      ),
                      FadeTransition(
                        opacity: _cardOpacity,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: ScaleTransition(
                            scale: _cardScale,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isDesktop ? 32 : 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withOpacity(0.12),
                                    blurRadius: 40,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: _buildForm(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _cardOpacity,
                        child: Text(
                          '© 2026 PICRENT • PREMIUM EXPERIENCE',
                          style: TextStyle(
                            color: textGray.withOpacity(0.6),
                            fontSize: 9,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}