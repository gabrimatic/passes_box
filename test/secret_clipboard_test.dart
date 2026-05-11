import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:passes_box/core/models/password.dart';
import 'package:passes_box/core/services/clipboard_service.dart';
import 'package:passes_box/core/values/strings.dart';
import 'package:passes_box/src/home/dialogs/history_dialog.dart';
import 'package:passes_box/src/home/widgets/password_card.dart';
import 'package:passes_box/src/home/widgets/totp_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? clipboardText;

  setUp(() {
    Get.testMode = true;
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          final arguments = call.arguments as Map<dynamic, dynamic>;
          clipboardText = arguments['text'] as String?;
          return null;
        case 'Clipboard.getData':
          return <String, dynamic>{'text': clipboardText};
        case 'Clipboard.hasStrings':
          return <String, dynamic>{
            'value': clipboardText != null && clipboardText!.isNotEmpty,
          };
        default:
          return null;
      }
    });
  });

  tearDown(() {
    ClipboardService.cancelAutoClear();
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('app version matches the current release', () {
    expect(appVersion, '2.2.0');
  });

  testWidgets('password card copy clears the clipboard after the timeout',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: PasswordCard(
            model: PasswordModel(
              key: 1,
              title: 'Example',
              username: 'soroush',
              password: 'secret-password',
              imageName: 'social',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy Password'));
    await tester.pump();

    expect(clipboardText, 'secret-password');

    await tester.pump(const Duration(seconds: 31));

    expect(clipboardText, '');
  });

  testWidgets('password history copy clears the clipboard after the timeout',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showHistoryDialog(
                PasswordModel(
                  title: 'Example',
                  passwordHistory: ['old-secret'],
                ),
              ),
              child: const Text('Show history'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show history'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();

    expect(clipboardText, 'old-secret');

    await tester.pump(const Duration(seconds: 31));

    expect(clipboardText, '');
  });

  testWidgets('totp copy clears the clipboard after the timeout',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TotpWidget(secret: 'JBSWY3DPEHPK3PXP'),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byType(TotpWidget));
    await tester.pump();

    expect(clipboardText, matches(RegExp(r'^\d{6}$')));

    await tester.pump(const Duration(seconds: 31));

    expect(clipboardText, '');
  });
}
