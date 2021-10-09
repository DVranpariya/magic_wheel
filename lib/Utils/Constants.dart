import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

const String IMG_URL = 'assets/images';
const String ICON_URL = 'assets/icons';
const Color kPrimaryColor1 = Color(0xffE44B9B);
const Color kPrimaryColor2 = Color(0xff2F23AD);
const Color kTextLight = Color(0xff877b9d);
const Color kCounterTextColor = Color(0xff48098d);

const BASE_URL = 'https://mwdev.smartclinic.net/MagicWheelApi';

const clientVersion = '1';
const apiVersion = '1';

final kOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(40),
  borderSide: BorderSide(color: Colors.white60, width: 1.0),
);

final kProgressIndicator = CircularProgressIndicator(color: Colors.grey.shade400, strokeWidth: 1);
Future writeData(String? key, dynamic value) async {
  final getX = GetStorage();
  getX.write(key!, value);
}

Future readData(String? key) async {
  final getX = GetStorage();
  final data = getX.read(key!);
  return data;
}

Future removeData(String? key) async {
  final getX = GetStorage();
  final data = getX.remove(key!);
  return data;
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class Toasty {
  static showtoast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.black,
      backgroundColor: Colors.white.withOpacity(0.8),
    );
  }
}
