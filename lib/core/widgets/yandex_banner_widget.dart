import 'package:flutter/material.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

class YandexBannerWidget extends StatefulWidget {
  final String adUnitId;

  const YandexBannerWidget({
    super.key,
    required this.adUnitId,
  });

  @override
  State<YandexBannerWidget> createState() => _YandexBannerWidgetState();
}

class _YandexBannerWidgetState extends State<YandexBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdInitialized = false;


  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAdInitialized) {
      _isAdInitialized = true;
      _loadBannerAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.destroy();
    super.dispose();
  }

  BannerAdSize _getAdSize() {
    final screenWidth = MediaQuery.of(context).size.width.round();
    final safeWidth = screenWidth > 0 ? screenWidth : 320;

    return BannerAdSize.sticky(width: safeWidth);
  }

  void _loadBannerAd() {
    debugPrint('=== РСЯ: Инициализация нативного баннера ===');

    final banner = BannerAd(
      adSize: _getAdSize(),
    );

    setState(() {
      _bannerAd = banner;
    });

    banner.loadStateStream.listen((state) {
      if (state is BannerAdLoadStateLoaded) {
        debugPrint('=== РСЯ: Баннер успешно загружен на устройство! ===');
        if (mounted) {


          setState(() {
            _isAdLoaded = true;
          });
        }
      } else if (state is BannerAdLoadStateError) {
        debugPrint('=== РСЯ: Ошибка загрузки баннера: ${state.error} ===');
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
          });
        }
      }
    });

    banner.load(AdRequest(adUnitId: widget.adUnitId));
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null) {


      final double adHeight = _isAdLoaded && _bannerAd!.adSize.height > 0
          ? _bannerAd!.adSize.height.toDouble()
          : 60.0;

      return SizedBox(
        width: double.infinity,
        height: adHeight,
        child: RepaintBoundary(
          child: AdWidget(bannerAd: _bannerAd!),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
