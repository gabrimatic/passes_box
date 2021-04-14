import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/models/password.dart';
import '../../../core/values/colors.dart';
import '../../../repository/db.dart';
import '../../about/page/about_page.dart';
import '../cubit/home_cubit.dart';
import '../cubit/io.dart';

Future<void> passwordDialog({
  PasswordModel? model,
}) async {
  final titleC = TextEditingController();
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();
  String? imageName = 'social';

  if (model != null) {
    titleC.text = model.title!;
    passwordC.text = model.password!;
    usernameC.text = model.username!;
    imageName = model.imageName;
  }

  Get.bottomSheet(
    SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 64,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => Column(
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.image_outlined,
                        color: appColor3,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Pick an image',
                        style: TextStyle(color: appColor3, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
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
                        onTap: () => setState(() => imageName = 'email'),
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
                        onTap: () => setState(() => imageName = 'social'),
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
                  const SizedBox(height: 32),
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: appColor3),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Enter the password information',
                        style: TextStyle(color: appColor3, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titleC,
                    maxLength: 64,
                    decoration: const InputDecoration(
                      counterText: '',
                      labelText: 'Title',
                      icon: Icon(Icons.article_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameC,
                    maxLength: 64,
                    decoration: const InputDecoration(
                      counterText: '',
                      labelText: 'Username',
                      icon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordC,
                    maxLength: 64,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      icon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          final pass = StringBuffer();

                          const _chars =
                              'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890@#&*';
                          final random = Random();
                          while (pass.length < 16) {
                            pass.write(
                              _chars[random.nextInt(_chars.length)],
                            );
                          }

                          setState(() => passwordC.text = pass.toString());
                        },
                        icon: const Icon(Icons.shuffle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: Get.width,
            child: FlatButton.icon(
              label: const Text('Save'),
              color: appColor2,
              textColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              icon: const Icon(Icons.save_rounded),
              onPressed: () async {
                if (titleC.text.isEmpty ||
                    passwordC.text.isEmpty ||
                    usernameC.text.isEmpty) return;

                if (model == null) {
                  final passwordModel = PasswordModel(
                    title: titleC.text,
                    password: passwordC.text,
                    username: usernameC.text,
                    imageName: imageName,
                  );
                  await PassesDB.insert(passwordModel);

                  Get.context!.read<HomeCubit>().addPassword(passwordModel);
                } else {
                  final passwordModel = PasswordModel(
                    id: model.id,
                    title: titleC.text,
                    password: passwordC.text,
                    username: usernameC.text,
                    imageName: imageName,
                  );
                  await PassesDB.update(passwordModel);
                  Get.context!.read<HomeCubit>().updatePassword(passwordModel);
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
    shape: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(32), /* topLeft: Radius.circular(32)*/
      ),
    ),
  );
}

Future<void> deleteDialog(
  PasswordModel model,
) =>
    Get.defaultDialog(
      title: 'Delete',
      content: Text('Are you sure to delete "${model.title}"?'),
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await PassesDB.delete(model.id!);
        Get.context!.read<HomeCubit>().removePassword(model.id!);

        Get.back(closeOverlays: true);
      },
      textCancel: 'Cancel',
      onCancel: () => Get.back(closeOverlays: true),
    );

// void search() => Get.bottomSheet(
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding:
//                 EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
//             child: TextFormField(
//               controller: _searchC,
//               onChanged: (text) {
//                 if (text.isNotEmpty) {
//                   setState(() => _filteredList = _mainList
//                       .where((element) => element.title!
//                           .toUpperCase()
//                           .contains(text.toUpperCase()))
//                       .toList());
//                 } else
//                   setState(() => _filteredList = _mainList);
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 border: OutlineInputBorder(),
//                 suffix: GestureDetector(
//                   child: Icon(Icons.close),
//                   onTap: () {
//                     setState(() {
//                       _searchC.clear();
//                       _filteredList = _mainList;
//                     });
//                     Get.back(closeOverlays: true);
//                   },
//                 ),
//                 icon: Icon(Icons.search),
//               ),
//             ),
//           ),
//           Container(
//             width: Get.width,
//             child: FlatButton.icon(
//               label: Text('Done'),
//               color: appColor2,
//               textColor: Colors.white.withOpacity(0.9),
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               icon: Icon(Icons.done),
//               onPressed: () async => Get.back(closeOverlays: true),
//             ),
//           )
//         ],
//       ),
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: OutlineInputBorder(
//           borderSide: BorderSide.none,
//           borderRadius: BorderRadius.only(
//             topRight: Radius.circular(32), /* topLeft: Radius.circular(32)*/
//           )),
//     );

Future<void> settings() async {
  const storage = FlutterSecureStorage();
  final auth = await storage.read(key: 'auth');
  final hasAuth = auth != null;

  await Get.bottomSheet(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Authentication'),
          leading: const Icon(
            Icons.fingerprint_rounded,
            color: appColor3,
          ),
          subtitle: hasAuth
              ? const Text('PassesBox uses biometric auth.')
              : const Text('Tap here to active biometric auth...'),
          trailing: hasAuth
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await storage.write(key: 'auth', value: null);
                    Get.back(closeOverlays: true);
                  },
                )
              : null,
          onTap: hasAuth ? null : authenticate,
        ),
        const Divider(),
        const ListTile(
          title: Text('Backup'),
          leading: Icon(Icons.backup),
          onTap: backup,
        ),
        const Divider(),
        const ListTile(
          title: Text('Restore'),
          leading: Icon(Icons.restore),
          onTap: restore,
        ),
        const Divider(),
/*               ListTile(
            title: Text('Rate'),
            leading: Icon(Icons.star_rate_outlined),
            //    onTap: () {},
          ),
          Divider(),*/
        ListTile(
          title: const Text('About'),
          leading: const Icon(Icons.info_outline, color: appColor3),
          onTap: () {
            Get.back(closeOverlays: true);
            Get.to(AboutPage());
          },
        ),
        const SizedBox(
          height: 8,
        )
      ],
    ),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(32), /* topLeft: Radius.circular(32)*/
      ),
    ),
  );
}

Future<void> authenticate() async {
  final localAuth = LocalAuthentication();

  if (!(await localAuth.canCheckBiometrics)) return;

  final didAuthenticate = await localAuth.authenticate(
    localizedReason: 'Please authenticate to enable biometric auth.',
    biometricOnly: true,
  );
  if (didAuthenticate) {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'auth', value: 'ok');
    Get.back(closeOverlays: true);
  }
}

void filter() {}
