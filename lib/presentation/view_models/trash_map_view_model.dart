import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../data/repositories/trash_repository.dart';
import '../../domain/entities/trash.dart';
import '../../domain/usecases/fetch_trash_usecase.dart';

class TrashMapViewModel extends ChangeNotifier {
  FetchTrashUseCase useCase = FetchTrashUseCase(TrashRepositoryImpl());
  bool _isFetching = false;
  List<Trash> _trashList = [];

  TrashMapViewModel();

  LatLng get jejuDocheong => LatLng(33.4890464, 126.4980324);
  List<Trash> get trashList => _trashList;
  List<Trash> get sortedTrashList => _trashList
    ..sort((a, b) => -a.priority.compareTo(b.priority));

  bool get isFetching => _isFetching;

  Future<bool> fetchTrash() async {
    _isFetching = true;
    notifyListeners();
    _trashList = await useCase.execute();
    _isFetching = false;
    notifyListeners();
    return true;
  }
}