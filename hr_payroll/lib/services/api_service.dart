import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _base = 'http://10.0.2.2:8080';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Future<List<dynamic>> findAll(
    String collection, {
    Map<String, String> params = const {},
  }) async {
    final uri = Uri.parse(
      '$_base/$collection',
    ).replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(res.body);
  }

  static Future<void> insertOne(
    String collection,
    Map<String, dynamic> document,
  ) async {
    await http.post(
      Uri.parse('$_base/$collection'),
      headers: _headers,
      body: jsonEncode(document),
    );
  }

  static Future<void> updateOne(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await http.put(
      Uri.parse('$_base/$collection/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteOne(String collection, String id) async {
    await http.delete(Uri.parse('$_base/$collection/$id'));
  }

  static Future<List<dynamic>> getReport(
    String reportName, {
    Map<String, String> params = const {},
  }) async {
    final uri = Uri.parse(
      '$_base/reports/$reportName',
    ).replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(res.body);
  }
}
