import 'package:url_launcher/url_launcher.dart';

import '../../../core/index.dart';

class AboutPage extends StatelessWidget {
  static const name = '/about.index';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                width: 220,
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
                  onPressed: () => launchUrl(Uri.parse('https://gabrimatic.info')),
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
