import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/values/colors.dart';
import '../cubit/home_cubit.dart';
import '../dialogs/dialogs.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoaded && state.passesList.isNotEmpty) {
                return StaggeredGridView.countBuilder(
                  padding: const EdgeInsets.all(6),
                  crossAxisCount: 4,
                  itemCount: state.passesList.length,
                  itemBuilder: (BuildContext context, int index) => Card(
                    shape: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(32),
                      ),
                      borderSide:
                          BorderSide(width: 0.1, color: Colors.blueGrey),
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
                              'assets/images/${state.passesList[index].imageName!}.png',
                              width: 32,
                              height: 32,
                            ),
                            title: Text(
                              state.passesList[index].title!,
                            ),
                            subtitle: Text(
                              state.passesList[index].username!,
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => passwordDialog(
                                  model: state.passesList[index],
                                ),
                                color: appColor3,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: appColor3,
                                onPressed: () => deleteDialog(
                                  state.passesList[index],
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
                                          ? state.passesList[index].password
                                          : state.passesList[index].username,
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
                  staggeredTileBuilder: (int index) => const StaggeredTile.fit(
                    2,
                  ),
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                );
              } else {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 2),
                    opacity: _btnOpacity,
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: const [
                IconButton(
                  icon: Icon(Icons.settings),
                  color: appColor3,
                  onPressed: settings,
                ),
                // const Spacer(),
                // IconButton(
                //   icon: const Icon(Icons.search),
                //   color: appColor3,
                //   onPressed: _search,
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

  /// @CODES
  double _btnOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _showHint();
  }

  void _showHint() => Timer.periodic(
        const Duration(seconds: 2),
        (timer) => (_btnOpacity == 1.0)
            ? setState(() => _btnOpacity = 0.1)
            : setState(
                () => _btnOpacity = 1.0,
              ),
      );
}
