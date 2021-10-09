import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:magicwheel/Components/CustomWidgets.dart';
import 'package:magicwheel/Utils/Constants.dart';

class FilterGameListScreen extends StatefulWidget {
  @override
  _FilterGameListScreenState createState() => _FilterGameListScreenState();
}

class _FilterGameListScreenState extends State<FilterGameListScreen> {
  List gameCategory = ['Home Activities', 'Outdoor Activities', 'Cognitive Development', 'Animals', 'Nature'];
  List sortBy = ['Trending', 'Most Favourites', 'Newest'];
  List ageData = [
    {'age': 1, 'value': false},
    {'age': 2, 'value': false},
    {'age': 3, 'value': false},
    {'age': 4, 'value': false},
    {'age': 5, 'value': false},
    {'age': 6, 'value': false},
  ];
  List tempList = [];
  int? selectedIndex;
  dynamic gameCatValue = 0;
  dynamic sortValue = 0;
  List temp = [];
  String? selectedAges;

  Response? response;
  Dio dio = Dio();
  var jsonData, games;
  String? authToken;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('$IMG_URL/BG3.png'), fit: BoxFit.fill),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: AppText(text: 'Filter', fontSize: 26, fontWeight: FontWeight.w700),
          actions: [
            GestureDetector(
              child: Image.asset('$ICON_URL/ic_close.png', height: 40, width: 40),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 16)
          ],
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(text: 'Games Category', fontSize: 16, fontWeight: FontWeight.w300),
                            SizedBox(height: 14),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: gameCategory.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(text: gameCategory[index], fontSize: 20, fontWeight: FontWeight.w500),
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
                                          groupValue: gameCatValue,
                                          onChanged: (val) => setState(() {
                                            print(val);
                                            gameCatValue = val!;
                                          }),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                            Divider(color: Colors.white, height: 40),
                            AppText(text: 'Select Age', fontSize: 16, fontWeight: FontWeight.w300),
                            SizedBox(height: 14),
                            GlassContainer(
                              frostColor: Colors.white,
                              frostAlphaValue: 30,
                              width: MediaQuery.of(context).size.width - 20,
                              height: 60,
                              child: Center(
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: ageData.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  ageData[index]['value'] == true
                                                      ? BoxShadow(color: Colors.black26, blurRadius: 1, spreadRadius: 1, offset: Offset(0, 1))
                                                      : BoxShadow(color: Colors.transparent)
                                                ],
                                                gradient: LinearGradient(
                                                  colors: [
                                                    ageData[index]['value'] == true ? Colors.red : Colors.red.withAlpha(80),
                                                    ageData[index]['value'] == true ? kPrimaryColor1.withOpacity(0.9) : kPrimaryColor1.withAlpha(70),
                                                    ageData[index]['value'] == true ? kPrimaryColor2 : kPrimaryColor2.withAlpha(80)
                                                  ],
                                                  begin: Alignment.bottomRight,
                                                  end: Alignment.topLeft,
                                                ),
                                              ),
                                              child: AppText(
                                                  text: index == 5 ? '${ageData[index]['age']}+' : '${ageData[index]['age']}',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                if (tempList.contains(ageData[index]['age'])) {
                                                  ageData[index]['value'] = !ageData[index]['value'];
                                                  tempList.remove(ageData[index]['age']);
                                                } else {
                                                  ageData[index]['value'] = !ageData[index]['value'];
                                                  tempList.add(ageData[index]['age']);
                                                }
                                                tempList.sort((a, b) => a.compareTo(b));
                                                selectedAges = tempList.join('|');
                                              });
                                              print(selectedAges);
                                            },
                                          ),
                                          index == 5 ? Container() : SizedBox(width: 8)
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Divider(color: Colors.white, height: 40),
                            AppText(text: 'Sort By', fontSize: 14, fontWeight: FontWeight.w300),
                            SizedBox(height: 14),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: sortBy.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(text: sortBy[index], fontSize: 20, fontWeight: FontWeight.w500),
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
                                          groupValue: sortValue,
                                          onChanged: (val) => setState(() {
                                            sortValue = val!;
                                          }),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      FrostedBGButton(
                        needIcon: false,
                        text: 'APPLY FILTERS',
                        backGround: 'btn-bg1',
                        onTap: () {
                          Navigator.pop(
                            context,
                            {
                              'isFiltered': true,
                              'category': gameCatValue + 1,
                              'ageLimit': selectedAges,
                              'sort': sortValue + 1,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _radioButton({String? title, int? value, void Function(int? val)? onChanged, int? groupValue}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       AppText(text: title!, fontSize: 20, fontWeight: FontWeight.w500),
  //       Theme(
  //         data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.grey),
  //         child: SizedBox(
  //           height: 40,
  //           child: Radio(
  //             splashRadius: 8,
  //             activeColor: Colors.white,
  //             focusColor: Colors.white,
  //             overlayColor: MaterialStateProperty.all(Colors.white),
  //             fillColor: MaterialStateProperty.all(Colors.white),
  //             value: value,
  //             groupValue: groupValue,
  //             onChanged: onChanged!,
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }
}
