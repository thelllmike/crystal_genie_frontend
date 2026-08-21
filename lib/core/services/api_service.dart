// lib/core/services/api_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../models/detection.dart';
import '../constants/api_config.dart';

class ApiService {
  static const _baseUrl = ApiConfig.baseUrl;

  Future<List<Detection>> detectCrystal(String filePath) async {
    final uri = Uri.parse('$_baseUrl/detect');

    // explicitly set MIME from extension:
    final ext = p.extension(filePath).toLowerCase(); // ".jpg", ".png"
    final subtype = ext.replaceFirst('.', '');       // "jpg" or "png"
    final mediaType = MediaType('image', subtype);

    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file', filePath,
        contentType: mediaType,
      ))
      ..headers['Accept'] = 'application/json';

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200) {
      debugPrint('🛑 /detect → ${resp.statusCode}: ${resp.body}');
      throw HttpException('Detect failed: ${resp.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(resp.body);
    final List<dynamic> hits = body['detections'] as List<dynamic>;
    return hits.map((e) => Detection.fromJson(e as Map<String, dynamic>)).toList();
  }
}