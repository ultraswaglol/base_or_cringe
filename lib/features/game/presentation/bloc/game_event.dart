import '../../domain/entities/situation.dart';

abstract class GameEvent {
  const GameEvent();
}

class LoadGameEvent extends GameEvent {}

class VoteEvent extends GameEvent {
  final Choice choice;
  const VoteEvent(this.choice);
}

class NextSituationEvent extends GameEvent {}
