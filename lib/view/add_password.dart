/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPasswordPage extends StatefulWidget {
  @override
  _AddPasswordPageState createState() => _AddPasswordPageState();
}

class _AddPasswordPageState extends State<AddPasswordPage> {

  @override
  void initState() {
*/
/*
    Provider.of<HomeController>(context, listen: false).loadGroups();
    provider = Provider.of<AddPasswordController>(context, listen: false);
*/ /*


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add new password')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              items: List.generate(78, (index) {
                return DropdownMenuItem(
                    value: 'value.listGroups[index]',
                    child: Text('value.listGroups[index]'));
              }),
              value: 'value.listGroups[0]',
              onChanged: (value) {},
            ),
            Row(
              children: [
                */
/*

                Expanded(
                  child: IconButton(
                    onPressed: () {
                      final titleController = TextEditingController();
                      Get.dialog(Container(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(labelText: 'Title'),
                            ),
                            SizedBox(height: 16),
                            FlatButton(
                              onPressed: () {
                                if (!titleController.text.isNullOrBlank)
                                  _groupBox.add(
                                      GroupModel(title: titleController.text));
                                Get.back(closeOverlays: true);
                              },
                              child: Text('Save'),
                            )
                          ],
                        ),
                      ));
                    },
                    icon: Icon(Icons.add),
                  ),
                )
*/ /*

              ],
            )
          ],
        ),
      ),
    );
  }
}
*/
