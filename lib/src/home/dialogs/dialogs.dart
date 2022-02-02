import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import "package:universal_html/html.dart" as html;

import '../../../core/index.dart';
import '../../../core/models/password.dart';
import '../../about/page/about_page.dart';
import '../controller/controller.dart';
import '../controller/io.dart';

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

  final widget = Column(
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
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.url,
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
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
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
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          textColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          icon: const Icon(Icons.save_rounded),
          onPressed: () async {
            if (passwordC.text.isEmpty) return;

            if (model == null) {
              final passwordModel = PasswordModel(
                title: titleC.text,
                password: passwordC.text,
                username: usernameC.text,
                imageName: imageName,
              );
              HomeController.to.addPassword(passwordModel);
            } else {
              model
                ..title = titleC.text
                ..password = passwordC.text
                ..username = usernameC.text
                ..imageName = imageName;

              HomeController.to.updatePassword(model);
            }

            appPopDialog();
          },
        ),
      )
    ],
  );

  Get.bottomSheet(
    SingleChildScrollView(child: widget),
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
      content: Text('Are you sure to delete the "${model.title}"?'),
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        HomeController.to.removePassword(model);

        appPopDialog();
      },
      textCancel: 'Cancel',
      onCancel: appPopDialog,
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
  final canUseAuth = kIsWeb || !GetPlatform.isMobile
      ? false
      : await localAuth.isDeviceSupported();

  bool hasAuth = false;
  if (canUseAuth) {
    final auth = appSH.getBool('auth');
    hasAuth = auth != null;
  }

  await Get.bottomSheet(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kIsWeb)
          ListTile(
            title: const Text('Download Android app'),
            leading: const Icon(
              Icons.android,
              color: appColor3,
            ),
            onTap: () async {
              final file = await rootBundle.load('assets/files/passesbox.apk');
              final _base64 = base64Encode(file.buffer.asUint8List());
              final anchor = html.AnchorElement(
                  href: 'data:application/octet-stream;base64,$_base64')
                ..target = 'blank';

              anchor.download = 'passesbox.apk';

              html.document.body!.append(anchor);
              anchor.click();
              anchor.remove();
            },
          ),
        if (kIsWeb) const Divider(),
        if (kIsWeb)
          ListTile(
            title: const Text('Download Windows app'),
            leading: const Icon(
              Icons.window,
              color: appColor3,
            ),
            onTap: () async {
              final file =
                  await rootBundle.load('assets/files/passesbox_windows.zip');
              final _base64 = base64Encode(file.buffer.asUint8List());
              final anchor = html.AnchorElement(
                  href: 'data:application/octet-stream;base64,$_base64')
                ..target = 'blank';

              anchor.download = 'passesbox_windows.zip';

              html.document.body!.append(anchor);
              anchor.click();
              anchor.remove();
            },
          ),
        if (canUseAuth)
          ListTile(
            title: const Text('Authentication'),
            leading: Icon(
              Icons.fingerprint_rounded,
              color: canUseAuth ? appColor3 : null,
            ),
            subtitle: canUseAuth
                ? (hasAuth
                    ? const Text('PassesBox is using biometric auth.')
                    : const Text('Tap here to active biometric auth.'))
                : const Text('Your device does not support biometric auth.'),
            trailing: (canUseAuth && hasAuth)
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await appSH.setBool('auth', false);
                      appPopDialog();
                    },
                  )
                : null,
            onTap: (canUseAuth && !hasAuth) ? _authenticate : null,
          ),
        if (kIsWeb || canUseAuth) const Divider(),
        const ListTile(
          title: Text('Backup'),
          leading: Icon(
            Icons.backup_outlined,
            color: appColor3,
          ),
          onTap: backup,
        ),
        const Divider(),
        const ListTile(
          title: Text('Restore'),
          leading: Icon(
            Icons.restore,
            color: appColor3,
          ),
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
            appPopDialog();
            Get.toNamed(AboutPage.name);
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

Future<void> _authenticate() async {
  // await Permission.sensors.request();
  final didAuthenticate = await localAuth.authenticate(
    localizedReason: 'Please authenticate to enable biometric auth.',
    // biometricOnly: true,
  );
  if (didAuthenticate) {
    await appSH.setBool('auth', true);
    appPopDialog();
  }
}
