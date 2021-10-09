import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Screens/HomeScreen.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'SplashScreen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  List _options = ['Contact', 'Support', 'Suggestion', 'Cooperation', 'Other'];
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController message = TextEditingController();

  Response? response;
  Dio dio = Dio();
  var profileData;
  String? authToken;
  bool _loading = false;
  String? category;

  Future sendMessage() async {
    var jsonData;
    authToken = await readData('authToken');
    // print(authToken);
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
          "verb": "SendMessage",
          "authToken": authToken,
          "name": name.text,
          "email": email.text,
          "category": category,
          "message": message.text
        },
      );
      print(response);
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          Toasty.showtoast('Message Sent Successfully');
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (Route<dynamic> route) => false);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('$IMG_URL/BG2.png'), fit: BoxFit.fill),
      ),
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: kProgressIndicator,
        opacity: 0,
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
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    AppText(text: 'Contact Us', fontSize: 44, fontWeight: FontWeight.w700),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: AppText(
                        text: 'You may use the following form to reach us\nregarding your questions and comments.',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomTextField(fieldHeight: 54, controller: name, hintText: 'Name'),
                    CustomTextField(fieldHeight: 54, controller: email, hintText: 'Email Address'),
                    Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.white30, fontFamily: 'Poppins', fontSize: 13),
                          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                          border: kOutlineInputBorder,
                          focusedBorder: kOutlineInputBorder,
                          enabledBorder: kOutlineInputBorder,
                          errorBorder: kOutlineInputBorder,
                          focusedErrorBorder: kOutlineInputBorder,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            iconDisabledColor: Colors.white30,
                            iconEnabledColor: Colors.white30,
                            hint: AppText(
                              text: category ?? 'Select Category',
                              color: category == null ? Colors.white30 : Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                            // value: category,

                            // isDense: true,
                            // dropdownColor: Colors.white.withAlpha(80),
                            elevation: 0,
                            isExpanded: true,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black),
                            items: [
                              // DropdownMenuItem(child: Text("Select Category"), value: ""),
                              DropdownMenuItem(child: Text("Contact"), value: "Contact"),
                              DropdownMenuItem(child: Text("Support"), value: "Support"),
                              DropdownMenuItem(child: Text("Suggestion"), value: "Suggestion"),
                              DropdownMenuItem(child: Text("Cooperation"), value: "Cooperation"),
                              DropdownMenuItem(child: Text("Other"), value: "Other"),
                            ],
                            onChanged: (newValue) {
                              print(newValue);
                              setState(() {
                                category = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // CustomTextField(
                    //   fieldHeight: 54,
                    //   hintText: 'Category',
                    //   readOnly: true,
                    //   suffix: PopupMenuButton(
                    //     offset: Offset(0, 44),
                    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    //     child: Icon(Icons.arrow_drop_down_rounded, color: Colors.white60),
                    //     itemBuilder: (BuildContext context) {
                    //       return _options
                    //           .map((day) => PopupMenuItem(child: Container(width: MediaQuery.of(context).size.width, child: Text(day)), value: day))
                    //           .toList();
                    //     },
                    //   ),
                    // ),
                    CustomTextField(fieldHeight: 130, controller: message, hintText: 'Your Message', maxLines: 5),
                  ],
                ),
                FrostedBGButton(
                  needIcon: false,
                  text: 'Send Message',
                  backGround: 'btn-bg1',
                  onTap: () {
                    sendMessage();
                    // Navigator.pop(context);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
