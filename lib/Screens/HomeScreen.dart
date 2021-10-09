import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Screens/EditProfileScreen.dart';
import 'package:magicwheel/Screens/GameFullDetailsScreen.dart';
import 'package:magicwheel/Screens/GamesListScreen.dart';
import 'package:magicwheel/Screens/SignInScreen.dart';
import 'package:magicwheel/Screens/SplashScreen.dart';
import 'package:magicwheel/Services/AdmobHelper.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AboutScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPremium = false;
  CountdownTimerController? controller;

  Response? response;
  Dio dio = Dio();
  var jsonData;
  var authToken;
  var isOneDayPremium = 0;
  List heroGames = [];
  List newestGames = [];
  List favoritesList = [];
  List trendingGamesList = [];
  List notifications = [];
  List currentList = [];
  var memberDetails;
  int? isGuestAccount;
  String name = '';
  String email = '';
  String initialVal = '';
  bool _loading = false;
  Future<List>? memberList;
  int _currentPage = 0;
  String _activeHero = '';
  int? _activeHeroId;
  int? _activeIsPremium;
  int isSubscribed = 0;

  initState() {
    print(ipAddress);
    print(platformType);
    print(deviceID);
    print(timeZone);
    print(fcmToken);
    getDashboard();

    super.initState();
  }

  Future getDashboard() async {
    // isOneDayPremium = await readData('isOneDayPremium');
    authToken = await readData('authToken');
    print('isOneDayPremium: $isOneDayPremium');
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
          "verb": "GetDashboard",
          "authToken": authToken
        },
      );
      // dev.log(response.toString());
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
            heroGames = jsonData['responseObject']['heroGames'];
            newestGames = jsonData['responseObject']['newestGames'];
            favoritesList = jsonData['responseObject']['favoritesList'];
            trendingGamesList = jsonData['responseObject']['trendingGamesList'];
            notifications = jsonData['responseObject']['notifications'];
            memberDetails = jsonData['responseObject']['member'];
            initialVal = heroGames[0]['title'];
            _activeHeroId = heroGames[0]['gameId'];
            name = memberDetails['name'];
            email = memberDetails['email'];
            isSubscribed = memberDetails['isPremium'];
            isGuestAccount = memberDetails['isGuestAccount'];
            profilePic = memberDetails['profilePhotoUrl'];

            if (favoritesList.isNotEmpty) {
              currentList = favoritesList;
              tags = ['Favourites', 'Newest', 'Trending'];
            } else if (favoritesList.isEmpty) {
              currentList = newestGames;
              tags = ['Newest', 'Trending'];
            }
          });
          print('isSubscribed>>>>: $isSubscribed');
          await setData();
        } else {
          print('Not Succeeded');
          print(response);
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  Future setData() async {
    await writeData('name', name);
    await writeData('email', email);
    await writeData('isGuestAccount', isGuestAccount);
    await writeData('isSubscribed', isSubscribed);
    await writeData('profilePic', profilePic);
  }

  void onEnd() {
    print('onEnd');
  }

  List tags = [];
  int selectedIndex = 0;
  String profilePic = '';

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      opacity: 0,
      inAsyncCall: _loading,
      progressIndicator: kProgressIndicator,
      child: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('$IMG_URL/BG1.png'), fit: BoxFit.fill),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('$IMG_URL/DrawerBG.png'), fit: BoxFit.fill),
              ),
              width: MediaQuery.of(context).size.width,
              child: FullScreenDrawer(name: name, email: email, isSubscribed: isSubscribed, isGuestAccount: isGuestAccount, isOneDayPremium: isOneDayPremium),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: GestureDetector(
              child: AppText(text: name.isNotEmpty ? 'Hi, $name' : '', fontSize: 26, fontWeight: FontWeight.w500, maxLines: 1),
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
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    heroGames.isEmpty
                        ? Container()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(text: 'Explore Games', fontSize: 13, fontWeight: FontWeight.w300, color: kTextLight),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(child: AppText(text: 'Trending', fontSize: 40, fontWeight: FontWeight.w700, height: 1.0)),
                                        // Image.asset('$ICON_URL/ic_Search.png', height: 30, width: 34),
                                      ],
                                    ),
                                    SizedBox(height: 20)
                                  ],
                                ),
                              ),
                              Container(
                                // alignment: Alignment.topCenter,
                                height: 350,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: CarouselSlider.builder(
                                            itemCount: heroGames.length,
                                            options: CarouselOptions(
                                              onPageChanged: (index, reason) {
                                                setState(() {
                                                  _currentPage = index;
                                                  _activeHero = heroGames[index]['title'] ?? '';
                                                  _activeHeroId = heroGames[index]['gameId'];
                                                  _activeIsPremium = heroGames[index]['gameId'];
                                                });
                                              },
                                              height: 320,
                                              autoPlay: true,
                                              aspectRatio: 2.0,
                                              enlargeCenterPage: true,
                                            ),
                                            itemBuilder: (context, index, realIdx) {
                                              return GestureDetector(
                                                onTap: () {
                                                  print('GAME ID: ${heroGames[index]['gameId']}');
                                                  Navigator.push(context,
                                                      MaterialPageRoute(builder: (context) => GameFullDetailsScreen(gameId: heroGames[index]['gameId'])));
                                                },
                                                child: Center(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(70),
                                                    child: CachedNetworkImage(
                                                      height: double.infinity,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      imageUrl: heroGames[index]['heroUrl'] ?? '',
                                                      placeholder: (context, url) => Center(child: kProgressIndicator),
                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => GameFullDetailsScreen(gameId: _activeHeroId!)));
                                      },
                                      child: GlassContainer(
                                        height: 60,
                                        frostAlphaValue: 30,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              AppText(text: _activeHero.isEmpty ? initialVal : _activeHero, fontWeight: FontWeight.w500, fontSize: 14),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ListView(
                                          physics: BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            SizedBox(width: 16),
                                            ListView.builder(
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
                                                        if (favoritesList.isNotEmpty) {
                                                          if (index == 0) {
                                                            currentList = favoritesList;
                                                          } else if (index == 1) {
                                                            currentList = newestGames;
                                                          } else if (index == 2) {
                                                            currentList = trendingGamesList;
                                                          }
                                                        } else if (favoritesList.isEmpty) {
                                                          if (index == 0) {
                                                            currentList = newestGames;
                                                          } else if (index == 1) {
                                                            currentList = trendingGamesList;
                                                          }
                                                        }
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
                                          child: InkWell(
                                            child: AppText(text: 'View All', fontSize: 11),
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => GamesListScreen()));
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 120,
                                    width: double.infinity,
                                    child: ListView(
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        SizedBox(width: 20),
                                        ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: currentList.length,
                                          itemBuilder: (context, index) {
                                            return SmallBanner(
                                              imageUrl: currentList[index]['thumbnailUrl'],
                                              favoriteCount: currentList[index]['favoriteCount'].toString(),
                                              playCount: currentList[index]['playCount'].toString(),
                                              onTap: () {
                                                print('GAME ID: ${currentList[index]['gameId']}');
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) => GameFullDetailsScreen(gameId: currentList[index]['gameId'])));
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 70),
                            ],
                          ),
                  ],
                ),
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
                              GestureDetector(
                                child: Image.asset('$ICON_URL/ic_like.png', height: 40),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => GamesListScreen()));
                                },
                              ),
                              SizedBox(width: 14),
                              Builder(
                                builder: (context) => Center(
                                  child: GestureDetector(
                                    onTap: () => Scaffold.of(context).openDrawer(),
                                    child: Image.asset('$ICON_URL/ic_setting.png', height: 40),
                                  ),
                                ),
                              ),
                            ],
                          )
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

