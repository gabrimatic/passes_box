import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passes_box/core/models/password.dart';
import 'package:passes_box/core/values/colors.dart';
import 'package:passes_box/repository/db.dart';
import 'package:passes_box/view/about_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _btnOpacity = 1.0;

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
                            /*subtitle: Text(
                              _filteredList[index].password,
                            ),*/
                          ),
                          Divider(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _passwordDialog(
                                      model: _filteredList[index],
                                      index: index,
                                    ),
                                color: appColor3,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: appColor3,
                                onPressed: () async =>
                                await _deleteDialog(
                                    _filteredList[index], index),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.copy),
                                color: appColor2,
                                onPressed: () =>
                                    Clipboard.setData(
                                        ClipboardData(
                                            text: _filteredList[index]
                                                .password)),
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
              : Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              curve: Curves.linear,
              duration: Duration(seconds: 2),
              opacity: _btnOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ADD YOUR FIRST PASSWORD !',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54),
                  SizedBox(
                    height: kToolbarHeight,
                  )
                ],
              ),
            ),
                ),
          floatingActionButton: FloatingActionButton.extended(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                'Add password',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _passwordDialog),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.settings),
                  color: appColor3,
                  onPressed: _settings,
                ),
                IconButton(
                    icon: Icon(Icons.delete_sweep),
                    color: appColor3,
                    onPressed: _deleteAllDialog),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.search),
                    color: appColor3,
                    onPressed: _search),
                IconButton(
                    icon: Icon(Icons.filter_list_rounded),
                    color: appColor3,
                    onPressed: _filter),
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

  void _showHint() =>
      Timer.periodic(
          Duration(seconds: 2),
              (timer) =>
          (_btnOpacity == 1.0)
              ? setState(() => _btnOpacity = 0.1)
              : setState(() => _btnOpacity = 1.0));

  Future<void> _getAllPasses() async {
    var list = await PassesDB.selectAll();
    setState(() {
      _mainList = list;
      _filteredList = list;
    });

    _showHint();
  }

  Future<void> _passwordDialog({PasswordModel model, int index}) async {
    var titleC = TextEditingController();
    var passwordC = TextEditingController();
    var imageName = 'social';

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
                                color: appColor3,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Pick an image',
                                style:
                                TextStyle(color: appColor3, fontSize: 16),
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
                                onTap: () => setState(() => imageName = 'bank'),
                                child: Opacity(
                                  opacity: imageName == 'bank' ? 1.0 : 0.4,
                                  child: Image.asset(
                                    'assets/images/bank.png',
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => imageName = 'card'),
                                child: Opacity(
                                  opacity: imageName == 'card' ? 1.0 : 0.4,
                                  child: Image.asset(
                                    'assets/images/card.png',
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    setState(() => imageName = 'email'),
                                child: Opacity(
                                  opacity: imageName == 'email' ? 1.0 : 0.4,
                                  child: Image.asset(
                                    'assets/images/email.png',
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    setState(() => imageName = 'social'),
                                child: Opacity(
                                  opacity: imageName == 'social' ? 1.0 : 0.4,
                                  child: Image.asset(
                                    'assets/images/social.png',
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => imageName = 'web'),
                                child: Opacity(
                                  opacity: imageName == 'web' ? 1.0 : 0.4,
                                  child: Image.asset(
                                    'assets/images/web.png',
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => imageName = 'wifi'),
                                child: Opacity(
                                  opacity: imageName == 'wifi' ? 1.0 : 0.4,
                                  child: Image.asset(
                                    'assets/images/wifi.png',
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 32,
                          ),
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: appColor3),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Enter the password information',
                                style:
                                TextStyle(color: appColor3, fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: titleC,
                            maxLength: 64,
                            maxLines: 1,
                            decoration: InputDecoration(
                                counterText: '',
                                labelText: 'Title',
                                icon: Icon(Icons.article_rounded),
                                border: OutlineInputBorder()),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: passwordC,
                            maxLength: 64,
                            maxLines: 1,
                            decoration: InputDecoration(
                                counterText: '',
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
                color: appColor2,
                textColor: Colors.white,
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
                color: appColor2,
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

  Future<void> _settings() async {
    final storage = new FlutterSecureStorage();
    var auth = await storage.read(key: 'auth');
    var hasAuth = !auth.isNullOrBlank;

    await Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Authentication'),
            leading: Icon(
              Icons.fingerprint_rounded,
              color: appColor3,
            ),
            subtitle: hasAuth
                ? Text('PassesBox uses biometric auth.')
                : Text('Tap here to active biometric auth...'),
            trailing: hasAuth
                ? IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await storage.write(key: 'auth', value: null);
                Get.back(closeOverlays: true);
              },
            )
                : null,
            onTap: hasAuth ? null : _authenticate,
          ),
          Divider(),
          /*     ListTile(
            title: Text('Rate'),
            leading: Icon(Icons.star_rate_outlined),
            //    onTap: () {},
          ),
          Divider(),*/
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info_outline, color: appColor3),
            onTap: () {
              Get.back(closeOverlays: true);
              Get.to(AboutPage());
            },
          ),
          SizedBox(
            height: 8,
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

  Future<void> _authenticate() async {
    var localAuth = LocalAuthentication();
    bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to enable biometric auth.');
    if (didAuthenticate) {
      final storage = new FlutterSecureStorage();
      await storage.write(key: 'auth', value: 'ok');
      Get.back(closeOverlays: true);
    }
  }

  void _filter() {}
}
