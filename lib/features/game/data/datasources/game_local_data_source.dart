import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/situation.dart';
import '../models/situation_model.dart';

abstract class GameLocalDataSource {
  Future<List<Situation>> getSituations();
  Future<CommunityStats> vote({required String situationId, required Choice choice});
}

class GameLocalDataSourceImpl implements GameLocalDataSource {

  List<Situation> _loadedSituations = [];


  List<Situation> _currentRoundSituations = [];

  @override
  Future<List<Situation>> getSituations() async {

    if (_loadedSituations.isEmpty) {
      final String jsonString = await rootBundle.loadString('assets/situations.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _loadedSituations = jsonList.map((json) => SituationModel.fromJson(json)).toList();
    }


    final List<Situation> shuffled = List.from(_loadedSituations);


    shuffled.shuffle();


    final int roundSize = shuffled.length < 10 ? shuffled.length : 10;
    _currentRoundSituations = shuffled.take(roundSize).toList();

    return _currentRoundSituations;
  }

  @override
  Future<CommunityStats> vote({
    required String situationId,
    required Choice choice,
  }) async {

    await Future.delayed(const Duration(milliseconds: 200));

    final index = _currentRoundSituations.indexWhere((element) => element.id == situationId);
    if (index == -1) {
      throw Exception('Ситуация не найдена в текущем раунде');
    }

    final currentSituation = _currentRoundSituations[index];
    final currentStats = currentSituation.stats;

    final updatedStats = CommunityStats(
      baseVotes: choice == Choice.base ? currentStats.baseVotes + 1 : currentStats.baseVotes,
      cringeVotes: choice == Choice.cringe ? currentStats.cringeVotes + 1 : currentStats.cringeVotes,
    );

    _currentRoundSituations[index] = Situation(
      id: currentSituation.id,
      text: currentSituation.text,
      category: currentSituation.category,
      stats: updatedStats,
      comments: currentSituation.comments,
      baseTrait: currentSituation.baseTrait,
      cringeTrait: currentSituation.cringeTrait,
    );

    return updatedStats;
  }
}
