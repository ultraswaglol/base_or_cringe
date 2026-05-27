import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../assessment/presentation/pages/assessment_page.dart';
import '../../domain/entities/situation.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/comments_list.dart';
import '../widgets/stats_bar.dart';
import '../widgets/swipeable_card.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      create: (_) => sl<GameBloc>()..add(LoadGameEvent()),
      child: const GameView(),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {

  final String _interstitialAdUnitId = '***';

  final _adLoader = InterstitialAdLoader();
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.destroy();
    super.dispose();
  }


  Future<void> _loadInterstitialAd() async {
    try {
      final ad = await _adLoader.loadAd(
        adRequest: AdRequest(adUnitId: _interstitialAdUnitId),
      );
      if (mounted) {
        setState(() {
          _interstitialAd = ad;
          _isAdLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Ошибка предзагрузки межстраничной рекламы: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
        });
      }
    }
  }


  void _handleVote(Choice choice) {


    final bool shouldShowAd = Random().nextDouble() < 0.10;

    if (shouldShowAd && _isAdLoaded && _interstitialAd != null) {

      _interstitialAd!.setAdEventListener(
        eventListener: InterstitialAdEventListener(
          onAdDismissed: () {

            context.read<GameBloc>().add(VoteEvent(choice));
            _loadInterstitialAd();
          },
          onAdFailedToShow: (error) {
            context.read<GameBloc>().add(VoteEvent(choice));
            _loadInterstitialAd();
          },
        ),
      );
      _interstitialAd!.show();
    } else {

      context.read<GameBloc>().add(VoteEvent(choice));

      if (!_isAdLoaded) {
        _loadInterstitialAd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('КРИНЖ ИЛИ БАЗА', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameFinished) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AssessmentPage(history: state.history),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentPurple));
          }

          if (state is GameError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: AppTheme.neonRed, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<GameBloc>().add(LoadGameEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Повторить'),
                    )
                  ],
                ),
              ),
            );
          }

          if (state is GameActiveCard || state is GameVotedState) {
            final isVoted = state is GameVotedState;

            final Situation situation;
            final int currentIndex;
            final int totalCount;
            final CommunityStats stats;

            if (state is GameVotedState) {
              situation = state.situation;
              currentIndex = state.currentIndex;
              totalCount = state.totalCount;
              stats = state.updatedStats;
            } else if (state is GameActiveCard) {
              situation = state.situation;
              currentIndex = state.currentIndex;
              totalCount = state.totalCount;
              stats = situation.stats;
            } else {
              return const SizedBox.shrink();
            }

            final categoryName = _getCategoryName(situation.category);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / totalCount,
                    backgroundColor: Colors.grey[800],
                    color: AppTheme.accentPurple,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ситуация ${currentIndex + 1} из $totalCount',
                    style: const TextStyle(color: AppTheme.textGray, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: isVoted
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SwipeableCard(
                                  situation: situation,
                                  categoryName: categoryName,
                                  isVoted: isVoted,
                                  onVote: (_) {},
                                ),
                                const SizedBox(height: 20),
                                StatsBar(stats: stats),
                                const SizedBox(height: 24),
                                CommentsList(comments: situation.comments),
                              ],
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              if (currentIndex + 1 < totalCount)
                                Transform.translate(
                                  offset: const Offset(0, 16),
                                  child: Transform.scale(
                                    scale: 0.94,
                                    child: Opacity(
                                      opacity: 0.3,
                                      child: Card(
                                        child: const SizedBox(
                                          height: 200,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              SwipeableCard(
                                situation: situation,
                                categoryName: categoryName,
                                isVoted: isVoted,

                                onVote: (choice) {
                                  _handleVote(choice);
                                },
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 12),
                  if (!isVoted)
                    Row(
                      children: [
                        Expanded(
                          child: _VoteButton(
                            title: 'КРИНЖ 😬',
                            color: AppTheme.neonRed,
                            onPressed: () {
                              _handleVote(Choice.cringe);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _VoteButton(
                            title: 'БАЗА 🗿',
                            color: AppTheme.neonGreen,
                            textColor: Colors.black,
                            onPressed: () {
                              _handleVote(Choice.base);
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        context.read<GameBloc>().add(NextSituationEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      child: const Text(
                        'СЛЕДУЮЩАЯ СИТУАЦИЯ ➔',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getCategoryName(SituationCategory category) {
    switch (category) {
      case SituationCategory.relationships:
        return 'ОТНОШЕНИЯ И РЕД-ФЛАГИ 🚩';
      case SituationCategory.lifestyle:
        return 'БЫТ И СОСЕДИ 🏠';
      case SituationCategory.friendship:
        return 'ДРУЖБА И ДЕНЬГИ 💵';
    }
  }
}

class _VoteButton extends StatelessWidget {
  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _VoteButton({
    required this.title,
    required this.color,
    this.textColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }
}
