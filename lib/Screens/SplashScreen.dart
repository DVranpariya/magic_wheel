import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:magicwheel/Screens/HomeScreen.dart';
import 'package:magicwheel/Utils/Constants.dart';

String? ipAddress;
String? platformType;
String? deviceID;
String? timeZone;
String? fcmToken;
String? countryName;
String? authToken;
var dailyPremiumCountdownValue;
int endTime = 0;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    formattedTimeZoneOffset();
    registerGuest();
    super.initState();
  }

  Future getData() async {
    authToken = await readData('authToken');
    fcmToken = await FirebaseMessaging.instance.getToken();
  }

  Future registerGuest() async {
    await getData();
    await retrieveIp();
    await getPlatform();
    await getCountry();
    // await saveAdVideoRewardToUpdateTimer();
    // getCountryName();
    if (authToken == null || authToken == 'null') {
      print('New User Detected');
      await createGuestAcc();
    } else if (authToken != null || authToken != 'null') {
      print('Logged In Successfully');
      await startTimer();
    }
    // await startTimer();
    // if (authToken == null || authToken == 'null') {
    //   await createGuestAcc();
    // } else {
    //   print('Logged In Successfully');
    // }
  }

  var ip;
  String? osType;
  Response? response;
  Dio dio = Dio();
  var jsonData;
  double latitude = 0.0;
  double longitude = 0.0;

  Future retrieveIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        setState(() {
          ip = addr.address;
          ipAddress = ip;
        });
      }
    }
  }

  getPlatform() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      osType = 'Android';
      var androidDeviceInfo = await deviceInfo.androidInfo;
      deviceID = androidDeviceInfo.androidId.toString();
    } else if (Platform.isIOS) {
      osType = 'IOS';
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceID = iosDeviceInfo.identifierForVendor.toString();
    }
    platformType = osType;
  }

  formattedTimeZoneOffset() {
    var time = DateTime.now();
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final duration = time.timeZoneOffset, hours = duration.inHours, minutes = duration.inMinutes.remainder(60).abs().toInt();
    setState(() {
      timeZone = '${twoDigits(hours.abs())}${twoDigits(minutes)}';
    });
  }

  getCountry() async {
    await getNativeInfo();
    // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    setState(() {
      countryName = placemarks[0].country.toString();
    });
    print('PLACEMARKS Country: $countryName');
  }

  getNativeInfo() async {
    response = await dio.get('http://ip-api.com/json');
    setState(() {
      jsonData = jsonDecode(response.toString());
      latitude = jsonData['lat'];
      longitude = jsonData['lon'];
    });
  }

  Future setData() async {
    await writeData('authToken', jsonData['responseObject']['authToken'] ?? authToken);
    print(await readData('authToken'));
  }

  Future startTimer() async {
    var duration = Duration(seconds: 2);
    return Timer(duration, route);
  }

  route() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (Route<dynamic> route) => false);
  }

  Future createGuestAcc() async {
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
          "timeZone": timeZone ?? '0',
          "verb": "CreateGuestAccount",
        },
      );
      if (response!.statusCode == 200) {
        print(response);
        if (!mounted) return;
        setState(() {
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['succeeded'] == 1) {
          print('GUEST LOGIN SUCCESSFUL');
          setState(() {
            authToken = jsonData['responseObject']['authToken'];
          });
          if (jsonData['responseObject']['authToken'] != null ||
              jsonData['responseObject']['authToken'] != 'null' ||
              jsonData['responseObject']['authToken'] != '') {
            await setData();
            print(authToken);
            await route();
          }
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage('$IMG_URL/BG2.png'), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Image.asset('$ICON_URL/bettermom.png', height: 200, width: 200)),
      ),
    );
  }

  Future saveAdVideoRewardToUpdateTimer() async {
    var jsonData;
    authToken = await readData('authToken');
    print(authToken);

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
          "rewardDetails": ""
        },
      );
      print(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());

          dailyPremiumCountdownValue = jsonData['dailyPremiumCountdownValue'];
          endTime = (DateTime.now().millisecondsSinceEpoch + 1000 * dailyPremiumCountdownValue * 60).toInt();
        });

        // if (jsonData['succeeded'] == 1) {
        //   // print('isPremium>>>>>> ${jsonData['responseObject']['isPremium']}');
        //   // if (jsonData['responseObject']['isPremium'] == 1) {
        //   //   await writeData('isOneDayPremium', jsonData['responseObject']['isPremium']);
        //   //   // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
        //   // }
        // } else if (jsonData['succeeded'] == 0) {
        //   print('Subscription Not Succeeded');
        //   Navigator.pop(context);
        //   print(response);
        // }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }
}
