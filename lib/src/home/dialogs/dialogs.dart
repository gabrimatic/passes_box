import 'package:flutter/foundation.dart';
import 'package:otp_auth/otp_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/index.dart';
import '../../../core/models/password.dart';
import '../../about/page/about_page.dart';
import '../../qr/qr_import_page.dart';
import '../../qr/qr_scan_page.dart';
import '../../recycle_bin/page.dart';
import '../controller/controller.dart';
import '../controller/io.dart';
import '../widgets/generator_sheet.dart';

Future<void> passwordDialog({
  PasswordModel? model,
}) async {
  final titleC = TextEditingController();
  final usernameC = TextEditingController();
  final passwordC = TextEditingController();
  final urlC = TextEditingController();
  final notesC = TextEditingController();
  final totpC = TextEditingController();
  String? imageName = 'social';

  if (model != null) {
    titleC.text = model.title ?? '';
    passwordC.text = model.password ?? '';
    usernameC.text = model.username ?? '';
    urlC.text = model.url ?? '';
    notesC.text = model.notes ?? '';
    totpC.text = model.totpSecret ?? '';
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
          builder: (BuildContext context, StateSetter setState) {
            String password = passwordC.text;
            passwordC.addListener(() {
              if (passwordC.text != password) {
                setState(() => password = passwordC.text);
              }
            });

            return Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: appColor3,
                    ),
                    SizedBox(width: 4),
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
                    SizedBox(width: 4),
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
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    icon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: Get.context!,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => GeneratorSheet(
                            onGenerated: (pass) => setState(() => passwordC.text = pass),
                          ),
                        );
                      },
                      icon: const Icon(Icons.tune),
                      tooltip: 'Password generator',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final strength = PasswordStrengthUtil.evaluate(password);
                  final score = PasswordStrengthUtil.score(password);
                  return Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: score,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                PasswordStrengthUtil.color(strength),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              PasswordStrengthUtil.label(strength),
                              style: TextStyle(
                                fontSize: 12,
                                color: PasswordStrengthUtil.color(strength),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlC,
                  maxLength: 256,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    counterText: '',
                    labelText: 'URL (optional)',
                    icon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesC,
                  maxLength: 500,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    counterText: '',
                    labelText: 'Notes (optional)',
                    icon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: totpC,
                  maxLength: 128,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'TOTP Secret (optional)',
                    icon: const Icon(Icons.lock_clock),
                    border: const OutlineInputBorder(),
                    helperText: 'Base32 secret from your 2FA setup',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () async {
                        final result = await Get.to<String>(() => const QrScanPage());
                        if (result != null && result.isNotEmpty) {
                          setState(() => totpC.text = _parseTotpSecret(result));
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
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

            // Check for duplicate password
            final allEntries = HomeController.to.passesList;
            final isDuplicate = allEntries.any((e) =>
              e.password == passwordC.text &&
              (model == null || e.key != model.key)
            );
            if (isDuplicate) {
              final confirmed = await Get.defaultDialog<bool>(
                title: 'Duplicate Password',
                content: const Text('This password is already used by another entry. Using the same password for multiple accounts is a security risk. Continue anyway?'),
                textConfirm: 'Use Anyway',
                textCancel: 'Change It',
                confirmTextColor: Colors.white,
                buttonColor: Colors.orange,
                onConfirm: () => Get.back(result: true),
                onCancel: () => Get.back(result: false),
              );
              if (confirmed != true) return;
            }

            if (model == null) {
              final passwordModel = PasswordModel(
                title: titleC.text,
                password: passwordC.text,
                username: usernameC.text,
                imageName: imageName,
                url: urlC.text.trim().isEmpty ? null : urlC.text.trim(),
                notes: notesC.text.trim().isEmpty ? null : notesC.text.trim(),
                totpSecret: totpC.text.trim().isEmpty ? null : totpC.text.trim().toUpperCase(),
              );
              await HomeController.to.addPassword(passwordModel);
            } else {
              model
                ..title = titleC.text
                ..password = passwordC.text
                ..username = usernameC.text
                ..imageName = imageName
                ..url = urlC.text.trim().isEmpty ? null : urlC.text.trim()
                ..notes = notesC.text.trim().isEmpty ? null : notesC.text.trim()
                ..totpSecret = totpC.text.trim().isEmpty ? null : totpC.text.trim().toUpperCase();

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

  final hibpEnabled = appSH.getBool('hibp_enabled') ?? false;

  await Get.bottomSheet(
    SingleChildScrollView(
      child: Column(
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
          ListTile(
            title: const Text('Breach Alert'),
            subtitle: Text(hibpEnabled
                ? 'Passwords are checked against breach databases on copy.'
                : 'Enable to check passwords against known breaches (requires internet).'),
            leading: const Icon(Icons.security, color: appColor3),
            trailing: Switch(
              value: hibpEnabled,
              onChanged: (v) async {
                await appSH.setBool('hibp_enabled', v);
                appPopDialog();
                settings();
              },
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('Backup'),
            subtitle: Text('Device-locked backup'),
            leading: Icon(Icons.backup_outlined, color: appColor3),
            onTap: backup,
          ),
          const Divider(),
          ListTile(
            title: const Text('Export (Portable)'),
            subtitle: const Text('Password-protected, any device'),
            leading: const Icon(Icons.lock_open, color: appColor3),
            onTap: () {
              appPopDialog();
              exportPortable();
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Restore'),
            subtitle: Text('Restore device-locked backup'),
            leading: Icon(Icons.restore, color: appColor3),
            onTap: restore,
          ),
          const Divider(),
          ListTile(
            title: const Text('Restore (Portable)'),
            subtitle: const Text('Restore from .pbbx backup'),
            leading: const Icon(Icons.restore_page, color: appColor3),
            onTap: () {
              appPopDialog();
              restorePortable();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Import from CSV'),
            leading: const Icon(Icons.table_chart_outlined, color: appColor3),
            onTap: () {
              appPopDialog();
              importCsv();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Import via QR'),
            leading: const Icon(Icons.qr_code_scanner, color: appColor3),
            onTap: () {
              appPopDialog();
              Get.toNamed(QrImportPage.name);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Recycle Bin'),
            leading: const Icon(Icons.delete_outline, color: appColor3),
            onTap: () {
              appPopDialog();
              Get.toNamed(RecycleBinPage.name);
            },
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
          const SizedBox(height: 8),
        ],
      ),
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

String _parseTotpSecret(String input) {
  if (input.startsWith('otpauth://')) {
    try {
      return OTPUri.extractSecret(input);
    } catch (_) {
      return input;
    }
  }
  return input.trim().replaceAll(' ', '').toUpperCase();
}
