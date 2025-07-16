// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/detection.dart';

class ApiService {
  static const _baseUrl = 'http://127.0.0.1:8000';

  /// Sends [filePath] to your `/detect` endpoint and returns a list of detections.
  Future<List<Detection>> detectCrystal(String filePath) async {
    final uri = Uri.parse('$_baseUrl/detect');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }

    final Map<String, dynamic> body = json.decode(response.body);
    final List detectionsJson = body['detections'] as List;
    return detectionsJson
        .map((e) => Detection.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}