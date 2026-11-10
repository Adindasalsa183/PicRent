import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ItemService {
  // Menentukan URL API secara otomatis untuk Chrome, Android Emulator, dan Desktop
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  /// Mengambil daftar semua produk dari endpoint GET /api/items
  Future<List<Item>> getItems() async {
    final uri = Uri.parse('$baseUrl/items');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // Memeriksa jika response berwujud Map dengan key 'data' (misal: { "success": true, "data": [...] })
        if (decodedData is Map<String, dynamic>) {
          if (decodedData['data'] != null && decodedData['data'] is List) {
            final List<dynamic> list = decodedData['data'];
            return list.map((json) => Item.fromJson(json)).toList();
          } else if (decodedData['success'] == false) {
            throw Exception(decodedData['message'] ?? 'Gagal memuat data produk');
          }
        } 
        // Memeriksa jika response berwujud List langsung (misal: [ {...}, {...} ])
        else if (decodedData is List) {
          return decodedData.map((json) => Item.fromJson(json)).toList();
        }

        return [];
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke API PicRent: $e');
    }
  }
}