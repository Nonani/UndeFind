import 'package:dio/dio.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/trash.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrashDataSource {
  final String baseUrl = 'https://hoduhodu.online';
  Logger logger = Logger();

  TrashDataSource();

  Future<List<Trash>> fetchTrash() async {
    final url = Uri.parse(
      'https://hoduhodu.online/trash/priority/?random=true&size=10',
    );
    final response = await http.get(url);
    try {
      final List<dynamic> json = jsonDecode(response.body);
      List<Trash> trash = json.map((e) => Trash.fromJson(e)).toList();
      return trash;
    } catch (e) {
      logger.e(e);
      throw Exception('Failed to load trash');
    }

  }
}
