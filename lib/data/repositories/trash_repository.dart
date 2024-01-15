
import '../../domain/entities/trash.dart';
import '../../domain/repositories/trash_repository.dart';
import '../datasources/trash_datasource.dart';

class TrashRepositoryImpl implements TrashRepository {
  final TrashDataSource dataSource = TrashDataSource();
  TrashRepositoryImpl();

  @override
  Future<List<Trash>> fetchTrashs() {
    return dataSource.fetchTrash();
  }
}