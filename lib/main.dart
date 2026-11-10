
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'onboarding_screen.dart';
import 'auth_splash_screen.dart';

void main() {
  runApp(const PicRentApp());
}

// ============================================================
// APP
// ============================================================

class PicRentApp extends StatelessWidget {
  const PicRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PicRent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8FC),
          foregroundColor: Color(0xFF111827),
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),

      // ONBOARDING MUNCUL PERTAMA
      home: const OnboardingScreen(),
    );
  }
}

// ============================================================
// MODEL KAMERA
// ============================================================

class Item {
  final int id;
  final String name;
  final String description;
  final num price;
  final String? imageUrl;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final dynamic rawPrice =
        json['price'] ?? json['harga'] ?? 0;

    num parsedPrice = 0;

    if (rawPrice is num) {
      parsedPrice = rawPrice;
    } else {
      parsedPrice = num.tryParse(
            rawPrice.toString()
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) ??
          0;
    }

    return Item(
      id: int.tryParse(
            json['id']?.toString() ?? '',
          ) ??
          0,
      name: (
        json['name'] ??
        json['nama'] ??
        json['title'] ??
        json['nama_kamera'] ??
        'Nama kamera tidak tersedia'
      ).toString(),
      description: (
        json['description'] ??
        json['deskripsi'] ??
        json['keterangan'] ??
        ''
      ).toString(),
      price: parsedPrice,
      imageUrl: (
        json['image_url'] ??
        json['image'] ??
        json['gambar'] ??
        json['foto']
      )?.toString(),
    );
  }
}

// ============================================================
// API SERVICE
// ============================================================

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://localhost:8000/api';
  }

  Future<List<Item>> getItems() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/items'),
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
      }

      if (response.body.trim().isEmpty) {
        return [];
      }

      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map(
              (item) => Item.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (decoded is Map) {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(decoded);

        dynamic data;

        if (json['data'] is List) {
          data = json['data'];
        } else if (json['items'] is List) {
          data = json['items'];
        } else if (json['products'] is List) {
          data = json['products'];
        } else if (json['results'] is List) {
          data = json['results'];
        }

        if (data is List) {
          return data
              .whereType<Map>()
              .map(
                (item) => Item.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }

        if (json.containsKey('id') ||
            json.containsKey('name') ||
            json.containsKey('nama')) {
          return [
            Item.fromJson(json),
          ];
        }

        throw Exception(
          'Daftar kamera tidak ditemukan.',
        );
      }

      throw Exception(
        'Format respons API tidak dikenali.',
      );
    } catch (e) {
      throw Exception(
        'Gagal mengambil data kamera: $e',
      );
    }
  }
}

// ============================================================
// ITEM LIST SCREEN
// ============================================================

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() =>
      _ItemListScreenState();
}

class _ItemListScreenState
    extends State<ItemListScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<Item>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _apiService.getItems();
  }

  Future<void> _refreshItems() async {
    final future = _apiService.getItems();

    setState(() {
      _itemsFuture = future;
    });

    try {
      await future;
    } catch (_) {}
  }

  String _formatPrice(num price) {
    final digits = price.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data kamera belum dapat dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshItems,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_camera_back_outlined,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada kamera tersedia.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    final imageUrl = item.imageUrl;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE9ECF3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 80,
                height: 80,
                color: const Color(0xFFF0F2FF),
                child: imageUrl != null &&
                        imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.camera_alt_rounded,
                            size: 35,
                            color: Color(0xFF6366F1),
                          );
                        },
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        size: 35,
                        color: Color(0xFF6366F1),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${_formatPrice(item.price)} / hari',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PicRent',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Temukan kamera untuk momen terbaikmu',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshItems,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return _buildLoading();
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error!);
          }

          final items = snapshot.data ?? <Item>[];

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshItems,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                            0.65,
                    child: _buildEmpty(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshItems,
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                24,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItemCard(items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
