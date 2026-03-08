import 'package:flutter/services.dart';

import '../../../core/index.dart';
import '../controller/controller.dart';
import '../dialogs/dialogs.dart';

class HomePage extends StatelessWidget {
  static const name = '/index.html';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GetX<HomeController>(
          builder: (controller) {
            if (controller.passesList.isNotEmpty) {
              return SingleChildScrollView(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: List.generate(
                    controller.passesList.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 1,
                        horizontal: 4,
                      ),
                      child: Card(
                        shape: OutlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(32),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 8,
                            right: 16,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller.passesList[index].title ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        controller.passesList[index].username ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Image.asset(
                                    'assets/images/${controller.passesList[index].imageName ?? 'social'}.png',
                                    width: 32,
                                    height: 32,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => passwordDialog(
                                      model: controller.passesList[index],
                                    ),
                                    color: appColor3,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: appColor3,
                                    onPressed: () => deleteDialog(
                                      controller.passesList[index],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: appColor3,
                                    ),
                                    itemBuilder: (context) {
                                      return <PopupMenuEntry>[
                                        const PopupMenuItem<String>(
                                          value: 'username',
                                          child: Text(
                                            'Copy Username',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: appColor3,
                                            ),
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'pass',
                                          child: Text(
                                            'Copy Password',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: appColor3,
                                            ),
                                          ),
                                        ),
                                      ];
                                    },
                                    onSelected: (value) {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: value == 'pass'
                                              ? controller
                                                      .passesList[index].password ??
                                                  ''
                                              : controller
                                                      .passesList[index].username ??
                                                  '',
                                        ),
                                      );
                                      appShowSnackbar(
                                        message: '${value == 'pass' ? 'Password' : 'Username'} copied to clipboard.',
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
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
                      SizedBox(
                        height: kToolbarHeight,
                      )
                    ],
                  ),
                ],
              );
            }
          },
        ),
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
