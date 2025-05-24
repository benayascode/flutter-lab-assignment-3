import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw HttpException('Failed with status: ${response.statusCode}');
      }
    } on SocketException {
      throw SocketException('No Internet connection');
    }
  }
} 