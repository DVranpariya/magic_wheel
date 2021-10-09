import 'dart:async';
import 'dart:convert';
import 'dart:math' as _math;
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Screens/GameTextDetailsScreen.dart';
import 'package:magicwheel/Screens/GameVideoDetailsScreen.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:magicwheel/flutter_fortune_wheel/flutter_fortune_wheel.dart';

import 'SplashScreen.dart';

class SpinWheelScreen extends StatefulWidget {
  final int? gameId;
  final List? wheelData;
  final int? favoriteCount;
  final int? playCount;

  const SpinWheelScreen({this.wheelData, this.gameId, this.favoriteCount, this.playCount});
  @override
  _SpinWheelScreenState createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  StreamController<int> controller = StreamController<int>();
  Random random = Random();
  int? randomNumber;
  int? gameItemDefinitionId;
  CountdownTimerController? timeController;
  int endTime = 0;
  final List items = [];
  RewardedAd? _rewardedAd;
  int spinWheelCount = 0;
  bool flag = true;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  void createRewardAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('$ad loaded.');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardAd() {
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        print("ad Disposed");
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewardAd();
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );
    _rewardedAd!.show(
      onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {
        print('REWARDED AD: ${ad.responseInfo}');
        print('rewardItem $rewardItem');
        print(rewardItem.type);
        print(rewardItem.amount);

        // setState(() {
        //   adPlayedCount += 1;
        // });
        // if (adPlayedCount == 1) {
        // } else if (adPlayedCount == 2) {
        // } else if (adPlayedCount == 3) {
        //   setState(() {
        //     adPlayedCount = 0;
        //   });
        // }
      },
    );
    _rewardedAd = null;
  }

  @override
  void initState() {
    print(widget.wheelData);
    startTimer();
    setState(() {
      endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 86400;
    });
    getItems();
    super.initState();
  }

  getItems() {
    for (int i = 0; i < widget.wheelData!.length; i++) {
      setState(() {
        items.add(widget.wheelData![i]['title']);
      });
    }
    print(items);
  }

  Response? response;
  Dio dio = Dio();
  var jsonData;
  String? authToken;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('$IMG_URL/BG1.png'), fit: BoxFit.fill),
      ),
      child: items.isEmpty
          ? Container()
          : Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: Image.asset('$ICON_URL/ic_back.png', height: 34, width: 34),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10, top: 13, bottom: 13),
                    child: GlassContainer(
                      frostColor: Colors.white,
                      borderColor: Colors.white,
                      frostAlphaValue: 70,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CounterTile(text: '${widget.favoriteCount} ', color: Colors.white, fontSize: 11),
                            CounterTile(text: 'favourites, ', fontWeight: FontWeight.w300, color: Colors.white, fontSize: 11),
                            CounterTile(text: '${widget.playCount} ', color: Colors.white, fontSize: 11),
                            CounterTile(text: 'game plays', fontWeight: FontWeight.w300, color: Colors.white, fontSize: 11),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 30),
                      AppText(text: 'Spin the Wheel', fontSize: 40, fontWeight: FontWeight.w700),
                      AppText(text: "and spent time with child", fontSize: 13, fontWeight: FontWeight.w300, color: kTextLight),
                      SizedBox(height: 10),
                      GlassContainer(
                        frostColor: Colors.black,
                        borderColor: Colors.white,
                        frostAlphaValue: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(text: '${hoursStr}hr :', fontSize: 10),
                              AppText(text: '${minutesStr}min : ', fontSize: 10),
                              AppText(text: '${secondsStr}sec', fontSize: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: MediaQuery.of(context).size.height,
                        child: Transform.scale(
                          scale: 1.7,
                          child: FortuneWheel(
                            selected: controller.stream,
                            physics: CircularPanPhysics(duration: Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn),
                            indicators: [FortuneIndicator(alignment: Alignment.topCenter, child: TriangleIndicator())],
                            onFling: () {
                              setState(() {
                                spinWheelCount += 1;
                                print('spinWheelCount $spinWheelCount');
                              });
                              if (spinWheelCount < 6) {
                                play();
                                randomNumber = random.nextInt(items.length);
                                controller.add(randomNumber!);
                                print(randomNumber);
                                if (spinWheelCount == 5) {
                                  createRewardAd();
                                }
                              } else if (spinWheelCount == 6) {
                                showRewardAd();
                                setState(() {
                                  spinWheelCount = 0;
                                });
                              } else {
                                setState(() {
                                  spinWheelCount = 0;
                                });
                              }
                              randomNumber = random.nextInt(items.length);
                              controller.add(randomNumber!);
                              print(randomNumber);
                            },
                            styleStrategy: AlternatingStyleStrategy(),
                            animateFirst: false,
                            onAnimationEnd: () async {
                              print(widget.wheelData![randomNumber!]['title']);
                              print(widget.wheelData![randomNumber!]['description']);
                              gameItemDefinitionId = await widget.wheelData![randomNumber!]['gameItemDefinitionId'];
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 500),
                                  reverseTransitionDuration: const Duration(milliseconds: 500),
                                  pageBuilder: (context, animation, secondaryAnimation) => ScaleTransition(
                                    scale: animation,
                                    child: widget.wheelData![randomNumber!]['videoUrl'] == ""
                                        ? GameTextDetailScreen(
                                            title: widget.wheelData![randomNumber!]['title'],
                                            description: widget.wheelData![randomNumber!]['description'],
                                            gameId: widget.gameId!,
                                            gameDefinitionId: widget.wheelData![randomNumber!]['gameItemDefinitionId'],
                                            favoriteCount: widget.wheelData![randomNumber!]['likeCount'],
                                            playCount: widget.wheelData![randomNumber!]['playCount'],
                                          )
                                        : GameVideoDetailScreen(
                                            title: widget.wheelData![randomNumber!]['title'],
                                            videoUrl: widget.wheelData![randomNumber!]['videoUrl'],
                                            gameId: widget.gameId!,
                                            gameDefinitionId: widget.wheelData![randomNumber!]['gameItemDefinitionId'],
                                            favoriteCount: widget.wheelData![randomNumber!]['likeCount'],
                                            playCount: widget.wheelData![randomNumber!]['playCount'],
                                          ),
                                  ),
                                ),
                              );
                              print(gameItemDefinitionId);
                              await gamePlayed();
                            },
                            onIndicatorPressed: () {
                              setState(() {
                                spinWheelCount += 1;
                                print('spinWheelCount $spinWheelCount');
                              });

                              if (spinWheelCount < 6) {
                                play();
                                randomNumber = random.nextInt(items.length);
                                controller.add(randomNumber!);
                                print(randomNumber);
                                if (spinWheelCount == 5) {
                                  createRewardAd();
                                }
                              } else if (spinWheelCount == 6) {
                                showRewardAd();
                                setState(() {
                                  spinWheelCount = 0;
                                });
                              } else {
                                setState(() {
                                  spinWheelCount = 0;
                                });
                              }
                            },
                            // selected: controller.stream,
                            items: [
                              for (var item in items)
                                FortuneItem(
                                  child: Flex(
                                    direction: Axis.vertical,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.only(left: 36),
                                          child: Text(item, overflow: TextOverflow.ellipsis, softWrap: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: FortuneItemStyle(
                                    textAlign: TextAlign.left,
                                    textStyle: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                      color: items.indexOf(item).isEven ? Color(0xff220542) : Color(0xfff2aa39),
                                    ),
                                    color: items.indexOf(item).isEven ? Color(0xffed8130) : Color(0xff220542),
                                    borderColor: Color(0xffe8c568),
                                    borderWidth: 0.4,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future gamePlayed() async {
    authToken = await readData('authToken');
    print(authToken);
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        BASE_URL,
        data: {
          "apiVersion": apiVersion,
          "clientType": platformType,
          "clientVersion": clientVersion,
          "ip": ipAddress,
          "deviceUniqueId": deviceID,
          "firebaseToken": fcmToken,
          "timeZone": timeZone,
          "verb": "GamePlayed",
          "authToken": authToken,
          "gameId": widget.gameId,
          "gameDefinitionId": gameItemDefinitionId
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  final audioPlayer = AudioCache();

  play() async {
    await audioPlayer.play('sound/wheel.mp3');
  }

  startTimer() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      if (mounted) {
        setState(() {
          hoursStr = ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
          minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
          secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
        });
      }
    });
  }

  Stream<int> stopWatchStream() {
    StreamController<int>? streamController;
    Timer? timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void tick(_) {
      counter++;
      streamController!.add(counter);
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }
}

class TriangleIndicator extends StatelessWidget {
  final Color? color;

  const TriangleIndicator({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Transform.rotate(
      angle: _math.pi,
      child: SizedBox(
        width: 26,
        height: 26,
        child: _Triangle(color: Color(0xff190130), elevation: 2),
      ),
    );
  }
}

class _Triangle extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final double elevation;

  const _Triangle({required this.color, this.borderColor, this.borderWidth = 1, this.elevation = 0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrianglePainter(fillColor: color, strokeColor: borderColor, strokeWidth: borderWidth, elevation: elevation),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final double elevation;

  const _TrianglePainter({required this.fillColor, this.strokeColor, this.strokeWidth = 1, this.elevation = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(size.width / 2, 0);

    final strokeColor = this.strokeColor ?? fillColor;
    final fillPaint = Paint()..color = fillColor;
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawShadow(path, Colors.black, elevation, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        elevation != oldDelegate.elevation ||
        strokeWidth != oldDelegate.strokeWidth ||
        strokeColor != oldDelegate.strokeColor;
  }
}
