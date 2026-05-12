import 'package:flutter/foundation.dart';

import '../index.dart';

class CenterTheWidget extends StatelessWidget {
  final Widget child;
  final Color color;

  const CenterTheWidget({
    super.key,
    required this.child,
    this.color = appBackground,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final width = MediaQuery.sizeOf(context).width;
    return Container(
      alignment: Alignment.center,
      width: width,
      color: color,
      child: SizedBox(
        width: width > 900 ? 900 : width,
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
          color: appColor2,
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: appSurface,
        borderColor: appBorder,
        borderWidth: 1,
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      ),
    );
