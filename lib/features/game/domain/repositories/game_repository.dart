import '../entities/situation.dart';

abstract class GameRepository {

  Future<List<Situation>> getSituations();


  Future<CommunityStats> vote({
    required String situationId,
    required Choice choice,
  });
}
