import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../view_models/trash_map_view_model.dart';

class TrashMapScreen extends StatefulWidget {


  TrashMapScreen();

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  late KakaoMapController mapController;
  int _currentIndex = 0;
  final _pageController = PageController();


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TrashMapViewModel>(context);
    Logger logger = Logger();
    return Scaffold(
      body: Stack(
        children: [viewModel.isFetching
            ? CircularProgressIndicator() // 데이터를 불러오는 동안 로딩 표시
            : KakaoMap(
          // 카카오맵 뷰

          currentLevel: 10,
          center: LatLng(33.488646, 126.5311884), // 초기 위치
          onMarkerTap: (id, latlng, x) {
            // 마커를 탭했을 때
            logger.d(latlng);
          },
          onMapCreated: ((controller) async {
            mapController = controller;
            await viewModel.fetchTrash(); // 쓰레기 데이터를 불러옵니다.
            await mapController.addMarker(
                markers: viewModel.trashList
                    .map((e) => Marker(
                  markerId: e.id.toString(),
                  latLng: e.location,
                  infoWindowContent: e.type.toString(),
                ))
                    .toList());
          }),
        ),
        DraggableScrollableSheet(initialChildSize: 0.4,builder: (context, controller) {
          return Container(
            color: Colors.white,
            child: ListView.builder(
              controller: controller,
              itemCount: viewModel.trashList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(viewModel.trashList[index].type.toString()),
                  subtitle: Text(viewModel.trashList[index].location.toString()),
                );
              },
            ),
          );
        }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await viewModel.fetchTrash(); // 쓰레기 데이터를 불러옵니다.
          await mapController.addMarker(
              markers: viewModel.trashList
                  .map((e) => Marker(
                        markerId: e.id.toString(),
                        latLng: e.location,
                        infoWindowContent: e.type.toString(),
                      ))
                  .toList());
          logger.d(viewModel.trashList[0].location);
          logger.d(viewModel.trashList[1].location);
          setState(() {});
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
