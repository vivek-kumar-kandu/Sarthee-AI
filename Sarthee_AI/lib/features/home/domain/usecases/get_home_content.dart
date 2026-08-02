import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

/// Clean Architecture Use Case for retrieving Home Dashboard content.
class GetHomeContent {
  const GetHomeContent(this._repository);

  final IHomeRepository _repository;

  Future<HomeEntity> call({bool forceRefresh = false}) {
    return _repository.getHomeData(forceRefresh: forceRefresh);
  }
}
