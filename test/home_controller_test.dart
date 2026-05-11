import 'package:flutter_test/flutter_test.dart';
import 'package:passes_box/core/models/password.dart';
import 'package:passes_box/src/home/controller/controller.dart';

void main() {
  test('search includes notes', () {
    final controller = HomeController();
    controller.passesList.value = [
      PasswordModel(
        title: 'Server',
        username: 'root',
        password: 'secret',
        notes: 'SSH recovery key',
      ),
    ];

    controller.searchQuery.value = 'recovery';

    expect(controller.filteredList.single.title, 'Server');
  });
}
