import 'package:flutter/material.dart';
import 'auth_splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;
  bool _isNavigating = false;

  // Palet warna PicRent.
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFDDD6FE);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  // Data untuk setiap halaman onboarding.
  final List<Map<String, dynamic>> _slides = [
    {
      'type': 'photographer',
      'title': 'Temukan Kamera Impianmu',
      'subtitle': 'RENTAL PROFESIONAL',
      'description':
          'Jelajahi berbagai pilihan kamera DSLR, mirrorless, dan lensa kelas atas untuk kebutuhan foto maupun videografimu.',
      'badgeColor': const Color(0xFF8B5CF6),
    },
    {
      'type': 'express',
      'title': 'Sewa Cepat & Praktis',
      'subtitle': 'PROSES INSTAN',
      'description':
          'Nikmati kemudahan sewa peralatan fotografi tanpa jaminan ribet. Siap digunakan kapan saja untuk petualanganmu.',
      'badgeColor': const Color(0xFFEC4899),
    },
    {
      'type': 'traveler',
      'title': 'Abadikan Setiap Karya',
      'subtitle': 'HASIL MAKSIMAL',
      'description':
          'Jadikan setiap perjalanan dan momen berhargamu menjadi hasil visual sinematik yang luar biasa bersama PicRent.',
      'badgeColor': const Color(0xFF06B6D4),
    },
  ];

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _navigateToLogin() {
    if (_isNavigating || !mounted) return;

    _isNavigating = true;
    Navigator.of(context)
        .pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthSplashScreen(),
      ),
    )
        .then((_) {
      _isNavigating = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Ilustrasi kartun untuk masing-masing halaman.
  Widget _buildCartoonIllustration(String type, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran cahaya di belakang ilustrasi.
          Container(
            width: size * 0.88,
            height: size * 0.88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFEDE9FE),
                  Color(0xFFF5F3FF),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Dekorasi lingkaran kecil.
          Positioned(
            top: size * 0.08,
            left: size * 0.10,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: lightPurple,
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.12,
            right: size * 0.08,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryPurple.withOpacity(0.20),
              ),
            ),
          ),

          // Ilustrasi fotografer.
          if (type == 'photographer')
            _buildIllustrationCard(
              color: primaryPurple,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 18,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDD6FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_5_rounded,
                        size: 46,
                        color: primaryPurple,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                          SizedBox(width: 7),
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.amberAccent,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )

          // Ilustrasi proses sewa cepat.
          else if (type == 'express')
            _buildIllustrationCard(
              color: const Color(0xFFEC4899),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 22,
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE7F3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 43,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 28,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: Colors.amber,
                          size: 23,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'QUICK RENT',
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )

          // Ilustrasi traveler.
          else
            _buildIllustrationCard(
              color: const Color(0xFF06B6D4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: const BoxDecoration(
                      color: Color(0xFFCFFAFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      size: 46,
                      color: Color(0xFF0891B2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.collections_rounded,
                    size: 28,
                    color: primaryPurple,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Kartu putih untuk ilustrasi.
  Widget _buildIllustrationCard({
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: 155,
      height: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  // Konten satu halaman onboarding.
  Widget _buildSlide(Map<String, dynamic> item, double width) {
    final double illustrationSize =
        (width * 0.75).clamp(230.0, 320.0).toDouble();

    final Color badgeColor = item['badgeColor'] as Color;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 12),
              _buildCartoonIllustration(
                item['type'] as String,
                illustrationSize,
              ),
              const SizedBox(height: 32),

              // Badge kategori.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Judul halaman.
              Text(
                item['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi halaman.
              Text(
                item['description'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textGray,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Indikator halaman.
  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _slides.length,
        (index) {
          final bool isActive = _currentIndex == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(right: 6),
            height: 7,
            width: isActive ? 22 : 7,
            decoration: BoxDecoration(
              color: isActive
                  ? primaryPurple
                  : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  // Tombol navigasi bagian bawah.
  Widget _buildBottomNavigation() {
    final bool isLastPage = _currentIndex == _slides.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Lewati atau Kembali.
          if (_currentIndex == 0)
            TextButton(
              onPressed: _navigateToLogin,
              child: const Text(
                'Lewati',
                style: TextStyle(
                  color: textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _onBack,
              child: const Text(
                'Kembali',
                style: TextStyle(
                  color: textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Indikator halaman.
          _buildPageIndicator(),

          // Tombol Lanjut atau Mulai Sekarang.
          if (isLastPage)
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    primaryPurple,
                    Color(0xFF9333EA),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mulai Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _onNext,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      primaryPurple,
                      Color(0xFF9333EA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header logo PicRent.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 12,
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.camera_alt_rounded,
                    color: primaryPurple,
                    size: 25,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'PicRent',
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel halaman onboarding.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth;

                  return PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      if (!mounted) return;
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildSlide(
                        _slides[index],
                        screenWidth,
                      );
                    },
                  );
                },
              ),
            ),

            // Navigasi bawah.
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }
}
