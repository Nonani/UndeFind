import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class Trash {
  final String id;
  final List<String> type;
  final LatLng location;
  final double distant;
  final String created_at;
  final int priority;

  Trash(this.id, this.type, this.location, this.distant, this.priority, this.created_at);

  factory Trash.fromJson(Map<String, dynamic> json) {
    return Trash(
      json['id'],
      List<String>.from(json['type']),
      LatLng(json['location']['lat'], json['location']['lng']),
      (json['distant'] as num).toDouble(),
      json['priority'],
      json['createdAt'],
    );
  }
}