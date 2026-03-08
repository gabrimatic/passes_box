import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

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
    titleC.text = model.title ?? '';
    passwordC.text = model.password ?? '';
    usernameC.text = model.username ?? '';
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
              const Row(
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
              const Row(
                children: [
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

                      const chars =
                          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890@#&*';
                      final random = Random.secure();
                      while (pass.length < 16) {
                        pass.write(
                          chars[random.nextInt(chars.length)],
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
        child: ElevatedButton.icon(
          label: const Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: appColor2,
            padding: const EdgeInsets.symmetric(vertical: 20),
            foregroundColor: Colors.white,
          ),
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
              await HomeController.to.addPassword(passwordModel);
            } else {
              model
                ..title = titleC.text
                ..password = passwordC.text
                ..username = usernameC.text
                ..imageName = imageName;

              await HomeController.to.updatePassword(model);
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
        topRight: Radius.circular(32),
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
        await HomeController.to.removePassword(model);

        appPopDialog();
      },
      textCancel: 'Cancel',
      onCancel: appPopDialog,
    );

Future<void> settings() async {
  final canUseAuth = kIsWeb || !GetPlatform.isMobile
      ? false
      : await localAuth.isDeviceSupported();

  bool hasAuth = false;
  if (canUseAuth) {
    final auth = appSH.getBool('auth');
    hasAuth = auth == true;
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
            onTap: () {
              launchUrl(
                Uri.parse(
                  "https://github.com/gabrimatic/passes_box/releases/latest",
                ),
              );
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
            onTap: () {
              launchUrl(
                Uri.parse(
                  "https://github.com/gabrimatic/passes_box/releases/latest",
                ),
              );
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
        topRight: Radius.circular(32),
      ),
    ),
  );
}

Future<void> _authenticate() async {
  final didAuthenticate = await localAuth.authenticate(
    localizedReason: 'Please authenticate to enable biometric auth.',
  );
  if (didAuthenticate) {
    await appSH.setBool('auth', true);
    appPopDialog();
  }
}
