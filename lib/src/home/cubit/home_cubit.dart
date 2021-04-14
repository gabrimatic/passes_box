import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/models/password.dart';
import '../../../repository/db.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadAll() async {
    final res = await PassesDB.selectAll();
    emit(
      HomeLoaded(res),
    );
  }

  void addAll(List<PasswordModel> list) {
    emit(
      HomeLoaded(list),
    );
  }

  Future<void> addPassword(PasswordModel model) async {
    final res = await PassesDB.insert(model);
    if (res < 1) return;
    emit(
      HomeLoaded(
        (state as HomeLoaded).passesList
          ..add(
            model..id = res,
          ),
      ),
    );
  }

  Future<void> removePassword(int id) async {
    final res = await PassesDB.delete(id);
    if (res < 0) return;
    emit(
      HomeLoaded(
        (state as HomeLoaded).passesList
          ..removeWhere(
            (element) => element.id == id,
          ),
      ),
    );
  }

  Future<void> updatePassword(PasswordModel model) async {
    final res = await PassesDB.update(model);
    if (res < 1) return;

    final list = (state as HomeLoaded).passesList;
    emit(
      HomeLoaded(
        list
          ..[list.indexWhere(
            (element) => element.id == model.id,
          )] = model,
      ),
    );
  }
}
