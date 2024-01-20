import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view_models/trash_map_view_model.dart';

import 'package:http/http.dart' as http;

String address = '';

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
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: viewModel.distantSortedTrashList.length,
              itemBuilder: (context, index) {
                return Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: sizeX * 4/5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '쓰레기 번호 : ' + index.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text("종류 : " +
                                    viewModel.distantSortedTrashList[index].type
                                        .toString(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('주소 : '+
                                  getAddress(viewModel.distantSortedTrashList[index].location.latitude,
                                      viewModel.distantSortedTrashList[index].location.longitude),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ),
                        Container(
                            width: sizeX * 1/5,

                            child: IconButton(
                                iconSize: 35,
                                onPressed: () {
                                  launchNaviUrl(Uri.parse(
                                      'https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route=' +
                                          viewModel.jejuDocheong.latitude
                                              .toString() +
                                          '%2C' +
                                          viewModel.jejuDocheong.longitude
                                              .toString() +
                                          '%3B' +
                                          viewModel.distantSortedTrashList[index]
                                              .location.latitude
                                              .toString() +
                                          '%2C' +
                                          viewModel.distantSortedTrashList[index]
                                              .location.longitude
                                              .toString()
                                  ));
                                },
                                icon: const Icon(Icons.map))
                        )
                      ],
                    )
                );
              },
            ),
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

  static Future<String> getPlaceAddress(double latitude, double longtitude) async{
    String key = dotenv.env['GOOGLE_APP_KEY'];
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longtitude&key=$key&language=ko';
    final response = await http.get(Uri.parse(url));
    //print(jsonDecode(response.body)['results'][0]['formatted_address']);
    return jsonDecode(response.body)['results'][0]['formatted_address'];
  }

  void ReverseGeocoding(double latitude, double longtitude) async {
    address = await getPlaceAddress(latitude, longtitude);
    //print(address);
  }

  String getAddress(double latitude, double longtitude) {
    ReverseGeocoding(latitude, longtitude);
    return address;
  }

}
