import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';

import '../view_models/trash_map_view_model.dart';

class TrashMapScreen extends StatelessWidget {
  late KakaoMapController mapController;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TrashMapViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Trash Map'),
      ),
      body: viewModel.isFetching
          ? CircularProgressIndicator() // 데이터를 불러오는 동안 로딩 표시
          : KakaoMap(
              // 카카오맵 뷰
              center: LatLng(37.5665, 126.9780), // 초기 위치
              onMapCreated: ((controller) async {
                mapController = controller;
                await mapController.addMarker(
                    markers: viewModel.trashList
                        .map((e) => Marker(
                              markerId: e.id.toString(),
                              latLng: LatLng(
                                  e.location.latitude, e.location.longitude),
                              width: 30,
                              height: 44,
                              offsetX: 15,
                              offsetY: 44,
                              infoWindowContent: "e.type",
                            ))
                        .toList());
              }),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          viewModel.fetchTrash(); // 쓰레기 데이터를 불러옵니다.
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  LatLng getAverageLatLng(Set<Marker> markers) {
    double sumLat = 0;
    double sumLng = 0;
    for (Marker marker in markers) {
      sumLat += marker.latLng.latitude;
      sumLng += marker.latLng.longitude;
    }
    print(LatLng(sumLat / markers.length, sumLng / markers.length));
    return LatLng(sumLat / markers.length, sumLng / markers.length);
  }
}