class FullScreenDrawer extends StatefulWidget {
  final name;
  final email;
  final isSubscribed;
  final isGuestAccount;
  final isOneDayPremium;

  FullScreenDrawer({this.name, this.email, this.isSubscribed, this.isGuestAccount, this.isOneDayPremium});
  @override
  _FullScreenDrawerState createState() => _FullScreenDrawerState();
}

class _FullScreenDrawerState extends State<FullScreenDrawer> {
  List menuItems = ['Home', 'Favourites', 'About', 'Go Premium', 'Settings'];
  List menuIcons = ['ic_Home', 'ic_Star', 'ic_info', 'ic_taj', 'ic_Setting1'];
  String adStatusText = 'Watch 3 videos daily to activate.';
  List subscriptions = ['1-day Free Premium Subscription', 'Subscribe\nA 1-month subscription for \$1.99'];
  dynamic subscriptionValue = -1;

  Response? response;
  Dio dio = Dio();
  var jsonData;
  String? authToken;
  int isSubscribed = 0;
  bool _loading = false;

  late List<String> datas;
  late List<Object> dataads; // will store both data + banner ads
  AdmobHelper admobHelper = new AdmobHelper();
  String profilePic = '';
  getData() async {
    profilePic = await readData('profilePic');
  }

  @override
  void initState() {
    isSubscribed = widget.isSubscribed;
    getData();

    print('isSubscribed: $isSubscribed');

    _getProduct();
    initPlatformState();
    // _getPurchaseHistory();

    datas = [];
    for (int i = 1; i <= 20; i++) {
      datas.add("List Item $i");
    }
    dataads = List.from(datas);
    // print(dataads);
    for (int i = 0; i <= 2; i++) {
      var min = 1;
      var rm = new Random();
      var rannumpos = min + rm.nextInt(18);
      dataads.insert(rannumpos, AdmobHelper.getBannerAd()..load());
    }
    createInterad();

    super.initState();
  }

