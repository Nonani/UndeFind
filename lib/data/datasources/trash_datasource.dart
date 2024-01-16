  import 'package:kakao_map_plugin/kakao_map_plugin.dart';

  import '../../domain/entities/trash.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';

  class TrashDataSource {
    final String baseUrl = 'https://example.com';
    TrashDataSource();

    Future<List<Trash>> fetchTrash() async {
      // 임시 데이터
      List<Map<String, dynamic>> tempData = [
        {
          "id": "1",
          "type": ["plastic", "metal"],
          "distant": 2.1,
          "location": {
            "lat": 33.3910079,
            "lng": 126.2220771
          }
        },
        {
          "id": "2",
          "type": ["paper"],
          "distant": 12.3,
          "location": {
            "lat": 33.490297,
            "lng": 126.413913
          }
        },
      ];

      return tempData.map((item) {
        return Trash(
          item['id'],
          List<String>.from(item['type']),
          LatLng(item['location']['lat'], item['location']['lng']),
          item['distant'],
        );
      }).toList();
      // final response = await http.get(Uri.parse('$baseUrl/trash'));
      //
      // if (response.statusCode == 200) {
      //   List jsonResponse = json.decode(response.body);
      //
      //   return jsonResponse.map((item) {
      //     return Trash(
      //       item['id'],
      //       List<String>.from(item['type']),
      //       LatLng(item['location']['lat'], item['location']['lng']),
      //     );
      //   }).toList();
      // } else {
      //   throw Exception('Failed to load trash from the server.');
      // }
    }
  }
