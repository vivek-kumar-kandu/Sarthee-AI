import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

/// Clean Architecture Use Case for refreshing Home Dashboard content.
class RefreshHomeContent {
  const RefreshHomeContent(this._repository);

  final IHomeRepository _repository;

  Future<HomeEntity> call() {
    return _repository.getHomeData(forceRefresh: true);
  }
}
