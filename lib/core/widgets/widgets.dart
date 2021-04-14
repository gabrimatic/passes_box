import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passes_box/core/values/colors.dart';

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
