import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magicwheel/Utils/Constants.dart';

class AppText extends StatelessWidget {
  final String text, fontFamily;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double? letterSpacing;
  final double? height;
  final TextDecoration textDecoration;
  final TextAlign textAlign;
  final int maxLines;
  final FontStyle fontStyle;
  AppText({
    this.text = '',
    this.fontSize = 14,
    this.color = Colors.white,
    this.fontWeight = FontWeight.w300,
    this.fontFamily = 'Poppins',
    this.letterSpacing,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.start,
    this.height = 1.4,
    this.maxLines = 100,
    this.fontStyle = FontStyle.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        height: height,
        color: color,
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final double height;
  final double width;
  final Color frostColor;
  final Color borderColor;
  final int frostAlphaValue;
  final int borderAlphaValue;
  final int borderRadius;
  final Widget? child;
  GlassContainer({
    this.height = 30,
    this.width = 80,
    this.frostColor = Colors.black,
    this.frostAlphaValue = 50,
    this.borderRadius = 40,
    this.child,
    this.borderColor = Colors.grey,
    this.borderAlphaValue = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.toDouble()),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: height.toDouble(),
          // width: width.toDouble(),
          decoration: BoxDecoration(
            color: frostColor.withAlpha(frostAlphaValue),
            border: Border.all(color: borderColor.withAlpha(borderAlphaValue)),
            borderRadius: BorderRadius.circular(borderRadius.toDouble()),
          ),
          child: child,
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    this.controller,
    this.input,
    this.label,
    this.maxLines,
    this.fieldHeight = 44,
    this.focusNode,
    this.hintText,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.initialValue,
    this.readOnly = false,
    this.suffix,
  });

  final TextEditingController? controller;
  final TextInputType? input;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? label;
  final int? maxLines;
  final double fieldHeight;
  final FocusNode? focusNode;
  final String? hintText;
  final Function()? onTap;
  final String? initialValue;
  final bool readOnly;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Container(
            height: fieldHeight,
            child: TextFormField(
              readOnly: readOnly,
              cursorColor: Colors.white60,
              focusNode: focusNode,
              maxLines: maxLines,
              controller: controller,
              keyboardType: input,
              onChanged: onChanged,
              onTap: onTap,
              inputFormatters: inputFormatters,
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13),
              decoration: InputDecoration(
                suffix: suffix,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white30, fontFamily: 'Poppins', fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                border: kOutlineInputBorder,
                focusedBorder: kOutlineInputBorder,
                enabledBorder: kOutlineInputBorder,
                errorBorder: kOutlineInputBorder,
                focusedErrorBorder: kOutlineInputBorder,
              ),
            ),
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}

class FrostedBGButton extends StatelessWidget {
  final String backGround;
  final String icon;
  final String text;
  final void Function() onTap;
  final bool needIcon;
  FrostedBGButton({
    required this.backGround,
    this.icon = '',
    required this.text,
    required this.onTap,
    this.needIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('$IMG_URL/$backGround.png'),
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            border: Border.all(color: Colors.grey.withAlpha(80)),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              needIcon == true ? Image.asset('$ICON_URL/$icon.png', height: 24) : Container(),
                              needIcon == true ? SizedBox(width: 12) : Container(),
                              AppText(text: text, fontWeight: FontWeight.w500, fontSize: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class Time extends StatelessWidget {
  final String time;
  final String unit;
  Time({required this.time, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppText(text: time, height: 1.3, fontWeight: FontWeight.w500, fontSize: 12),
        AppText(text: unit, color: Colors.white, fontSize: 9),
      ],
    );
  }
}

class Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppText(text: ':', height: 1.3, fontWeight: FontWeight.w300);
  }
}

class CounterTile extends StatelessWidget {
  final String? text;
  final FontWeight fontWeight;
  final Color color;
  final int fontSize;

  CounterTile({this.text, this.fontWeight = FontWeight.w700, this.color = kCounterTextColor, this.fontSize = 9});

  @override
  Widget build(BuildContext context) {
    return AppText(text: text!, fontWeight: fontWeight, color: color, fontSize: fontSize.toDouble());
  }
}

class SmallBanner extends StatelessWidget {
  final String imageUrl;
  final String favoriteCount;
  final String playCount;
  final void Function() onTap;
  const SmallBanner({required this.imageUrl, required this.favoriteCount, required this.playCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 100,
                fit: BoxFit.cover,
                imageUrl: imageUrl,
                placeholder: (context, url) => Center(child: SizedBox(height: 20, width: 20, child: kProgressIndicator)),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            GlassContainer(
              frostColor: Colors.black,
              borderColor: Colors.white,
              frostAlphaValue: 10,
              width: MediaQuery.of(context).size.width.toInt() * 0.3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Image.asset('$ICON_URL/filled_star.png', height: 10, width: 10),
                    SizedBox(width: 5),
                    AppText(text: favoriteCount, fontSize: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: VerticalDivider(color: Colors.white, width: 10),
                    ),
                    AppText(text: 'Played $playCount', fontSize: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
