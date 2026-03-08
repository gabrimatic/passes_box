import 'package:flutter/services.dart';

import '../../../core/index.dart';
import '../../../core/models/password.dart';

class HomeController extends GetxController {
  final passesList = <PasswordModel>[].obs;
  HomeController();

  static HomeController get to => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    PassesDB.selectAll().then((list) {
      passesList.value = list;
    });
  }

  Future<void> addPassword(PasswordModel model) async {
    final key = await PassesDB.insert(model);
    model.key = key;
    passesList.add(model);

    Clipboard.setData(
      ClipboardData(text: model.password ?? ''),
    );

    appShowSnackbar(message: 'Password has been copied to the clipboard.');
  }

  Future<void> removePassword(PasswordModel passwordModel) async {
    await PassesDB.delete(passwordModel);
    passesList.removeWhere(
      (element) => element == passwordModel,
    );
  }

  Future<void> updatePassword(PasswordModel model) async {
    await PassesDB.update(model);
    final index = passesList.indexWhere(
      (element) => element == model,
    );
    if (index != -1) {
      passesList[index] = model;
    }
  }
}
