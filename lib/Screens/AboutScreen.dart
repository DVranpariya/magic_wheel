import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Screens/ContactUsScreen.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'SplashScreen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Response? response;
  Dio dio = Dio();
  var jsonData, getAbout;
  String? authToken;
  bool _loading = false;

  getAboutData() async {
    authToken = await readData('authToken');
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
          "verb": "GetAboutText",
          "authToken": authToken
        },
      );
      print(response);
      if (response!.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
        });

        if (jsonData['succeeded'] == 1) {
          setState(() {
            getAbout = jsonData['responseObject'];
          });
        } else {
          // Toasty.showtoast(jsonData['message']);
        }
      } else {
        // Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  @override
  void initState() {
    getAboutData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('$IMG_URL/BG2.png'), fit: BoxFit.fill),
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
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: Image.asset('$ICON_URL/ic_back.png', height: 34, width: 34),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: getAbout == null
              ? Container()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppText(text: getAbout == null ? '' : getAbout['title'], fontSize: 40, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: GlassContainer(
                            height: MediaQuery.of(context).size.height,
                            frostColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
                              child: getAbout == null
                                  ? Container()
                                  : AppText(
                                      textAlign: TextAlign.center,
                                      text:
                                          '${getAbout['desc1']} \n\n ${getAbout['desc2']} \n\n${getAbout['desc3']} \n\n${getAbout['desc4']} \n\n${getAbout['desc5']}',
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FrostedBGButton(
                      needIcon: false,
                      text: 'Contact Us',
                      backGround: 'btn-bg1',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsScreen()));
                      },
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
                    SizedBox(height: 10),
                  ],
                ),
        ),
      ),
    );
  }
}
