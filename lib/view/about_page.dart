import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passes_box/core/values/colors.dart';
import 'package:passes_box/core/values/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
/*
        bottomSheet: BottomSheet(
          elevation: 8,
          builder: (BuildContext context) => InkWell(
            onTap: () => launch('https://gabrimatic.info'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              width: Get.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'By Hossein Yousefpour | v $appVersion',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    'Tap to find more info.',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          onClosing: () {},
        ),
*/
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  )),
              Image.asset(
                'assets/images/icons/logo_trans.png',
                width: Get.width / 2,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                appName,
                style: TextStyle(color: appColor2, fontSize: 24),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  appAbout,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Divider(),
              ListTile(
                title: Text('By Hossein Yousefpour'),
                subtitle: Text('version $appVersion'),
                trailing: IconButton(
                  icon: Icon(Icons.public),
                  color: appColor2,
                  onPressed: () => launch('https://gabrimatic.info'),
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
