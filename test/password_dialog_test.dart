import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:passes_box/core/models/password.dart';
import 'package:passes_box/src/home/controller/controller.dart';
import 'package:passes_box/src/home/dialogs/dialogs.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('editing a password sends the old password to history tracking',
      (tester) async {
    final controller = _FakeHomeController();
    Get.put<HomeController>(controller);

    final model = PasswordModel(
      key: 1,
      title: 'Example',
      username: 'soroush',
      password: 'old-secret',
      imageName: 'social',
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => passwordDialog(model: model),
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(2), 'new-secret');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(controller.oldPassword, 'old-secret');
    expect(controller.updatedModel?.password, 'new-secret');
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('adding a password closes the sheet after the saved snackbar',
      (tester) async {
    final controller = _FakeHomeController();
    Get.put<HomeController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: passwordDialog,
              child: const Text('Add'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Example');
    await tester.enterText(find.byType(TextFormField).at(2), 'S0lid!Secret');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(controller.addedModel?.title, 'Example');
    expect(controller.addedModel?.password, 'S0lid!Secret');
    expect(find.text('Save'), findsNothing);
  });
}

class _FakeHomeController extends HomeController {
  String? oldPassword;
  PasswordModel? addedModel;
  PasswordModel? updatedModel;

  @override
  // The fake controller deliberately skips database-backed startup work.
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> addPassword(PasswordModel model) async {
    addedModel = model;
  }

  @override
  Future<void> updatePassword(PasswordModel model,
      {String? oldPassword}) async {
    this.oldPassword = oldPassword;
    updatedModel = model;
  }
}
