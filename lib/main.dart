import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/game/presentation/pages/game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  await YandexAds.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);


  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const KringeOrBaseApp());
}

class KringeOrBaseApp extends StatelessWidget {
  const KringeOrBaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'КРИНЖ ИЛИ БАЗА: Тест на Ред-Флаги',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const GamePage(),
    );
  }
}
