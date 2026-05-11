import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void appPopDialog() {
  if ((Get.isDialogOpen ?? false) || (Get.isBottomSheetOpen ?? false)) {
    Get.back();
    return;
  }

  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
    return;
  }

  Navigator.of(
    Get.context!,
    rootNavigator: true,
  ).maybePop();
}

void appExit() => SystemChannels.platform.invokeMethod('SystemNavigator.pop');
