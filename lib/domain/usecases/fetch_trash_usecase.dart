
import '../entities/trash.dart';
import '../repositories/trash_repository.dart';

class FetchTrashUseCase {
  final TrashRepository repository;
  FetchTrashUseCase(this.repository);
  Future<List<Trash>> execute() {
    return repository.fetchTrashs();
  }
}