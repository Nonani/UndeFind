import 'package:flutter/material.dart';
import '../../data/repositories/trash_repository.dart';
import '../../domain/entities/trash.dart';
import '../../domain/usecases/fetch_trash_usecase.dart';

class TrashMapViewModel extends ChangeNotifier {
  FetchTrashUseCase useCase = FetchTrashUseCase(TrashRepositoryImpl());
  bool _isFetching = false;
  List<Trash> _trashList = [];

  TrashMapViewModel();

  List<Trash> get trashList => _trashList;
  bool get isFetching => _isFetching;

  void fetchTrash() async {
    _isFetching = true;
    notifyListeners();
    _trashList = await useCase.execute();
    _isFetching = false;
    notifyListeners();
  }
}