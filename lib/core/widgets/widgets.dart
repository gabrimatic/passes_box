import 'package:flutter/foundation.dart';

import '../index.dart';

class CenterTheWidget extends StatelessWidget {
  final Widget child;
  final Color color;

  const CenterTheWidget({
    Key? key,
    required this.child,
    this.color = const Color(0xfff8f8f8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => kIsWeb
      ? Container(
          decoration: const BoxDecoration(
              // image: DecorationImage(
              //   fit: BoxFit.cover,
              //   image: AssetImage('assets/images/main_back.jpg'),
              // ),
              ),
          alignment: Alignment.center,
          width: Get.width,
          child: SizedBox(
            width: appGetWidth,
            child: child,
          ),
        )
      : Container(child: child);
}

void appShowSnackbar({required String message}) => Get.showSnackbar(
      GetBar(
        message: message.tr,
        borderRadius: 8,
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        duration: const Duration(seconds: 3),
        backgroundGradient: const LinearGradient(
          colors: [
            appColor3,
            appColor2,
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        overlayColor: Colors.white,
      ),
    );
