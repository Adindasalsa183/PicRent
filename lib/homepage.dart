import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController(viewportFraction: 0.91);
  Timer? _bannerTimer;

  static const Color primary = Color(0xFF6D4AFF);
  static const Color primaryDark = Color(0xFF30205F);
  static const Color lavender = Color(0xFFF0EBFF);
  static const Color background = Color(0xFFF8F8FC);
  static const Color textDark = Color(0xFF19172A);
  static const Color textMuted = Color(0xFF858397);

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Capture every\nbeautiful moment',
      'subtitle': 'Sewa kamera premium dengan harga terbaik.',
      'badge': 'SPECIAL OFFER',
      'image':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=1200',
    },
    {
      'title': 'Your graduation,\nyour story',
      'subtitle': 'Abadikan momen wisuda dengan hasil terbaik.',
      'badge': 'BEST SELLER',
      'image':
          'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=1200',
    },
    {
      'title': 'Create something\nextraordinary',
      'subtitle': 'Paket kamera untuk content creator.',
      'badge': 'CREATOR PACKAGE',
      'image':
          'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?q=80&w=1200',
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {'title': 'Wisuda', 'icon': Icons.school_rounded, 'color': Color(0xFF8065F6)},
    {'title': 'Pre-Wedding', 'icon': Icons.favorite_rounded, 'color': Color(0xFFE66A9B)},
    {'title': 'Wedding', 'icon': Icons.groups_rounded, 'color': Color(0xFFD49A45)},
    {'title': 'Content', 'icon': Icons.videocam_rounded, 'color': Color(0xFF42A8B8)},
  ];

  final List<Map<String, dynamic>> _cameras = [
    {
      'name': 'Sony Alpha A7 IV',
      'type': 'MIRRORLESS • FULL FRAME',
      'price': '350.000',
      'rating': '4.9',
      'image':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=900',
      'tag': 'Popular',
    },
    {
      'name': 'Canon EOS R6 Mark II',
      'type': 'MIRRORLESS • FULL FRAME',
      'price': '380.000',
      'rating': '4.8',
      'image':
          'https://images.unsplash.com/photo-1607462109225-6b64ae2dd3cb?q=80&w=900',
      'tag': 'Top rated',
    },
    {
      'name': 'Fujifilm X-T5',
      'type': 'MIRRORLESS • APS-C',
      'price': '280.000',
      'rating': '4.9',
      'image':
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?q=80&w=900',
      'tag': 'Best value',
    },
    {
      'name': 'Sony FX3 Cinema',
      'type': 'CINEMA CAMERA • 4K',
      'price': '650.000',
      'rating': '5.0',
      'image':
          'https://images.unsplash.com/photo-1589872783425-bea785181745?q=80&w=900',
      'tag': 'Pro choice',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildHomeTab(),
            _buildSimpleTab(
              icon: Icons.camera_alt_outlined,
              title: 'Sewa Saya',
              subtitle: 'Pesanan sewa kamera kamu akan tampil di sini.',
            ),
            _buildSimpleTab(
              icon: Icons.favorite_border_rounded,
              title: 'Favorit',
              subtitle: 'Simpan kamera favoritmu untuk ditemukan lagi.',
            ),
            _buildAccountTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildBannerSlider()),
        SliverToBoxAdapter(child: _buildServiceSection()),
        SliverToBoxAdapter(child: _buildSectionHeader('Kamera pilihan', 'Lihat semua')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCameraCard(_cameras[index]),
              childCount: _cameras.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B73FF), primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PICRENT', style: TextStyle(fontSize: 11, letterSpacing: 2.2,
                    fontWeight: FontWeight.w800, color: primary)),
                SizedBox(height: 3),
                Text('Hello, PicRent User ✨', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: textDark)),
              ],
            ),
          ),
          _roundIconButton(Icons.notifications_none_rounded, () {
            _showMessage('Notifikasi belum tersedia.');
          }),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: textDark, size: 21),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFEDEBF4)),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16),
            Icon(Icons.search_rounded, color: textMuted, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text('Cari kamera, lensa, atau layanan...',
                  style: TextStyle(fontSize: 12, color: textMuted)),
            ),
            Icon(Icons.tune_rounded, color: primary, size: 20),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 205,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentBannerIndex = index);
            },
            itemBuilder: (context, index) {
              final item = _banners[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(item['image'], fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: primaryDark)),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xE62B1C52), Color(0x442B1C52), Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.25)),
                              ),
                              child: Text(item['badge'],
                                style: const TextStyle(color: Colors.white,
                                  fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(height: 12),
                            Text(item['title'],
                              style: const TextStyle(color: Colors.white, fontSize: 23,
                                height: 1.12, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 210,
                              child: Text(item['subtitle'],
                                style: TextStyle(color: Colors.white.withOpacity(0.85),
                                  fontSize: 11, height: 1.4)),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Text('Explore now', style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w700, fontSize: 11)),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final selected = index == _currentBannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected ? primary : const Color(0xFFD9D5E7),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jelajahi layanan',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                        letterSpacing: -0.4, color: textDark)),
                    SizedBox(height: 4),
                    Text('Temukan yang sesuai dengan momenmu',
                      style: TextStyle(fontSize: 11, color: textMuted)),
                  ],
                ),
              ),
              _sectionAction('Semua'),
            ],
          ),
        ),
        SizedBox(
          height: 116,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final service = _services[index];
              final color = service['color'] as Color;
              return SizedBox(
                width: 88,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showMessage('Layanan ${service['title']}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEDEAF5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(service['icon'], color: color, size: 23),
                          ),
                          const SizedBox(height: 9),
                          Text(service['title'],
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5,
                              fontWeight: FontWeight.w700, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionAction(String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showMessage('$label belum tersedia.'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: primary, fontSize: 11,
              fontWeight: FontWeight.w700)),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 19,
                  letterSpacing: -0.4, fontWeight: FontWeight.w800, color: textDark)),
                const SizedBox(height: 4),
                const Text('Pilihan terbaik untuk kebutuhan fotografimu',
                  style: TextStyle(fontSize: 11, color: textMuted)),
              ],
            ),
          ),
          _sectionAction(action),
        ],
      ),
    );
  }

  Widget _buildCameraCard(Map<String, dynamic> camera) {
    final imageUrl = camera['image'] as String? ?? '';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showMessage('Detail ${camera['name']}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDEAF4)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF30205F).withOpacity(0.035),
                blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFFF1EFF7),
                        child: imageUrl.isEmpty
                            ? const Center(child: Icon(Icons.camera_alt_rounded,
                                color: primary, size: 38))
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.camera_alt_rounded,
                                    color: primary, size: 38)),
                              ),
                      ),
                      Positioned(
                        top: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(camera['tag'] as String? ?? 'Featured',
                            style: const TextStyle(fontSize: 9, color: primaryDark,
                              fontWeight: FontWeight.w800)),
                        ),
                      ),
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFB547), size: 13),
                              const SizedBox(width: 3),
                              Text(camera['rating'] as String? ?? '4.8',
                                style: const TextStyle(fontSize: 10,
                                  fontWeight: FontWeight.w800, color: textDark)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(camera['type'] as String? ?? 'CAMERA',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 8, letterSpacing: 0.6,
                                color: textMuted, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 5),
                            Text(camera['name'] as String? ?? 'Camera',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5,
                                fontWeight: FontWeight.w800, color: textDark)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rp ${camera['price'] ?? '0'}',
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12,
                                      color: primary, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  const Text('per hari',
                                    style: TextStyle(fontSize: 9, color: textMuted)),
                                ],
                              ),
                            ),
                            Container(
                              width: 31, height: 31,
                              decoration: BoxDecoration(color: primary,
                                borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 19),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: lavender,
                borderRadius: BorderRadius.circular(28)),
              child: Icon(icon, color: primary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22,
              fontWeight: FontWeight.w800, color: textDark)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center,
              style: const TextStyle(color: textMuted, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 25),
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF9B87FF), primary]),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 43),
          ),
          const SizedBox(height: 14),
          const Text('PicRent User', style: TextStyle(fontSize: 21,
            fontWeight: FontWeight.w800, color: textDark)),
          const SizedBox(height: 5),
          const Text('user@email.com', style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 30),
          _accountMenu(Icons.receipt_long_rounded, 'Riwayat Transaksi'),
          _accountMenu(Icons.favorite_border_rounded, 'Favorit Saya'),
          _accountMenu(Icons.settings_outlined, 'Pengaturan Akun'),
          _accountMenu(Icons.help_outline_rounded, 'Pusat Bantuan'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showMessage('Silakan hubungkan logout dengan autentikasi.'),
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text('Keluar Akun', style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Color(0xFFF2DADA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountMenu(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EEF6))),
      child: ListTile(
        leading: Icon(icon, color: primary),
        title: Text(title, style: const TextStyle(fontSize: 13,
          fontWeight: FontWeight.w600, color: textDark)),
        trailing: const Icon(Icons.chevron_right_rounded, color: textMuted),
        onTap: () => _showMessage('$title belum tersedia.'),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    const labels = ['Home', 'Rental', 'Wishlist', 'Profile'];
    const icons = [
      Icons.home_rounded,
      Icons.camera_alt_rounded,
      Icons.favorite_rounded,
      Icons.person_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF0EEF5))),
        boxShadow: [
          BoxShadow(color: const Color(0xFF21164A).withOpacity(0.045),
            blurRadius: 18, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
          child: Row(
            children: List.generate(labels.length, (index) {
              final active = _currentNavIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentNavIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFF1EDFF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 34 : 28,
                          height: 27,
                          decoration: BoxDecoration(
                            color: active ? primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(icons[index],
                            size: 18, color: active ? Colors.white : const Color(0xFF9290A2)),
                        ),
                        const SizedBox(height: 4),
                        Text(labels[index],
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.1,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                            color: active ? primary : const Color(0xFF9290A2),
                          )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryDark,
      ));
  }
}
