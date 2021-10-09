import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'SplashScreen.dart';

class GameVideoDetailScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final int gameId;
  final int gameDefinitionId;
  final int? favoriteCount;
  final int? playCount;
  const GameVideoDetailScreen({required this.title, this.videoUrl = '', this.gameId = 0, this.gameDefinitionId = 0, this.favoriteCount, this.playCount});

  @override
  _GameVideoDetailScreenState createState() => _GameVideoDetailScreenState();
}

class _GameVideoDetailScreenState extends State<GameVideoDetailScreen> {
  VideoPlayerController? _controller;
  FlickManager? flickManager;
  double rating = 5;
  bool isLiked = false;

  late YoutubePlayerController _yTController;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;

  @override
  void initState() {
    checkLikedUnlikedGame();
    initYoutubePlayer();

    // _controller = VideoPlayerController.network(/*'https://www.youtube.com/watch?v=DK_UsATwoxI'*/
    //     'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
    //   ..initialize().then((_) {
    //     setState(() {});
    //   });

    // flickManager = FlickManager(
    //   videoPlayerController: VideoPlayerController.network("https://www.youtube.com/watch?v=DK_UsATwoxI"),
    // );
    super.initState();
  }

  initYoutubePlayer() {
    _yTController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  @override
  void deactivate() {
    _yTController.pause();
    super.deactivate();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_yTController.value.isFullScreen) {
      setState(() {
        _playerState = _yTController.value.playerState;
        _videoMetaData = _yTController.metadata;
      });
    }
  }

  @override
  void dispose() {
    _yTController.dispose();
    // flickManager!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('$IMG_URL/BG1.png'), fit: BoxFit.fill),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 10),
                    child: GestureDetector(
                      child: Image.asset('$ICON_URL/ic_back.png', height: 34, width: 34),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(text: widget.title, fontSize: 40, fontWeight: FontWeight.w700),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBarIndicator(
                                  rating: 5,
                                  itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CounterTile(text: '${widget.favoriteCount} ', color: Colors.white60, fontSize: 12),
                                    CounterTile(text: 'favourites, ', fontWeight: FontWeight.w300, color: Colors.white60, fontSize: 12),
                                    CounterTile(text: '${widget.playCount} ', color: Colors.white60, fontSize: 12),
                                    CounterTile(text: 'game plays', fontWeight: FontWeight.w300, color: Colors.white60, fontSize: 12),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              child: Image.asset(isLiked == false ? '$ICON_URL/ic_like2.png' : '$ICON_URL/ic_like1.png', height: 44),
                              onTap: () async {
                                setState(() {
                                  isLiked = !isLiked;
                                });
                                await likeDislike();
                              },
                            )
                            // GlassContainer(
                            //   frostColor: Colors.black,
                            //   borderColor: Colors.white,
                            //   frostAlphaValue: 10,
                            //   width: MediaQuery.of(context).size.width.toInt() * 0.25,
                            //   child: Padding(
                            //     padding: const EdgeInsets.symmetric(horizontal: 8),
                            //     child: Row(
                            //       children: [
                            //         Image.asset('$ICON_URL/filled_star.png', height: 10, width: 10),
                            //         Padding(
                            //           padding: const EdgeInsets.symmetric(vertical: 6),
                            //           child: VerticalDivider(color: Colors.white, width: 10),
                            //         ),
                            //         AppText(text: 'Favourite', fontSize: 10),
                            //       ],
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.topCenter,
                    height: mHeight * 0.5,
                    width: double.infinity,
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(image: AssetImage('$IMG_URL/pubg.jpeg'), fit: BoxFit.cover),
                    // ),
                    child:
                        /*FlickVideoPlayer(
                      flickManager: FlickManager(
                        videoPlayerController: _controller!,
                      ),
                    )*/
                        YoutubePlayerBuilder(
                      onExitFullScreen: () {
                        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
                      },
                      player: YoutubePlayer(
                        controller: _yTController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.white,
                        topActions: <Widget>[
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _yTController.metadata.title,
                              style: const TextStyle(color: Colors.white, fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                        onReady: () {
                          _isPlayerReady = true;
                        },
                      ),
                      builder: (context, player) {
                        return player;
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: 30),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 70),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(14),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 2)],
                                    ),
                                  ),
                                  Container(
                                    height: 70,
                                    width: 170,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(24),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 2)],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                        child: Container(
                                          height: 60,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xff45386f), Color(0xff445eac)],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            border: Border.all(color: Colors.grey.withAlpha(80)),
                                            borderRadius: BorderRadius.circular(40),
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: AppText(
                                              text: 'Play Another Game',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Response? response;
  Dio dio = Dio();
  var jsonData;
  String? authToken;
  int isSubscribed = 0;
  bool _loading = false;

  Future likeDislike() async {
    var jsonData;
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
          "verb": "LikeUnlikeGameItem",
          "authToken": authToken,
          "gameId": widget.gameId,
          "gameDefinitionId": widget.gameDefinitionId
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          print(jsonData['responseObject']);
          if (jsonData['responseObject'] == 'LIKED') {
            setState(() {
              isLiked = true;
            });
          } else if (jsonData['responseObject'] == 'UNLIKED') {
            setState(() {
              isLiked = false;
            });
          }
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  Future checkLikedUnlikedGame() async {
    var jsonData;
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
          "verb": "CheckGameItemDefinitionLike",
          "authToken": authToken,
          "gameId": widget.gameId,
          "gameDefinitionId": widget.gameDefinitionId
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          print(jsonData['responseObject']);
          if (jsonData['responseObject'] == 'LIKED') {
            setState(() {
              isLiked = true;
            });
          } else if (jsonData['responseObject'] == 'NOT_LIKED') {
            setState(() {
              isLiked = false;
            });
          }
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }
}
