import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/situation.dart';
import '../../domain/repositories/game_repository.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository repository;

  List<Situation> _situations = [];
  int _currentIndex = 0;


  final List<Map<Situation, Choice>> _history = [];

  GameBloc({required this.repository}) : super(GameLoading()) {
    on<LoadGameEvent>(_onLoadGame);
    on<VoteEvent>(_onVote);
    on<NextSituationEvent>(_onNextSituation);
  }

  Future<void> _onLoadGame(LoadGameEvent event, Emitter<GameState> emit) async {
    emit(GameLoading());
    try {
      _situations = await repository.getSituations();
      _currentIndex = 0;
      _history.clear();

      if (_situations.isEmpty) {
        emit(GameError("Список ситуаций пуст"));
        return;
      }

      emit(GameActiveCard(
        situation: _situations[_currentIndex],
        currentIndex: _currentIndex,
        totalCount: _situations.length,
      ));
    } catch (e) {
      emit(GameError("Не удалось загрузить данные: ${e.toString()}"));
    }
  }

  Future<void> _onVote(VoteEvent event, Emitter<GameState> emit) async {
    final currentState = state;
    if (currentState is! GameActiveCard) return;

    final currentSituation = _situations[_currentIndex];

    try {

      final updatedStats = await repository.vote(
        situationId: currentSituation.id,
        choice: event.choice,
      );


      _history.add({currentSituation: event.choice});

      emit(GameVotedState(
        situation: currentSituation,
        userChoice: event.choice,
        updatedStats: updatedStats,
        currentIndex: _currentIndex,
        totalCount: _situations.length,
      ));
    } catch (e) {
      emit(GameError("Ошибка при отправке голоса"));
    }
  }

  void _onNextSituation(NextSituationEvent event, Emitter<GameState> emit) {
    _currentIndex++;

    if (_currentIndex < _situations.length) {
      emit(GameActiveCard(
        situation: _situations[_currentIndex],
        currentIndex: _currentIndex,
        totalCount: _situations.length,
      ));
    } else {

      emit(GameFinished(_history));
    }
  }
}
