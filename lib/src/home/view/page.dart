import '../../../core/index.dart';
import '../controller/controller.dart';
import '../dialogs/dialogs.dart';
import '../widgets/password_card.dart';
import '../widgets/search_sort_bar.dart';

class HomePage extends StatelessWidget {
  static const name = '/index.html';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          final controller = HomeController.to;
          final list = controller.filteredList;

          if (list.isNotEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SearchSortBar(),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: list
                        .map(
                          (model) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 1,
                              horizontal: 4,
                            ),
                            child: PasswordCard(model: model),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          } else if (controller.passesList.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 84,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      color: Colors.black12,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Passes Box',
                    style: TextStyle(
                      color: Colors.black12,
                      fontSize: 28,
                    ),
                  ),
                ),
                const Spacer(),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ADD YOUR FIRST PASSWORD!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                    SizedBox(height: kToolbarHeight),
                  ],
                ),
              ],
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.black12),
                  SizedBox(height: 16),
                  Text(
                    'No matches found',
                    style: TextStyle(color: Colors.black38, fontSize: 18),
                  ),
                ],
              ),
            );
          }
        }),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: const Text(
            'Add password',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => passwordDialog(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                color: appColor3,
                onPressed: settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
