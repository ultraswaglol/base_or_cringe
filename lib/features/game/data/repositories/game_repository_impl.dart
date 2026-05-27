import '../../domain/entities/situation.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_data_source.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource localDataSource;

  GameRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Situation>> getSituations() async {
    try {
      return await localDataSource.getSituations();
    } catch (e) {

      rethrow;
    }
  }

  @override
  Future<CommunityStats> vote({
    required String situationId,
    required Choice choice,
  }) async {
    try {
      return await localDataSource.vote(situationId: situationId, choice: choice);
    } catch (e) {
      rethrow;
    }
  }
}
