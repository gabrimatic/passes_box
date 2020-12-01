import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:passes_box/core/models/password.dart';
import 'package:passes_box/core/values/colors.dart';
import 'package:passes_box/repository/db.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _btmMargin = kToolbarHeight;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: (_filteredList.isNotEmpty)
              ? StaggeredGridView.countBuilder(
                  padding: EdgeInsets.all(6),
                  crossAxisCount: 4,
                  itemCount: _filteredList.length,
                  itemBuilder: (BuildContext context, int index) => Card(
                    shape: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.only(topRight: Radius.circular(32)),
                        borderSide:
                            BorderSide(width: 0.1, color: Colors.blueGrey)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            trailing: Image.asset(
                              'assets/images/' +
                                  _filteredList[index].imageName +
                                  '.png',
                              width: 32,
                              height: 32,
                            ),
                            title: Text(
                              _filteredList[index].title,
                            ),
                            subtitle: Text(
                              _filteredList[index].password,
                            ),
                          ),
                          Divider(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _passwordDialog(
                                  model: _filteredList[index],
                                  index: index,
                                ),
                                color: appGrayColor,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: appGrayColor,
                                onPressed: () async => await _deleteDialog(
                                    _filteredList[index], index),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.copy),
                                color: appOrangeColor,
                                onPressed: () => Clipboard.setData(
                                    ClipboardData(
                                        text: _filteredList[index].password)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                )
              : AnimatedContainer(
                  curve: Curves.ease,
                  padding: EdgeInsets.only(bottom: _btmMargin),
                  duration: Duration(milliseconds: 500),
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ADD YOUR FIRST PASSWORD!',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded)
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
              icon: Icon(
                Icons.add,
                color: Colors.white.withOpacity(0.9),
              ),
              label: Text(
                'Add password',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              onPressed: _passwordDialog),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.settings),
                  color: appGrayColor,
                  onPressed: () {},
                ),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.search),
                    color: appGrayColor,
                    onPressed: _search),
                IconButton(
                    icon: Icon(Icons.delete_sweep),
                    color: appGrayColor,
                    onPressed: _deleteAllDialog),
              ],
            ),
          ),
        ),
      );

  /// @CODES

  var _filteredList = List<PasswordModel>();
  var _mainList = List<PasswordModel>();
  var _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAllPasses();
  }

  Future<void> _getAllPasses() async {
    var list = await PassesDB.selectAll();
    setState(() {
      _mainList = list;
      _filteredList = list;
    });
    if (_filteredList.isEmpty)
      Timer.periodic(
          Duration(milliseconds: 1500),
          (timer) => (_btmMargin < 100)
              ? setState(() => _btmMargin = 100)
              : setState(() => _btmMargin = kToolbarHeight));
  }

  Future<void> _passwordDialog({PasswordModel model, int index}) async {
    var titleC = TextEditingController();
    var passwordC = TextEditingController();
    var imageName = '';

    if (model != null) {
      titleC.text = model.title;
      passwordC.text = model.password;
      imageName = model.imageName;
    }

    Get.bottomSheet(
      SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
              EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 64),
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) =>
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: appGrayColor,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Pick a image',
                                style: TextStyle(
                                    color: appGrayColor, fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: 8,
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              InkWell(
                                onTap: () => imageName = 'wifi',
                                child: Image.asset(
                                  'assets/images/wifi.png',
                                  width: 52,
                                  height: 52,
                                ),
                              ),
                              InkWell(
                                onTap: () => imageName = 'wifi',
                                child: Image.asset(
                                  'assets/images/wifi.png',
                                  width: 52,
                                  height: 52,
                                ),
                              ),
                              InkWell(
                                onTap: () => imageName = 'wifi',
                                child: Image.asset(
                                  'assets/images/wifi.png',
                                  width: 52,
                                  height: 52,
                                ),
                              ),
                              InkWell(
                                onTap: () => imageName = 'wifi',
                                child: Image.asset(
                                  'assets/images/wifi.png',
                                  width: 52,
                                  height: 52,
                                ),
                              ),
                              InkWell(
                                onTap: () => imageName = 'wifi',
                                child: Image.asset(
                                  'assets/images/wifi.png',
                                  width: 52,
                                  height: 52,
                                ),
                              ),
                              InkWell(
                                onTap: () => imageName = 'wifi',
                                child: Image.asset(
                                  'assets/images/wifi.png',
                                  width: 52,
                                  height: 52,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 32,
                          ),
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: appGrayColor),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Enter the password information',
                                style: TextStyle(
                                    color: appGrayColor, fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: titleC,
                            decoration: InputDecoration(
                                labelText: 'Title',
                                icon: Icon(Icons.article_rounded),
                                border: OutlineInputBorder()),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: passwordC,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    String pass = '';

                                    const _chars =
                                        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890@#&*';
                                    var random = Random();
                                    while (pass.length < 16)
                                      pass +=
                                      _chars[random.nextInt(_chars.length)];

                                    setState(() => passwordC.text = pass);
                                  },
                                  icon: Icon(Icons.shuffle),
                                )),
                          ),
                        ],
                      )),
            ),
            Container(
              width: Get.width,
              child: FlatButton.icon(
                label: Text('Save'),
                color: appOrangeColor,
                textColor: Colors.white.withOpacity(0.9),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                icon: Icon(Icons.save_rounded),
                onPressed: () async {
                  if (titleC.text.isEmpty || passwordC.text.isEmpty) return;

                  if (model == null) {
                    var passwordModel = PasswordModel(
                      title: titleC.text,
                      password: passwordC.text,
                      imageName: imageName,
                    );
                    await PassesDB.insert(passwordModel);
                    setState(() => _filteredList.add(passwordModel));
                  } else {
                    var passwordModel = PasswordModel(
                      id: model.id,
                      title: titleC.text,
                      password: passwordC.text,
                      imageName: imageName,
                    );
                    await PassesDB.update(passwordModel);
                    setState(() => _filteredList[index] = passwordModel);
                  }
                  Get.back(closeOverlays: true);
                },
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32), /* topLeft: Radius.circular(32)*/
          )),
    );
  }

  Future<void> _deleteDialog(PasswordModel model, int index) async =>
      await Get.defaultDialog(
        title: 'Delete',
        content: Text('Are you sure to delete \"${model.title}\"?'),
        textConfirm: 'Delete',
        confirmTextColor: Colors.white,
        onConfirm: () async {
          await PassesDB.delete(_filteredList[index].id);
          setState(() => _filteredList.removeAt(index));
          Get.back(closeOverlays: true);
        },
        textCancel: 'Cancel',
        onCancel: () => Get.back(closeOverlays: true),
      );

  Future<void> _deleteAllDialog() async =>
      await Get.defaultDialog(
        title: 'Delete all',
        content: Text('Are you sure to delete all passwords?'),
        textConfirm: 'Delete all',
        confirmTextColor: Colors.white,
        onConfirm: () async {
          await PassesDB.deleteAll();
          setState(() => _filteredList.clear());
          Get.back(closeOverlays: true);
        },
        textCancel: 'Cancel',
        onCancel: () => Get.back(closeOverlays: true),
      );

  void _search() =>
      Get.bottomSheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
              EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
              child: TextFormField(
                controller: _searchC,
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    setState(() =>
                    _filteredList = _mainList
                        .where((element) =>
                        element.title
                            .toUpperCase()
                            .contains(text.toUpperCase()))
                        .toList());
                  } else
                    setState(() => _filteredList = _mainList);
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  suffix: GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () {
                      setState(() {
                        _searchC.clear();
                        _filteredList = _mainList;
                      });
                      Get.back(closeOverlays: true);
                    },
                  ),
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            Container(
              width: Get.width,
              child: FlatButton.icon(
                label: Text('Done'),
                color: appOrangeColor,
                textColor: Colors.white.withOpacity(0.9),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                icon: Icon(Icons.done),
                onPressed: () async => Get.back(closeOverlays: true),
              ),
            )
          ],
        ),
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(32), /* topLeft: Radius.circular(32)*/
            )),
      );
}
