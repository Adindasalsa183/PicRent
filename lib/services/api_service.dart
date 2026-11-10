import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiService {
  // Ganti URL sesuai device yang Anda gunakan
  static const String baseUrl = 'http://10.0.2.2:8000/api'; 

  Future<List<Item>> getItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data barang');
    }
  }
}