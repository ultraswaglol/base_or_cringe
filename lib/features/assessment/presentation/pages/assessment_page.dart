import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../game/domain/entities/situation.dart';
import '../../../game/presentation/pages/game_page.dart';
import '../cubit/assessment_cubit.dart';
import '../cubit/assessment_state.dart';
import '../../domain/entities/personality_profile.dart';

class AssessmentPage extends StatefulWidget {
  final List<Map<Situation, Choice>> history;

  const AssessmentPage({super.key, required this.history});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {

  final String _interstitialAdUnitId = '****';

  final _adLoader = InterstitialAdLoader();
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _shouldShowAd = false;

  @override
  void initState() {
    super.initState();


    _shouldShowAd = Random().nextDouble() < 0.50;

    if (_shouldShowAd) {
      _loadInterstitialAd();
    }
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
      debugPrint('Ошибка предзагрузки межстраничной рекламы на экране результатов: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
        });
      }
    }
  }

  void _navigateToGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  void _onPlayAgainPressed() {

    if (_shouldShowAd && _isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.setAdEventListener(
        eventListener: InterstitialAdEventListener(
          onAdDismissed: () {
            _navigateToGame();
          },
          onAdFailedToShow: (error) {
            _navigateToGame();
          },
        ),
      );
      _interstitialAd!.show();
    } else {

      _navigateToGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssessmentCubit>(
      create: (_) => sl<AssessmentCubit>()..processResults(widget.history),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('РЕЗУЛЬТАТЫ ТЕСТА', style: TextStyle(fontWeight: FontWeight.w900)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, state) {
            if (state is AssessmentCalculating) {
              return const _LoadingScreen();
            }

            if (state is AssessmentError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: const TextStyle(color: AppTheme.neonRed)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _navigateToGame,
                        child: const Text('На главную'),
                      )
                    ],
                  ),
                ),
              );
            }

            if (state is AssessmentLoaded) {
              final profile = state.profile;
              final accentColor = _getProfileColor(profile.type);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(seconds: 1),
                                child: Text(
                                  profile.emoji,
                                  style: const TextStyle(fontSize: 80),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              profile.title,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: accentColor,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  profile.description,
                                  style: const TextStyle(fontSize: 16, height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Твои маркеры:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.traits.map((trait) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  trait,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              )).toList(),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[800]!, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline, color: Colors.amber),
                                      SizedBox(width: 8),
                                      Text(
                                        'Совет гигачада:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    profile.recommendation,
                                    style: const TextStyle(color: AppTheme.textGray, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),


                    ElevatedButton(
                      onPressed: _onPlayAgainPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      child: const Text(
                        'ПРОЙТИ ЕЩЕ РАЗ 🔄',
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
      ),
    );
  }

  Color _getProfileColor(ProfileType type) {
    switch (type) {
      case ProfileType.sigma:
        return AppTheme.neonGreen;
      case ProfileType.toxic:
        return AppTheme.neonRed;
      case ProfileType.pleaser:
        return Colors.amber;
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.accentPurple,
              strokeWidth: 5,
            ),
            SizedBox(height: 32),
            Text(
              'АНАЛИЗИРУЕМ ТВОИ РЕД-ФЛАГИ...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Вычисляем процент душноты и уровень Сигмы в крови. Подожди пару сек...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGray),
            ),
          ],
        ),
      ),
    );
  }
}
