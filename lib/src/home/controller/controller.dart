import '../../../core/index.dart';
import '../../../core/models/password.dart';

class HomeController extends GetxController {
  final passesList = <PasswordModel>[].obs;
  HomeController();

  static final to = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    passesList.value = PassesDB.selectAll();
  }

  // void addAll(List<PasswordModel> list) {
  //   passesList.clear();
  //   passesList.addAll(list);
  // }

  void addPassword(PasswordModel model) {
    PassesDB.insert(model);

    passesList.add(model);
  }

  void removePassword(PasswordModel passwordModel) {
    passwordModel.delete();

    passesList.removeWhere(
      (element) => element == passwordModel,
    );
  }

  void updatePassword(PasswordModel model) {
    PassesDB.update(model);

    passesList[passesList.indexWhere(
      (element) => element == model,
    )] = model;
  }
}
