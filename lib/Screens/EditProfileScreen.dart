import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Screens/HomeScreen.dart';
import 'package:magicwheel/Utils/Constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:numberpicker/numberpicker.dart';

import 'SplashScreen.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  // TextEditingController dob = TextEditingController();
  File? _image;
  String fileName = '';

  Response? response;
  Dio dio = Dio();
  var profileData;
  String? authToken;
  bool _loading = false;
  var base64Image;
  int? selectedIndex;
  int _selectedAge = 0;
  String profilePic = '';

  initState() {
    getProfile();
    super.initState();
  }

  // Future getImage() async {
  //   final _picker = ImagePicker();
  //   // PickedFile? image = await _picker.getImage(source: ImageSource.gallery, imageQuality: 60);
  //   final PickedFile? image = await _picker.getImage(source: ImageSource.gallery);
  //   base64Image = base64Encode(File(image!.path).readAsBytesSync());
  //   setState(() {
  //     // final bytes = ;
  //     _image = File(image.path);
  //     // fileName = _image!.path.split('/').last;
  //     log("base64Image : $base64Image");
  //   });
  // }
  String? path;
  Future pickImage() async {
    List<Media>? res = await ImagesPicker.pick(
      count: 1,
      pickType: PickType.image,
      // language: Language.System,
      // maxSize: 500,
      // cropOpt: CropOption(
      //   aspectRatio: CropAspectRatio.wh16x9,
      // ),
    );
    if (res != null) {
      print(res.map((e) => e.path).toList());
      setState(() {
        path = res[0].path;
        _image = File(path!);
        base64Image = base64Encode(File(path!).readAsBytesSync());
      });
      print(base64Image);
      print(_image);
      // bool status = await ImagesPicker.saveImageToAlbum(File(res[0]?.path));
      // print(status);
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
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(height: 40),
                  AppText(text: 'Update Profile', fontSize: 40, fontWeight: FontWeight.w700),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Stack(
                      children: [
                        profilePic == '' || _image != null
                            ? _image == null
                                ? Container(
                                    height: 110,
                                    width: 110,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                    child: Image.asset('$ICON_URL/user-profile.png', height: 50, width: 50),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: /*Image.asset('assets/icons/an_user (1).png', width: 70, height: 70, fit: BoxFit.cover)*/
                                        Image.file(_image!, width: 110, height: 110, fit: BoxFit.cover),
                                  )
                            : Container(
                                height: 110,
                                width: 110,
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
                                        ? Container(
                                            height: 110,
                                            width: 110,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                            child: Image.asset('$ICON_URL/user-profile.png', height: 50, width: 50),
                                          )
                                        : Container(
                                            height: 110,
                                            width: 110,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                            child: Image.asset('$ICON_URL/user-profile.png', height: 50, width: 50),
                                          ),
                                  ),
                                ),
                              ),
                        // : _image != null
                        //     ? Container(
                        //         height: 110,
                        //         width: 110,
                        //         alignment: Alignment.center,
                        //         child: ClipRRect(
                        //           borderRadius: BorderRadius.circular(70),
                        //           child: Image.file(_image!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                        //         ),
                        //       )
                        //     : Container(
                        //         height: 110,
                        //         width: 110,
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        //         child: Image.asset('$ICON_URL/user-profile.png', height: 50, width: 50),
                        //       ),
                        /* : Container(
                                height: 110,
                                width: 110,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                child: Image.asset('$ICON_URL/user-profile.png', height: 50, width: 50),
                              ),*/
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            child: Image.asset('$ICON_URL/add.png', height: 30, width: 30),
                            onTap: pickImage,
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      CustomTextField(fieldHeight: 60, hintText: 'Name', controller: name, maxLines: 1, input: TextInputType.name),
                      CustomTextField(fieldHeight: 60, hintText: 'Email Address', controller: email, maxLines: 1, input: TextInputType.emailAddress),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(text: 'Select Child Age'),
                            SizedBox(height: 6),
                            GlassContainer(
                              frostColor: Colors.white,
                              frostAlphaValue: 30,
                              height: 54,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: double.infinity,
                                    child: NumberPicker(
                                      value: _selectedAge,
                                      minValue: 0,
                                      maxValue: 10,
                                      itemCount: 7,
                                      itemWidth: MediaQuery.of(context).size.width / 8,
                                      axis: Axis.horizontal,
                                      onChanged: (value) => setState(() => _selectedAge = value),
                                      textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                      selectedTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.red, kPrimaryColor1.withOpacity(0.9), kPrimaryColor2],
                                          begin: Alignment.bottomRight,
                                          end: Alignment.topLeft,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  FrostedBGButton(
                    needIcon: false,
                    text: 'Update',
                    backGround: 'btn-bg1',
                    onTap: () {
                      updateProfile();
                      // Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future getProfile() async {
    var jsonData;
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
          "verb": "GetUserProfile",
          "authToken": authToken,
        },
      );
      print(response);
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          setState(() {
            profileData = jsonData['responseObject'];
            name = TextEditingController(text: profileData['name']);
            email = TextEditingController(text: profileData['email']);
            profilePic = profileData['profilePhotoUrl'];
            _selectedAge = profileData['ageOfChild'];
          });
          print(profilePic);
        } else {
          print('Not Succeeded');
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }

  Future updateProfile() async {
    var jsonData;
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
          "verb": "UpdateUserProfile",
          "authToken": authToken,
          "name": name.text,
          "email": email.text,
          "ageOfChild": _selectedAge,
          "profilePhotoData": base64Image
        },
      );
      print(response);
      if (response!.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
          _loading = false;
        });
        if (jsonData['succeeded'] == 1) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
        } else {
          print('Not Succeeded');
        }
      }
    } catch (e) {
      print('Exception Detected >>> ${e.toString()} <<<');
    }
  }
}
