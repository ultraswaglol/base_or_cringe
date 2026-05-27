import '../../domain/entities/situation.dart';

abstract class GameState {}

class GameLoading extends GameState {}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}


class GameActiveCard extends GameState {
  final Situation situation;
  final int currentIndex;
  final int totalCount;

  GameActiveCard({
    required this.situation,
    required this.currentIndex,
    required this.totalCount,
  });
}


class GameVotedState extends GameState {
  final Situation situation;
  final Choice userChoice;
  final CommunityStats updatedStats;
  final int currentIndex;
  final int totalCount;

  GameVotedState({
    required this.situation,
    required this.userChoice,
    required this.updatedStats,
    required this.currentIndex,
    required this.totalCount,
  });
}


class GameFinished extends GameState {
  final List<Map<Situation, Choice>> history;

  GameFinished(this.history);
}
