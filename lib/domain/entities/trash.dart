import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class Trash{
  final String id;
  final List<String> type;
  final LatLng location;
  final double distant;
  final int priority;
  Trash(this.id, this.type, this.location, this.distant, this.priority);

}