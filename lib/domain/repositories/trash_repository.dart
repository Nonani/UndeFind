
import '../entities/trash.dart';

abstract class TrashRepository {
  Future<List<Trash>> fetchTrashs();
}
