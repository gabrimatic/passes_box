import 'package:url_launcher/url_launcher.dart';

import '../../../core/index.dart';

class AboutPage extends StatelessWidget {
  static const name = '/about';

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
                  icon: const Icon(Icons.close),
                  onPressed: Get.back,
                ),
              ),
              Image.asset(
                'assets/images/logo.png',
                width: Get.width / 2,
              ),
              const SizedBox(height: 16),
              const Text(
                appName,
                style: TextStyle(color: appColor2, fontSize: 24),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  appAbout,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                title: const Text('By Hossein Yousefpour'),
                subtitle: const Text('version $appVersion'),
                trailing: IconButton(
                  icon: const Icon(Icons.public),
                  color: appColor2,
                  onPressed: () => launch('https://gabrimatic.info'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
