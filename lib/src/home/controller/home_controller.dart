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

  Future<void> loadAll() async {
    passesList.value = await PassesDB.selectAll();
  }

  void addAll(List<PasswordModel> list) {
    passesList.clear();
    passesList.addAll(list);
  }

  Future<void> addPassword(PasswordModel model) async {
    final res = await PassesDB.insert(model);
    if (res < 1) return;

    passesList.add(model..id = res);
  }

  Future<void> removePassword(int id) async {
    final res = await PassesDB.delete(id);
    if (res < 0) return;
    passesList.removeWhere(
      (element) => element.id == id,
    );
  }

  Future<void> updatePassword(PasswordModel model) async {
    final res = await PassesDB.update(model);
    if (res < 1) return;

    passesList[passesList.indexWhere(
      (element) => element.id == model.id,
    )] = model;
  }
}
