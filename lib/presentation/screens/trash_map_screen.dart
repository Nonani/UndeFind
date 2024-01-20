import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:undefind_project/domain/entities/trash.dart';

import '../view_models/trash_map_view_model.dart';

class TrashMapScreen extends StatefulWidget {
  const TrashMapScreen({super.key});

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  late KakaoMapController mapController;
  late TrashMapViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    viewModel = Provider.of<TrashMapViewModel>(context, listen: false);
    return Stack(
        children: [
          viewModel.isFetching
              ? const CircularProgressIndicator() // 데이터를 불러오는 동안 로딩 표시
              : KakaoMap(
                  // 카카오맵 뷰

                  currentLevel: 10,
                  center: viewModel.jejuDocheong, // 초기 위치
                  onMarkerTap: (id, latlng, x) {
                    // 마커를 탭했을 때
                    logger.d(latlng);
                  },
                  onMapCreated: ((controller) async {
                    mapController = controller;
                     // 쓰레기 데이터를 불러옵니다.
                    await viewModel.fetchTrash();
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
          SlidingUpPanel(
            panel: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0), // 왼쪽 위 모서리 둥글게
                  topRight: Radius.circular(24.0), // 오른쪽 위 모서리 둥글게
                ),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Image(
                          image: AssetImage('assets/images/logo.png'),
                          width: 150,
                          color: Colors.white,
                        ),
                        InkWell(
                          onTap: () async {
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
                          borderRadius: BorderRadius.circular(30),
                          // 물결 효과의 경계를 원형으로 설정
                          child: Container(
                            padding: const EdgeInsets.all(8.0), // 패딩을 줍니다.
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // 원형 모양으로 설정
                              color: Colors.white, // 배경색 설정
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 2), // 그림자의 위치 설정
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.refresh, // 아이콘 설정
                              color: Colors.black, // 아이콘 색상 설정
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: viewModel.trashList.length,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                viewModel.trashList[index].type.toString()),
                            subtitle: Text(
                                viewModel.trashList[index].location.toString()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            collapsed: null,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0)),
            minHeight: 100,
            // 최소 높이 설정
            maxHeight: 500, // 최대 높이 설정
          ),
        ],
      );
  }

  LatLng getAverageLatLng(List<Trash> latLngs) {
    double sumLat = 0;
    double sumLng = 0;
    for (Trash t in latLngs) {
      sumLat += t.location.latitude;
      sumLng += t.location.longitude;
    }
    print(LatLng(sumLat / latLngs.length, sumLng / latLngs.length));
    return LatLng(sumLat / latLngs.length, sumLng / latLngs.length);
  }
}
