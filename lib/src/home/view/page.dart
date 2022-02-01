import 'package:flutter/services.dart';

import '../../../core/index.dart';
import '../controller/home_controller.dart';
import '../dialogs/dialogs.dart';

class HomePage extends StatelessWidget {
  static const name = '/home';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GetX<HomeController>(
          builder: (controller) {
            if (controller.passesList.isNotEmpty) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.of(context).orientation ==
                          Orientation.portrait)
                      ? 2
                      : 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                padding: const EdgeInsets.all(6),
                itemCount: controller.passesList.length,
                itemBuilder: (BuildContext context, int index) => Card(
                  shape: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(32),
                    ),
                    borderSide: BorderSide(width: 0.1, color: Colors.blueGrey),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 8,
                      right: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          trailing: Image.asset(
                            'assets/images/${controller.passesList[index].imageName!}.png',
                            width: 32,
                            height: 32,
                          ),
                          title: Text(
                            controller.passesList[index].title!,
                          ),
                          subtitle: Text(
                            controller.passesList[index].username!,
                          ),
                        ),
                        const Divider(),
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
                            const Spacer(),
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
                                        ? controller.passesList[index].password
                                        : controller.passesList[index].username,
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: 1, //_btnOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'ADD YOUR FIRST PASSWORD!',
                        style: TextStyle(
                          fontSize: 16,
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
                ),
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
            children: const [
              IconButton(
                icon: Icon(Icons.settings),
                color: appColor3,
                onPressed: settings,
              ),
              // const Spacer(),

              // BlocBuilder<HomeCubit, HomeState>(
              //   builder: (context, state) {
              //     if (state is HomeLoaded && state.passesList.isNotEmpty) {
              //       return IconButton(
              //         icon: const Icon(Icons.search),
              //         color: appColor3,
              //         onPressed: () => Get.to(
              //           BlocProvider.value(
              //             value: context.read<HomeCubit>(),
              //             child: const SearchPage(),
              //           ),
              //         ),
              //       );
              //     } else {
              //       return const SizedBox.shrink();
              //     }
              //   },
              // ),
              // IconButton(
              //   icon: const Icon(Icons.filter_list_rounded),
              //   color: appColor3,
              //   onPressed: _filter,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
