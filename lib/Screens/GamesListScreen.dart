import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'FilterGameListScreen.dart';
import 'GameFullDetailsScreen.dart';
import 'HomeScreen.dart';
import 'SignInScreen.dart';
import 'SplashScreen.dart';

class GamesListScreen extends StatefulWidget {
  @override
  _GamesListScreenState createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  List tags = ['Favourites', 'Newest', 'Trending'];
  int selectedIndex = 0;
  bool isPremium = false;
  CountdownTimerController? controller;
  // int endTime = 0;
  double rating = 5;
  List games = [];
  String name = '';
  String email = '';

  Response? response;
  Dio dio = Dio();
  var jsonData;
  String? authToken;
  bool _loading = false;
  bool isFiltered = false;
  int? category;
  int isGuestAccount = 0;
  var isOneDayPremium = 0;
  String profilePic = '';
  String ageLimit = '';
  int? sort;
  int isSubscribed = 0;

  Future getGameList() async {
    authToken = await readData('authToken');
    // print(authToken);
    setState(() {
      _loading = true;
    });
    try {
      response = await dio.post(
        BASE_URL,
        data: isFiltered == false
            ? {
                "apiVersion": apiVersion,
                "clientType": platformType,
                "clientVersion": clientVersion,
                "ip": ipAddress,
                "deviceUniqueId": deviceID,
                "firebaseToken": fcmToken,
                "timeZone": timeZone,
                "verb": "GetGames",
                "authToken": authToken,
              }
            : {
                "apiVersion": apiVersion,
                "clientType": platformType,
                "clientVersion": clientVersion,
                "ip": ipAddress,
                "deviceUniqueId": deviceID,
                "firebaseToken": fcmToken,
                "timeZone": timeZone,
                "verb": "GetGames",
                "authToken": authToken,
                "category": category,
                "ageList": ageLimit,
                "sort": sort
              },
      );
      print(response);
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
          dailyPremiumCountdownValue = jsonData['dailyPremiumCountdownValue'];
          if (dailyPremiumCountdownValue > 0) {
            isOneDayPremium = 1;
            endTime = (DateTime.now().millisecondsSinceEpoch + 1000 * dailyPremiumCountdownValue * 60).toInt();
          } else {
            isOneDayPremium = 0;
          }
          print('dailyPremiumCountdownValue: $dailyPremiumCountdownValue');
        });
        if (jsonData['succeeded'] == 1) {
          setState(() {
            games = jsonData['responseObject'];
            // if (sort == 1) {
            //   games = jsonData['responseObject'];
            // }
          });
          // log(games.toString());
        } else {
          print('Not Succeeded');
        }
      } else {
        // Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  Future _goAndGetTheData() async {
    Map results = await Navigator.push(context, MaterialPageRoute(builder: (context) => FilterGameListScreen()));

    if (results.isNotEmpty && results.containsKey('isFiltered')) {
      setState(() {
        isFiltered = results['isFiltered'];
        category = results['category'];
        ageLimit = results['ageLimit'];
        sort = results['sort'];
        print(isFiltered.toString());
        print('Category: $category');
        print('Age Limit: $ageLimit');
        print('Sort: $sort');
      });
      await getGameList();
    } else {
      return;
    }
  }

  Future getData() async {
    name = await readData('name');
    email = await readData('email');
    isGuestAccount = await readData('isGuestAccount');
    isSubscribed = await readData('isSubscribed');
    // isOneDayPremium = await readData('isOneDayPremium');
    profilePic = await readData('profilePic');
  }

  initState() {
    getData();
    getGameList();
    super.initState();
  }

  void onEnd() {
    print('onEnd');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage('$IMG_URL/BG1.png'), fit: BoxFit.fill)),
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: kProgressIndicator,
        opacity: 0,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: Container(
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage('$IMG_URL/DrawerBG.png'), fit: BoxFit.fill)),
              width: MediaQuery.of(context).size.width,
              child: FullScreenDrawer(name: name, email: email, isGuestAccount: isGuestAccount, isSubscribed: isSubscribed, isOneDayPremium: isOneDayPremium),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: GestureDetector(
              child: AppText(text: name.isNotEmpty ? 'Hi, $name' : '', fontSize: 26, fontWeight: FontWeight.w500),
              onTap: () {
                if (isGuestAccount == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                } else {
                  print('You are no more Guest');
                  return null;
                }
              },
            ),
            leadingWidth: 80,
            titleSpacing: 0,
            leading: Builder(
              builder: (context) => Center(
                child: GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: profilePic.isNotEmpty
                      ? Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: CachedNetworkImage(
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl: profilePic,
                              placeholder: (context, url) => Center(child: kProgressIndicator),
                              errorWidget: (context, url, error) => profilePic.isNotEmpty
                                  ? CircleAvatar(backgroundColor: Colors.transparent, radius: 20, child: Image.asset('$ICON_URL/user.png'))
                                  : Center(child: kProgressIndicator),
                            ),
                          ),
                        )
                      : CircleAvatar(backgroundColor: Colors.transparent, radius: 20, child: Image.asset('$ICON_URL/user.png')),
                ),
              ),
            ),
            actions: [Image.asset('$ICON_URL/ic_ball.png', height: 34, width: 34), SizedBox(width: 20)],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListView(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(width: 16),
                              isFiltered == true
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: AppText(text: '\"Search Results\"', fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                                    )
                                  : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: tags.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                selectedIndex == index
                                                    ? Padding(
                                                        padding: const EdgeInsets.only(right: 6),
                                                        child: Container(
                                                          height: 6,
                                                          width: 6,
                                                          decoration: BoxDecoration(color: Color(0xfff90070), shape: BoxShape.circle),
                                                        ),
                                                      )
                                                    : Container(),
                                                AppText(
                                                  text: tags[index],
                                                  fontWeight: selectedIndex == index ? FontWeight.w500 : FontWeight.w100,
                                                  fontSize: 13,
                                                  color: selectedIndex == index ? Colors.white : kTextLight,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: IconButton(
                              splashRadius: 20,
                              icon: Image.asset('$ICON_URL/ic_filter.png'),
                              onPressed: () {
                                _goAndGetTheData();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  games.isEmpty && _loading == false
                      ? Expanded(child: Center(child: AppText(text: 'No Games Found')))
                      : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      print(games[index]['gameId']);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => GameFullDetailsScreen(gameId: games[index]['gameId'])));
                                    },
                                    child: Container(
                                      height: 110,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(image: AssetImage('$IMG_URL/tile-bg.png')),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12, right: 16, top: 12, bottom: 12),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                                              child: CachedNetworkImage(
                                                height: double.infinity,
                                                width: MediaQuery.of(context).size.width * 0.35,
                                                fit: BoxFit.cover,
                                                imageUrl: games[index]['game']['thumbnailUrl'] ?? '',
                                                placeholder: (context, url) => Center(child: kProgressIndicator),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  RatingBarIndicator(
                                                    rating: 5,
                                                    itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
                                                    itemCount: 5,
                                                    itemSize: 20.0,
                                                    direction: Axis.horizontal,
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: AppText(
                                                      text: games[index]['game']['title'] ?? '',
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xff48098d),
                                                      fontSize: 20,
                                                      maxLines: 2,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      CounterTile(text: '${games[index]['game']['favoriteCount']} '),
                                                      CounterTile(text: 'favourites, ', fontWeight: FontWeight.w300),
                                                      CounterTile(text: '${games[index]['game']['playCount']} '),
                                                      CounterTile(text: 'game plays', fontWeight: FontWeight.w300),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 18),
                              ],
                            );
                          },
                        ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassContainer(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    frostAlphaValue: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isSubscribed == 0
                              ? GestureDetector(
                                  child: GlassContainer(
                                    height: 40,
                                    width: 120,
                                    child: Row(
                                      children: [
                                        Image.asset('$ICON_URL/goPro.png', fit: BoxFit.fitHeight),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: AppText(text: 'Go Premium', fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : isOneDayPremium == 1
                                  ? CountdownTimer(
                                      endTime: endTime,
                                      onEnd: onEnd,
                                      controller: controller,
                                      widgetBuilder: (context, time) {
                                        return GlassContainer(
                                          height: 40,
                                          width: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Time(
                                                    time: time!.hours.toString().length == 1 ? '0${time.hours.toString()}' : time.hours.toString(), unit: 'hr'),
                                                Colon(),
                                                Time(time: time.min.toString().length == 1 ? '0${time.min.toString()}' : time.min.toString(), unit: 'min'),
                                                Colon(),
                                                Time(time: time.sec.toString().length == 1 ? '0${time.sec.toString()}' : time.sec.toString(), unit: 'sec'),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(),
                          Row(
                            children: [
                              Image.asset('$ICON_URL/ic_like.png', height: 40),
                              SizedBox(width: 14),
                              Image.asset('$ICON_URL/ic_setting.png', height: 40),
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
        ),
      ),
    );
  }
}