  RewardedAd? _rewardedAd;
  int num_of_attempt_load = 0;
  int adPlayedCount = 0;
  var rewardData;

  void createInterad() {
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

  void showInterad() {
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
        createInterad();
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );

    _rewardedAd!.show(
      onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {
        setState(() {
          rewardData = {'rewardType': rewardItem.type, 'rewardAmount': rewardItem.amount};
        });
        print('REWARDED AD: ${ad.responseInfo}');
        saveAdVideoReward();
        print('rewardItem $rewardItem');
        print(rewardItem.type);
        print(rewardItem.amount);
      },
    );
    _rewardedAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      progressIndicator: kProgressIndicator,
      opacity: 0,
      child: Drawer(
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      profilePic.isNotEmpty
                          ? Container(
                              height: 60,
                              width: 60,
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
                                      ? CircleAvatar(backgroundColor: Colors.transparent, radius: 30, child: Image.asset('$ICON_URL/user.png'))
                                      : Center(child: kProgressIndicator),
                                ),
                              ),
                            )
                          : CircleAvatar(backgroundColor: Colors.transparent, radius: 30, child: Image.asset('$ICON_URL/user.png')),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(text: widget.name ?? '', fontSize: 26, fontWeight: FontWeight.w700),
                          AppText(text: widget.email ?? 'user@example.com', fontSize: 13, color: Colors.white54),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: AppText(text: 'Edit', color: Colors.white54, fontSize: 13),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return index == 3
                        ? isSubscribed == 0
                            ? ListTile(
                                onTap: () {
                                  if (widget.isGuestAccount == 1) {
                                    Scaffold.of(context).openEndDrawer();
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                                  } else if (widget.isGuestAccount == 0) {
                                    _modalBottomSheetMenu();
                                  }
                                },
                                horizontalTitleGap: 0,
                                leading: Image.asset('$ICON_URL/${menuIcons[3]}.png', height: 20, width: 20),
                                title: AppText(text: menuItems[index], fontSize: 20, fontWeight: FontWeight.w500),
                                trailing: GlassContainer(
                                  frostColor: Colors.white,
                                  height: 40,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('$ICON_URL/goPro.png', height: 26, fit: BoxFit.fitHeight),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: AppText(text: 'Go Premium', fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ListTile(
                                onTap: () {
                                  showCancelSubscriptionDialog(context);
                                },
                                horizontalTitleGap: 0,
                                leading: Image.asset('$ICON_URL/${menuIcons[index]}.png', height: 20, width: 20),
                                title: AppText(text: 'Deactivate Subscription', fontSize: 20, fontWeight: FontWeight.w500),
                              )
                        : ListTile(
                            onTap: () {
                              if (index == 0) {
                                Navigator.pop(context);
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                              } else if (index == 1) {
                                Scaffold.of(context).openEndDrawer();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamesListScreen()));
                              } else if (index == 2) {
                                Scaffold.of(context).openEndDrawer();
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
                              } else if (index == 4) {
                                Scaffold.of(context).openEndDrawer();
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                              }
                            },
                            horizontalTitleGap: 0,
                            leading: Image.asset('$ICON_URL/${menuIcons[index]}.png', height: 20, width: 20),
                            title: AppText(text: menuItems[index], fontSize: 20, fontWeight: FontWeight.w500),
                          );
                  },
                ),
              ),
            ),
            widget.isGuestAccount == 0
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        showLogoutDialog(context);
                      },
                      child: ListTile(
                        horizontalTitleGap: 0,
                        leading: Image.asset('$ICON_URL/logout.png', height: 20, width: 20),
                        title: AppText(text: 'Logout', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white30, height: 1.2),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  _modalBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GlassContainer(
                      frostColor: Colors.white,
                      frostAlphaValue: 30,
                      height: 40,
                      width: 110,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('$ICON_URL/goPro.png', height: 26, fit: BoxFit.fitHeight),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: AppText(text: 'Go Premium', fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: AppText(
                                    text: index == 0 ? '${subscriptions[index]}\n$adStatusText' : subscriptions[index],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () async {
                                  setState(() {
                                    subscriptionValue = index;
                                  });
                                  if (subscriptionValue == 0) {
                                    print('Ad Played Count: $adPlayedCount');
                                    print('Ad Status Text: $adStatusText');
                                    setState(() {
                                      adPlayedCount += 1;
                                    });
                                    if (adPlayedCount == 1) {
                                      // saveAdVideoReward();
                                      setState(() {
                                        adStatusText = 'Watch 2 more videos to activate.';
                                        createInterad();
                                        print('Ad Status Text: $adStatusText');
                                      });
                                    } else if (adPlayedCount == 2) {
                                      // saveAdVideoReward();
                                      setState(() {
                                        adStatusText = 'Watch 1 more video to activate.';
                                        createInterad();
                                        print('Ad Status Text: $adStatusText');
                                      });
                                    } else if (adPlayedCount == 3) {
                                      // saveAdVideoReward();
                                      setState(() {
                                        adStatusText = 'Watch 3 videos daily to activate.';
                                        adPlayedCount = 0;
                                      });
                                    }
                                    showInterad();
                                  } else if (subscriptionValue == 1) {
                                    setState(() {
                                      _loading = true;
                                    });
                                    await _getProduct();
                                    await _requestPurchase();
                                  }
                                  // print(subscriptionValue);
                                },
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.grey),
                                child: SizedBox(
                                  height: 40,
                                  child: Radio(
                                    splashRadius: 8,
                                    activeColor: Colors.white,
                                    focusColor: Colors.white,
                                    overlayColor: MaterialStateProperty.all(Colors.white),
                                    fillColor: MaterialStateProperty.all(Colors.white),
                                    value: index,
                                    groupValue: subscriptionValue,
                                    onChanged: (val) async {
                                      setState(() {
                                        subscriptionValue = val!;
                                        print(subscriptionValue);
                                      });
                                      if (subscriptionValue == 0) {
                                        print('Ad Played Count: $adPlayedCount');
                                        print('Ad Status Text: $adStatusText');
                                        setState(() {
                                          adPlayedCount += 1;
                                        });
                                        if (adPlayedCount == 1) {
                                          // saveAdVideoReward();
                                          setState(() {
                                            adStatusText = 'Watch 2 more videos to activate.';
                                            createInterad();
                                            print('Ad Status Text: $adStatusText');
                                          });
                                        } else if (adPlayedCount == 2) {
                                          // saveAdVideoReward();
                                          setState(() {
                                            adStatusText = 'Watch 1 more video to activate.';
                                            createInterad();
                                            print('Ad Status Text: $adStatusText');
                                          });
                                        } else if (adPlayedCount == 3) {
                                          // saveAdVideoReward();
                                          setState(() {
                                            adStatusText = 'Watch 3 videos daily to activate.';
                                            adPlayedCount = 0;
                                          });
                                        }
                                        showInterad();
                                      } else if (subscriptionValue == 1) {
                                        setState(() {
                                          _loading = true;
                                        });
                                        await _getProduct();
                                        await _requestPurchase();
                                      }
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    FrostedBGButton(
                      needIcon: false,
                      text: 'Restore Subscription',
                      backGround: 'btn-bg1',
                      onTap: () async {
                        await _purchaseRestore();
                        // print("RestoreSubscription");
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  showLogoutDialog(BuildContext context) {
    Widget cancelButton = TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context));
    Widget logoutButton = TextButton(child: Text("Logout"), onPressed: logout);

    AlertDialog alert = AlertDialog(
      title: AppText(text: 'Logout', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
      content: AppText(text: "Are you sure you want to Logout?", color: Colors.black, fontWeight: FontWeight.w500),
      actions: [cancelButton, logoutButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showCancelSubscriptionDialog(BuildContext context) {
    Widget cancelButton = TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context));
    Widget logoutButton = TextButton(
        child: Text("Deactivate"),
        onPressed: () async {
          if (Platform.isIOS) {
            await subscriptionCancellation();
            if (widget.isOneDayPremium != 1) {
              await AppSettings.openAppSettings(asAnotherTask: true);
            }
          } else if (Platform.isAndroid) {
            await subscriptionCancellation();
            if (widget.isOneDayPremium != 1) {
              if (await canLaunch('https://play.google.com/store/account/subscriptions')) {
                await launch(
                  'https://play.google.com/store/account/subscriptions',
                  forceSafariVC: false,
                  forceWebView: false,
                  headers: <String, String>{'my_header_key': 'my_header_value'},
                );
              } else {
                throw 'Could not launch https://play.google.com/store/account/subscriptions';
              }
            }
          }
        });

    AlertDialog alert = AlertDialog(
      title: AppText(text: 'Deactivate Premium Subscription', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
      content: AppText(
          text:
              "Are you sure you want to deactivate your Premium Subscription? \n\n${Platform.isIOS ? 'To deactivate Go to\nSettings > Apple ID Profile > Subscriptions' : Platform.isAndroid ? 'To Deactivate Go to \nPlay Store > Tap on your profile icon > Payment & Subscriptions > Subscriptions' : ''} ",
          color: Colors.black,
          fontWeight: FontWeight.w500),
      actions: [cancelButton, logoutButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future logout() async {
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
          "verb": "Logout",
          "authToken": authToken
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          await removeData('authToken');
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SplashScreen()), (route) => false);
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  //Send Purchase Receipt to Server For Premium Subscription Activation
  Future subscriptionActivation({String? receipt, String? platform, String? details}) async {
    var jsonData;
    authToken = await readData('authToken');
    print(authToken);
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }
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
          "verb": "SubscriptionActivated",
          "authToken": authToken,
          "receipt": receipt,
          "details": details,
          "platform": platform,
          "log": 1
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          if (jsonData['responseObject']['isPremium'] == 1 || jsonData['responseObject']['isPremium'] == '1') {
            setState(() {
              isSubscribed = jsonData['responseObject']['isPremium'];
              print(isSubscribed);
            });
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
          } else {
            Navigator.pop(context);
          }
        } else if (jsonData['succeeded'] == 0) {
          print('Subscription Not Succeeded');
          Navigator.pop(context);
          print(response);
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  //To Cancel the Activated Premium Subscription
  Future subscriptionCancellation() async {
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
          "verb": "SubscriptionCancelled",
          "authToken": authToken
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          if (jsonData['responseObject']['isPremium'] == 0 || jsonData['responseObject']['isPremium'] == '0') {
            setState(() {
              isSubscribed = jsonData['responseObject']['isPremium'];
              print(isSubscribed);
            });
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
          } else {
            Navigator.pop(context);
          }
        } else if (jsonData['succeeded'] == 0) {
          print('Subscription Not Succeeded');
          Navigator.pop(context);
          print(response);
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  //Send Purchase Receipt to Server For Premium Subscription Activation
  subscriptionRestore({String? receipt, String? platform, String? details}) async {
    var jsonData;
    authToken = await readData('authToken');
    print(authToken);
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }
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
          "verb": "SubscriptionRestored",
          "authToken": authToken,
          "receipt": receipt,
          "details": details,
          "platform": platform,
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          if (jsonData['responseObject']['isPremium'] == 1 || jsonData['responseObject']['isPremium'] == '1') {
            setState(() {
              isSubscribed = jsonData['responseObject']['isPremium'];
              print(isSubscribed);
            });
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
          } else {
            Navigator.pop(context);
          }
        } else if (jsonData['succeeded'] == 0) {
          print('Subscription Not Succeeded');
          Navigator.pop(context);
          print(response);
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  Future saveAdVideoReward() async {
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
          "verb": "SaveVideoReward",
          "authToken": authToken,
          "rewardDetails": rewardData,
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          // print('isPremium>>>>>> ${jsonData['responseObject']['isPremium']}');
          if (jsonData['responseObject']['isPremium'] == 1 || jsonData['dailyPremiumCountdownValue'] > 1) {
            // await writeData('isOneDayPremium', jsonData['responseObject']['isPremium']);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
          }
        } else if (jsonData['succeeded'] == 0) {
          print('Subscription Not Succeeded');
          Navigator.pop(context);
          print(response);
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  // InApp Purchase Configuration Below
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  late StreamSubscription _purchaseUpdatedSubscription;
  late StreamSubscription _purchaseErrorSubscription;
  late StreamSubscription _conectionSubscription;
  final List<String> _productLists = [Platform.isAndroid ? "magicwheel_1.99_pm" : "MagicWheel1.99pm"];
  // @override
  // void dispose() async {
  //   super.dispose();
  //   if (_conectionSubscription != null) {
  //     _conectionSubscription.cancel();
  //     _conectionSubscription = null;
  //     _purchaseUpdatedSubscription.cancel();
  //     _purchaseUpdatedSubscription = null;
  //     _purchaseErrorSubscription.cancel();
  //     _purchaseErrorSubscription = null;
  //   }
  //   await FlutterInappPurchase.instance.endConnection;
  // }

  Future _getProduct() async {
    List<IAPItem> items = Platform.isAndroid
        ? await FlutterInappPurchase.instance.getSubscriptions(_productLists)
        : await FlutterInappPurchase.instance.getProducts(_productLists);
    print('========items======');
    print("items: $items");
    for (var item in items) {
      // print('${item.toString()}');
      this._items.add(item);
    }
    if (mounted) {
      setState(() {
        this._items = items;
        this._purchases = [];
      });
    }
  }

  String _platformVersion = 'Unknown';
  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = (await FlutterInappPurchase.instance.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    var result = await FlutterInappPurchase.instance.initConnection;
    print('inApp result: $result');

    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
      print('_platformVersion><><><><: $_platformVersion');
    });

    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _conectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected Subscription: $connected');
    });
    // https://play.google.com/store/account/subscriptions
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      if (Platform.isAndroid) {
        print('ANDROID subscription');
        print('Subscribed Successfully>>> $productItem');
        print('productItem!.transactionReceipt:  ${productItem!.transactionReceipt}');
        if (productItem.purchaseToken != null) {
          await subscriptionActivation(receipt: productItem.transactionReceipt, platform: _platformVersion, details: productItem.purchaseToken);
        } else {
          print('TRANSACTION RESPONSE: $productItem');
        }
      } else if (Platform.isIOS) {
        print('IOS subscription!');
        print('purchase Item: $productItem');
        if (productItem!.transactionId != null) {
          await subscriptionActivation(receipt: productItem.transactionReceipt, platform: _platformVersion, details: productItem.transactionId);
        } else {
          print('TRANSACTION RESPONSE: $productItem');
        }
      }
      if (productItem!.transactionStateIOS == TransactionState.purchased || productItem.purchaseStateAndroid == PurchaseState.purchased) {
        setState(() {
          _loading = false;
        });
      }
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error<<>>: $purchaseError');
    });
  }

  _requestPurchase() async {
    try {
      await FlutterInappPurchase.instance.requestPurchase(Platform.isAndroid ? "magicwheel_1.99_pm" : "MagicWheel1.99pm");
    } on Exception catch (e) {
      print(e);
    }
  }

  Future _purchaseRestore() async {
    List<PurchasedItem>? items;
    var receiptBody;

    items = await FlutterInappPurchase.instance.getPurchaseHistory();
    dev.log(items.toString());

    // FlutterInappPurchase.instance.validateReceiptAndroid(productId: '', packageName: '', productToken: '', accessToken: '');
    if (items!.length != 0) {
      if (Platform.isIOS && items[0].transactionStateIOS == TransactionState.restored) {
        receiptBody = {'receipt-data': items[0].transactionReceipt, 'password': '1a4b812260664f85899d9b5614e98785'};
        var result = await FlutterInappPurchase.instance
            .validateReceiptIos(receiptBody: receiptBody, isTest: true)
            .whenComplete(() => subscriptionRestore(receipt: items![0].transactionReceipt, platform: 'IOS', details: items[0].transactionId));
        print(result);
      } else if (Platform.isAndroid && items[0].purchaseToken != null) {
        // var result = await FlutterInappPurchase.instance.validateReceiptAndroid(
        //   packageName: 'com.magicwheel',
        //   productId: items[0].productId!,
        //   productToken: items[0].purchaseToken!,
        //   accessToken: items[0].transactionDate!.millisecondsSinceEpoch.toString(),
        // );
        await subscriptionRestore(receipt: items[0].transactionReceipt, platform: 'ANDROID', details: items[0].purchaseToken);
        // print(result);
      }
    } else {
      Toasty.showtoast('You don\'t have any Subscription');
    }
  }

/*  validateReceipt(PurchasedItem purchasedItem) async {
    if(Platform.isIOS){
      var receiptBody = {
        'receipt-data': purchasedItem.transactionReceipt,
        //'password': '******' // ? Question: for iOS password is "Only used for receipts that contain auto-renewable subscriptions."
      };
      var result = await FlutterInappPurchase.instance.validateReceiptIos(
          receiptBody: receiptBody,
          isTest: isSandbox
      );
      print(result);
    }
    else if(Platform.isAndroid){
      String accessToken; // todo VALIDATE setup getAccessToken()
      assert(accessToken != null);

      var result = await FlutterInappPurchase.instance.validateReceiptAndroid(
        packageName: 'com.mypackage.samplefaces', // ? Question: does my app id go here?
        productId: purchasedItem.productId,
        productToken: purchasedItem.purchaseToken, // ? Question: is this the same?
        accessToken: accessToken,
        isSubscription: false,
      );
      print(result);
    }*/

  //
  //   setState(() {
  //     this._items = [];
  //     this._purchases = items;
  //   });
  // }
  Future<bool> subscriptionStatus(String sku, [Duration duration = const Duration(days: 30), Duration grace = const Duration(days: 0)]) async {
    if (Platform.isIOS) {
      var history;

      history = await FlutterInappPurchase.instance.getPurchaseHistory();

      for (var purchase in history) {
        Duration difference = DateTime.now().difference(purchase.transactionDate);
        if (difference.inMinutes <= (duration + grace).inMinutes && purchase.productId == sku) return true;
      }
      return false;
    } else if (Platform.isAndroid) {
      var purchases;
      purchases = await FlutterInappPurchase.instance.getAvailablePurchases();

      for (var purchase in purchases) {
        if (purchase.productId == sku) return true;
      }
      return false;
    }
    throw PlatformException(code: Platform.operatingSystem, message: "platform not supported");
  }

  // bool? userSubscribed;
  // _subscriptionState() {
  //   subscriptionStatus(iapId, const Duration(days: 30), const Duration(days: 0)).then((val) => setState(() {
  //         userSubscribed = val;
  //       }));
  // }
}
