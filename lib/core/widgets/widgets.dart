import 'package:flutter/foundation.dart';

import '../index.dart';

class CenterTheWidget extends StatelessWidget {
  final Widget child;
  final Color color;

  const CenterTheWidget({
    super.key,
    required this.child,
    this.color = const Color(0xfff8f8f8),
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final width = MediaQuery.sizeOf(context).width;
    return Container(
      alignment: Alignment.center,
      width: width,
      child: SizedBox(
        width: width > 600 ? 600 : width,
        child: child,
      ),
    );
  }
}

void appShowSnackbar({required String message}) => Get.showSnackbar(
      GetSnackBar(
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
      ),
    );
