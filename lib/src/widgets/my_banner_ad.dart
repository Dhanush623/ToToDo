import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/helper/analytics_helper.dart';

class MyBannerAdWidget extends StatefulWidget {
  const MyBannerAdWidget({
    super.key,
  });

  @override
  State<MyBannerAdWidget> createState() => _MyBannerAdWidgetState();
}

class _MyBannerAdWidgetState extends State<MyBannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    addScreenViewTracking(
      widget.runtimeType.toString(),
      "MyBannerAdWidget",
    );
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Constants.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: _bannerAd == null
          ? const SizedBox()
          : AdWidget(
              ad: _bannerAd!,
            ),
    );
  }
}
