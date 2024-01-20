import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:undefind_project/domain/entities/trash.dart';
import 'package:http/http.dart' as http;
import '../view_models/trash_map_view_model.dart';

class TrashMapScreen extends StatefulWidget {
  const TrashMapScreen({super.key});

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  late KakaoMapController mapController;
  late final TrashMapViewModel viewModel;
  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel = Provider.of<TrashMapViewModel>(context, listen: false);
      viewModel.fetchTrash();
      logger.w("test");
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TrashMapViewModel>(context);

    return Stack(
      children: [
        viewModel.isFetching
            ? Center(
                child: CircularProgressIndicator(),
              )
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
                  await mapController.addMarker(
                      markers: viewModel.trashList
                          .map((e) => Marker(
                                markerId: e.id.toString(),
                                latLng: e.location,
                                infoWindowContent: e.type
                                    .toString()
                                    .substring(1, e.type.toString().length - 1),
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
                viewModel.isFetching
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : FutureBuilder(
                        future: Future.wait(viewModel.trashList.map((e) =>
                            getAddress(
                                e.location.latitude, e.location.longitude))),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done)
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          else {
                            return Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24.0),
                                    topRight: Radius.circular(24.0),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: ListView.builder(
                                    itemCount: viewModel.trashList.length,
                                    physics: const ClampingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        height: 90,
                                        margin:
                                            EdgeInsets.fromLTRB(20, 0, 20, 0),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 1, 0, 1),
                                              child: Text(
                                                viewModel.trashList[index].type
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 1, 0, 1),
                                              child: Text(
                                                "위치 : ${snapshot.data![index]}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 1, 0, 1),
                                              child: Text(
                                                "생성시간 : " +
                                                    parseTime(viewModel
                                                        .sortedTrashList[index]
                                                        .created_at),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
              ],
            ),
          ),
          collapsed: null,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
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

  String parseTime(String input) {
    DateTime dateTime = DateTime.parse(input);

    // 사용자 정의 형식으로 포맷
    String formattedTime = DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(dateTime);

    return formattedTime;
  }

  static Future<String> getPlaceAddress(
      double latitude, double longtitude) async {
    await dotenv.load(fileName: "assets/.env");
    String key = dotenv.env['GOOGLE_APP_KEY'] ?? '';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longtitude&key=$key&language=ko';
    final response = await http.get(Uri.parse(url));
    //print(jsonDecode(response.body)['results'][0]['formatted_address']);

    return jsonDecode(response.body)['results'][0]['formatted_address'];
  }

  Future<String> getAddress(double latitude, double longtitude) async {
    return await getPlaceAddress(latitude, longtitude);
  }
}
