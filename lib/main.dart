import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  //AdMobの初期化処理
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

const maxFailedLoadAttempts = 3;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''), // Japanese, no country code
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter AdMob サンプル'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/2934735716',
    size: AdSize.mediumRectangle,
    request: request,
    listener: const BannerAdListener(),
  );

  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => debugPrint('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => debugPrint('Ad impression.'),
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  //リワード広告用
  // RewardedAd? _rewardedAd;
  // int _numRewardedLoadAttempts = 0;

  //リワードインタースティシャル広告用
  // RewardedInterstitialAd? _rewardedInterstitialAd;
  // int _numRewardedInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    myBanner.load();
    _createInterstitialAd();
    // _createRewardedAd();
    // _createRewardedInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/8691691433'
            : 'ca-app-pub-3940256099942544/5135589807',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // void _createRewardedAd() {
  //   RewardedAd.load(
  //       adUnitId: Platform.isAndroid
  //           ? 'ca-app-pub-3940256099942544/5224354917'
  //           : 'ca-app-pub-3940256099942544/1712485313',
  //       request: request,
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (RewardedAd ad) {
  //           debugPrint('$ad loaded.');
  //           _rewardedAd = ad;
  //           _numRewardedLoadAttempts = 0;
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           debugPrint('RewardedAd failed to load: $error');
  //           _rewardedAd = null;
  //           _numRewardedLoadAttempts += 1;
  //           if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
  //             _createRewardedAd();
  //           }
  //         },
  //       ));
  // }
  //
  // void _showRewardedAd() {
  //   if (_rewardedAd == null) {
  //     debugPrint('Warning: attempt to show rewarded before loaded.');
  //     return;
  //   }
  //   _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (RewardedAd ad) =>
  //         debugPrint('ad onAdShowedFullScreenContent.'),
  //     onAdDismissedFullScreenContent: (RewardedAd ad) {
  //       debugPrint('$ad onAdDismissedFullScreenContent.');
  //       ad.dispose();
  //       _createRewardedAd();
  //     },
  //     onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
  //       debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
  //       ad.dispose();
  //       _createRewardedAd();
  //     },
  //   );
  //
  //   _rewardedAd!.setImmersiveMode(true);
  //   _rewardedAd!.show(
  //       onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //     debugPrint(
  //         '$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
  //   });
  //   _rewardedAd = null;
  // }
  //
  // void _createRewardedInterstitialAd() {
  //   RewardedInterstitialAd.load(
  //       adUnitId: Platform.isAndroid
  //           ? 'ca-app-pub-3940256099942544/5354046379'
  //           : 'ca-app-pub-3940256099942544/6978759866',
  //       request: request,
  //       rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
  //         onAdLoaded: (RewardedInterstitialAd ad) {
  //           debugPrint('$ad loaded.');
  //           _rewardedInterstitialAd = ad;
  //           _numRewardedInterstitialLoadAttempts = 0;
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           debugPrint('RewardedInterstitialAd failed to load: $error');
  //           _rewardedInterstitialAd = null;
  //           _numRewardedInterstitialLoadAttempts += 1;
  //           if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
  //             _createRewardedInterstitialAd();
  //           }
  //         },
  //       ));
  // }
  //
  // void _showRewardedInterstitialAd() {
  //   if (_rewardedInterstitialAd == null) {
  //     debugPrint(
  //         'Warning: attempt to show rewarded interstitial before loaded.');
  //     return;
  //   }
  //   _rewardedInterstitialAd!.fullScreenContentCallback =
  //       FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
  //         debugPrint('$ad onAdShowedFullScreenContent.'),
  //     onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
  //       debugPrint('$ad onAdDismissedFullScreenContent.');
  //       ad.dispose();
  //       _createRewardedInterstitialAd();
  //     },
  //     onAdFailedToShowFullScreenContent:
  //         (RewardedInterstitialAd ad, AdError error) {
  //       debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
  //       ad.dispose();
  //       _createRewardedInterstitialAd();
  //     },
  //   );
  //
  //   _rewardedInterstitialAd!.setImmersiveMode(true);
  //   _rewardedInterstitialAd!.show(
  //       onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //     debugPrint(
  //         '$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
  //     _amountOfReward += 5;
  //     debugPrint(_amountOfReward.toString());
  //   });
  //   _rewardedInterstitialAd = null;
  // }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    // _rewardedAd?.dispose();
    // _rewardedInterstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: myBanner);
    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'バナー広告',
              style: TextStyle(fontSize: 30.0, color: Colors.black),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: const Text(
                '画面下部にバナー広告を表示しました。一定時間がたつと自動で更新されます。初心者には使いやすい広告のひとつです。',
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
                onPressed: () {
                  _showInterstitialAd();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SecondScreen(
                                title: widget.title,
                              )));
                },
                child: const Text(
                  '次の画面へ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                )),
            const SizedBox(
              height: 60.0,
            ),
            adContainer,
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'インタースティシャル広告',
              style: TextStyle(fontSize: 30.0, color: Colors.black),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: const Text(
                'ユーザーが閉じるまで全画面に表示される広告です。ゲームのシーン切り替えや画面遷移のときなど、アプリの流れが自然に一時停止する場面で有効な広告です。予期しないタイミングでの表示や頻度が高いとユーザビリティを損なってしまうので注意が必要です。',
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
