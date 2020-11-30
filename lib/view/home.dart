import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:passes_box/core/models/password.dart';
import 'package:passes_box/repository/db.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Passes Box'),
        ),
        body: (_mainList.isNotEmpty)
            ? ListView.builder(
                itemCount: _mainList.length,
                itemBuilder: (ctx, index) => Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(_mainList[index].title),
                        subtitle: Text(_mainList[index].password),
                      ),
                      Divider(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _passwordDialog(
                              model: _mainList[index],
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async =>
                                await _deleteDialog(_mainList[index], index),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: _mainList[index].password)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            : Center(
                child: Text(
                  'No password found!',
                  style: TextStyle(fontSize: 24),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _passwordDialog,
        ),
      );

  /// @CODES

  var _mainList = List<PasswordModel>();

  @override
  void initState() {
    super.initState();
    _getAllPasses();
  }

  Future<void> _getAllPasses() async {
    var list = await PassesDB.selectAll();
    setState(() => _mainList = list);
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

    await Get.defaultDialog(
      title: 'Password',
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
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
                    Divider(),
                    TextFormField(
                      controller: titleC,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        icon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    TextFormField(
                      controller: passwordC,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          icon: Icon(Icons.lock),
                          suffix: IconButton(
                            onPressed: () {
                              String pass = '';

                              const _chars =
                                  'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890@#&*';
                              var random = Random();
                              while (pass.length < 16)
                                pass += _chars[random.nextInt(_chars.length)];

                              setState(() => passwordC.text = pass);
                            },
                            icon: Icon(Icons.shuffle),
                          )),
                    ),
                  ],
                ),
              )),
      confirm: OutlinedButton(
        onPressed: () async {
          if (titleC.text.isEmpty || passwordC.text.isEmpty) return;

          if (model == null) {
            var passwordModel = PasswordModel(
              title: titleC.text,
              password: passwordC.text,
              imageName: imageName,
            );
            await PassesDB.insert(passwordModel);
            setState(() => _mainList.add(passwordModel));
          } else {
            var passwordModel = PasswordModel(
              id: model.id,
              title: titleC.text,
              password: passwordC.text,
              imageName: imageName,
            );
            await PassesDB.update(passwordModel);
            setState(() => _mainList[index] = passwordModel);
          }
          Get.back(closeOverlays: true);
        },
        child: Text('Save'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(closeOverlays: true),
        child: Text('Cancel'),
      ),
    );
  }

  Future<void> _deleteDialog(PasswordModel model, int index) async {
    await Get.defaultDialog(
      title: 'Delete',
      content: Text('Are you sure to delete ${model.title}?'),
      confirm: OutlinedButton(
        onPressed: () async {
          await PassesDB.delete(_mainList[index].id);
          setState(() => _mainList.removeAt(index));
        },
        child: Text('Delete'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(closeOverlays: true),
        child: Text('Cancel'),
      ),
    );
  }
}
