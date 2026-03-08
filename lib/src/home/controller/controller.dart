import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/index.dart';
import '../../../core/models/password.dart';
import 'io.dart';

class HomeController extends GetxController {
  final passesList = <PasswordModel>[].obs;
  final searchQuery = ''.obs;
  final sortOption = 'newest'.obs;
  final categoryFilter = 'all'.obs;

  HomeController();

  List<PasswordModel> get filteredList {
    var list = passesList.toList();

    if (categoryFilter.value != 'all') {
      list =
          list.where((m) => m.imageName == categoryFilter.value).toList();
    }

    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((m) {
        return (m.title?.toLowerCase().contains(query) ?? false) ||
            (m.username?.toLowerCase().contains(query) ?? false) ||
            (m.url?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    switch (sortOption.value) {
      case 'az':
        list.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
      case 'za':
        list.sort((a, b) => (b.title ?? '').compareTo(a.title ?? ''));
      case 'oldest':
        list.sort((a, b) => (a.createdAt ?? DateTime(0))
            .compareTo(b.createdAt ?? DateTime(0)));
      case 'newest':
      default:
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
    }

    return list;
  }

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

    HapticFeedback.lightImpact();
    await ClipboardService.copyWithAutoClear(model.password ?? '');

    appShowSnackbar(message: 'Password has been copied to the clipboard.');

    if (!kIsWeb && (appSH.getBool('hibp_enabled') ?? false)) {
      checkHibp(model.password ?? '').then((count) {
        if (count > 0) {
          appShowSnackbar(
            message:
                'This password appeared in $count data breaches. Consider changing it.',
          );
        }
      });
    }
  }

  Future<void> removePassword(PasswordModel passwordModel) async {
    await PassesDB.softDelete(passwordModel);
    passesList.removeWhere(
      (element) => element == passwordModel,
    );
  }

  Future<void> updatePassword(PasswordModel model, {String? oldPassword}) async {
    await PassesDB.updateWithHistory(model, oldPassword: oldPassword);
    final index = passesList.indexWhere(
      (element) => element == model,
    );
    if (index != -1) {
      passesList[index] = model;
    }
  }
}
