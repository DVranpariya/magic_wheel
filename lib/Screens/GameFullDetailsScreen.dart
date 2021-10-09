import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Screens/SpinWheelScreen.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'SplashScreen.dart';

class GameFullDetailsScreen extends StatefulWidget {
  final int gameId;
  const GameFullDetailsScreen({required this.gameId});

  @override
  _GameFullDetailsScreenState createState() => _GameFullDetailsScreenState();
}

class _GameFullDetailsScreenState extends State<GameFullDetailsScreen> {
  double rating = 5;
  var game;
  int? favorited;
  List moreGames = [];
  List wheelItemsList = [];

  Response? response;
  Dio dio = Dio();
  var jsonData;
  String? authToken;
  bool _loading = false;

  Future getGameDetails() async {
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
          "verb": "GetGameDetails",
          "authToken": authToken,
          "gameId": widget.gameId
        },
      );
      // log(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          setState(() {
            game = jsonData['responseObject']['game'];
            moreGames = jsonData['responseObject']['moreGames'];
            favorited = jsonData['responseObject']['favorited'];
            wheelItemsList = jsonData['responseObject']['gameItems'];
          });
        } else {
          print('Not Succeeded');
          print(response);
        }
      } else {
        // Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  initState() {
    getGameDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mWidth = MediaQuery.of(context).size.width;
    var mHeight = MediaQuery.of(context).size.height;
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('$IMG_URL/BG1.png'), fit: BoxFit.fill),
      ),
      child: ModalProgressHUD(
        opacity: 0,
        inAsyncCall: _loading,
        progressIndicator: kProgressIndicator,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: AppText(text: 'Game Details', fontSize: 26, fontWeight: FontWeight.w500),
            leading: IconButton(
              icon: Image.asset('$ICON_URL/ic_back.png', height: 34, width: 34),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: moreGames.isEmpty || game == null
              ? jsonData != null
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      alignment: Alignment.center,
                      child: AppText(
                        fontSize: 18,
                        text: jsonData['errorDescription'] ?? '',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  alignment: Alignment.topCenter,
                                  height: 340,
                                  width: mWidth * 0.86,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(70),
                                    child: CachedNetworkImage(
                                      height: double.infinity,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      imageUrl: game['heroUrl'] ?? '',
                                      placeholder: (context, url) => Center(child: kProgressIndicator),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 386,
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 80),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Stack(
                                              alignment: Alignment.topCenter,
                                              children: [
                                                SecondLayer(),
                                                FirstLayer(),
                                                PlayButton(
                                                  text: 'Play Now',
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => SpinWheelScreen(
                                                          wheelData: wheelItemsList,
                                                          gameId: widget.gameId,
                                                          favoriteCount: game['favoriteCount'],
                                                          playCount: game['playCount'],
                                                        ),
                                                      ),
                                                    );
                                                  },
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(text: game['title'], fontSize: 30, fontWeight: FontWeight.w700),
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
                                              CounterTile(text: '${game['favoriteCount'].toString()} ', color: Colors.white60, fontSize: 12),
                                              CounterTile(text: 'favourites, ', fontWeight: FontWeight.w300, color: Colors.white60, fontSize: 12),
                                              CounterTile(text: '${game['playCount'].toString()} ', color: Colors.white60, fontSize: 12),
                                              CounterTile(text: 'game plays', fontWeight: FontWeight.w300, color: Colors.white60, fontSize: 12),
                                            ],
                                          ),
                                        ],
                                      ),
                                      favorited == 1 ? FavoriteBadge() : Container()
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  AppText(
                                    text: game['description'],
                                    color: Colors.white60,
                                  ),
                                  SizedBox(height: 20),
                                  AppText(text: 'More Games', color: kTextLight),
                                  SizedBox(
                                    height: 120,
                                    width: double.infinity,
                                    child: ListView(
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: moreGames.length,
                                          itemBuilder: (context, index) {
                                            return SmallBanner(
                                              imageUrl: moreGames[index]['thumbnailUrl'],
                                              favoriteCount: moreGames[index]['favoriteCount'].toString(),
                                              playCount: moreGames[index]['playCount'].toString(),
                                              onTap: () {
                                                print('GAME ID: ${moreGames[index]['gameId']}');
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) => GameFullDetailsScreen(gameId: moreGames[index]['gameId'])));
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

class FavoriteBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      frostColor: Colors.white,
      borderColor: Colors.white,
      frostAlphaValue: 60,
      height: 24,
      width: MediaQuery.of(context).size.width.toInt() * 0.25,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Image.asset('$ICON_URL/filled_star.png', height: 10, width: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: VerticalDivider(color: Colors.white, width: 10),
            ),
            AppText(text: 'Favourite', fontSize: 10),
          ],
        ),
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  final String? text;
  final void Function() onTap;
  PlayButton({this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        frostColor: Colors.white,
        height: 60,
        width: double.infinity,
        frostAlphaValue: 70,
        child: Align(
          alignment: Alignment.center,
          child: AppText(
            text: text!,
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

class FirstLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 2)],
      ),
    );
  }
}

class SecondLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 2)],
      ),
    );
  }
}
