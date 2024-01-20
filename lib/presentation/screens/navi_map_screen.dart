import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view_models/trash_map_view_model.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:http/http.dart' as http;

class NaviMapScreen extends StatelessWidget {
  const NaviMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<TrashMapViewModel>(context);

    return Container(
      width: sizeX,
      height: sizeY,
      color: Colors.black,
      child: Column(
        children: [
          Container(
              height: 100,
              color: Colors.black,
              padding: const EdgeInsets.only(top: 30, left: 5),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    // 왼쪽 정렬을 위해 Alignment.centerLeft 사용
                    child: Image.asset('assets/images/logo.png',
                        color: Colors.white),
                  ),
                ],
              )),
          Expanded(
            // 로고를 제외한 나머지 부분을 ListView가 차지하게 됩니다.
            child: FutureBuilder<List<String>>(
                future: Future.wait(viewModel.sortedTrashList.map((e) =>
                    getAddress(e.location.latitude, e.location.longitude))),
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white,)); // 로딩 중일 때 출력할 위젯
                  } else {
                    return TransformableListView.builder(
                      getTransformMatrix: getTransformMatrix,
                      padding: const EdgeInsets.all(0),
                      itemCount: viewModel.sortedTrashList.length,
                      itemBuilder: (context, index) {
                        return Container(
                            height: 120,
                            margin: const EdgeInsets.only(bottom: 18.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  width: sizeX * 4 / 5,
                                  child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '수거 순서 : ' + (index + 1).toString(),
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          height: 1,
                                          color: Colors.grey,
                                        ),

                                        Container(
                                          margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
                                          child: Text(
                                            "쓰레기 종류 : " +
                                                viewModel
                                                    .sortedTrashList[index].type
                                                    .toString(),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xff373737),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 1.0),
                                          child: Text(
                                            '주소 : ' + snapshot.data![index],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xff373737),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 1.0),
                                          child: Text(
                                            "센터로부터의 거리 : " +
                                                viewModel
                                                    .sortedTrashList[index].distant
                                                    .toStringAsFixed(2) + ' km',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xff373737),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    width: sizeX * 1 / 5,
                                    child: IconButton(
                                        iconSize: 35,
                                        onPressed: () {
                                          launchNaviUrl(Uri.parse(
                                              'https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route=' +
                                                  viewModel
                                                      .jejuDocheong.latitude
                                                      .toString() +
                                                  '%2C' +
                                                  viewModel
                                                      .jejuDocheong.longitude
                                                      .toString() +
                                                  '%3B' +
                                                  viewModel
                                                      .sortedTrashList[index]
                                                      .location
                                                      .latitude
                                                      .toString() +
                                                  '%2C' +
                                                  viewModel
                                                      .sortedTrashList[index]
                                                      .location
                                                      .longitude
                                                      .toString()));
                                        },
                                        icon: const Icon(Icons.map)))
                              ],
                            ));
                      },
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  void launchNaviUrl(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
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
  Matrix4 getTransformMatrix(TransformableListItem item) {
    /// final scale of child when the animation is completed
    const endScaleBound = 0.85;

    /// 0 when animation completed and [scale] == [endScaleBound]
    /// 1 when animation starts and [scale] == 1
    final animationProgress = item.visibleExtent / item.size.height;

    /// result matrix
    final paintTransform = Matrix4.identity();

    /// animate only if item is on edge
    if (item.position != TransformableListItemPosition.middle) {
      final scale = endScaleBound + ((1 - endScaleBound) * animationProgress);

      paintTransform
        ..translate(item.size.width / 2)
        ..scale(scale)
        ..translate(-item.size.width / 2);
    }

    return paintTransform;
  }

}
