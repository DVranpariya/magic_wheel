import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Screens/HomeScreen.dart';
import 'package:magicwheel/Services/GoogleSignIn.dart';
import 'package:magicwheel/Utils/Constants.dart';

import 'SplashScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Response? response;
  Dio dio = Dio();
  var jsonData;
  String? authToken;
  bool _loading = false;

  createSocialAcc({String? loginChannel, String? socialAuthToken, String? profilePhotoUrl, String? name, String? email}) async {
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
          "authToken": authToken,
          "verb": "CompleteRegistration",
          "channel": loginChannel,
          "channelDetails": socialAuthToken,
          "name": name,
          "email": email,
          "country": countryName,
          "profilePhotoUrl": profilePhotoUrl
        },
      );
      log(response.toString());
      if (response!.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        // print(response);
        if (!mounted) return;
        setState(() {
          jsonData = jsonDecode(response.toString());
        });

        if (jsonData['succeeded'] == 1) {
          setState(() {
            authToken = jsonData['responseObject']['authToken'];
          });
          await setData();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  Future<void> socialFBLogin() async {
    var userData;
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      userData = await FacebookAuth.instance.getUserData();
      print('FB LOGIN DATA >>>>>>>>>>>>>>>> ' + userData.toString());
      var name = userData['name'];
      var email = userData['email'];
      var socialAuthToken = userData['id'];
      var profilePhotoUrl = userData['picture']['data']['url'];

      if (socialAuthToken != null || socialAuthToken != '') {
        createSocialAcc(
          email: email,
          loginChannel: 'FACEBOOK',
          socialAuthToken: socialAuthToken,
          name: name,
          profilePhotoUrl: profilePhotoUrl,
        );
        print('Facebook Logged In');
        print('STATUS Success>>>>>>>>>>>>>>>> ' + result.status.toString());
      }
    } else {
      print('STATUS >>>>>>>>>>>>>>>> ' + result.status.toString());
      print('MESSAGE >>>>>>>>>>>>>>> ' + result.message!);
    }
  }

  Future setData() async {
    await writeData('authToken', authToken ?? jsonData['responseObject']['authToken']);
    await writeData('email', jsonData['responseObject']['authToken']);
    await writeData('name', jsonData['responseObject']['authToken']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('$IMG_URL/BG2.png'), fit: BoxFit.fill),
      ),
      child: Scaffold(
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
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  AppText(text: 'Sign-in', fontSize: 50, fontWeight: FontWeight.w700),
                  AppText(
                    text: 'Sign-in with your Facebook, Google or Twitter\naccount to save your favourite games and access\nother members only features.',
                    textAlign: TextAlign.center,
                    fontSize: 13,
                  ),
                ],
              ),
              Column(
                children: [
                  FrostedBGButton(
                    text: 'Facebook',
                    icon: 'ic_facebook',
                    backGround: 'btn-bg1',
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      // socialFBLogin();
                      socialFBLogin();
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                  ),
                  FrostedBGButton(
                    text: 'Google',
                    icon: 'ic_google',
                    backGround: 'btn-bg2',
                    onTap: () {
                      signInWithGoogle().then((result) {
                        if (result.isNotEmpty) {
                          createSocialAcc(name: gName, socialAuthToken: googleAuth, profilePhotoUrl: gProfilePic, loginChannel: 'GOOGLE', email: gEmail);
                        }
                      });
                    },
                  ),
                  // FrostedBGButton(
                  //   text: 'Twitter',
                  //   icon: 'ic_twitter',
                  //   backGround: 'btn-bg3',
                  //   onTap: () {
                  //     Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  //   },
                  // ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(text: 'By using Magic Wheel you agree to our', fontSize: 13, color: kTextLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: AppText(text: 'Terms of Use', fontSize: 13, textDecoration: TextDecoration.underline, color: kTextLight),
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          launchURL('https://www.google.co.in/');
                        },
                      ),
                      AppText(text: ' & ', fontSize: 13, color: kTextLight),
                      GestureDetector(
                        child: AppText(text: 'Privacy Policy', fontSize: 13, textDecoration: TextDecoration.underline, color: kTextLight),
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          launchURL('https://www.google.co.in/');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(text: 'Magic Wheel is a product of ', fontSize: 13, color: Color(0xff877b9d)),
                      GestureDetector(
                        child: AppText(text: 'Better Mom', fontSize: 13, textDecoration: TextDecoration.underline, color: Color(0xff877b9d)),
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          launchURL('https://bettermom.net');
                        },
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
}
