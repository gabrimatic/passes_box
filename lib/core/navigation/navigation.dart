import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void appPopDialog() => Navigator.of(
      Get.context!,
      rootNavigator: true,
    ).pop();

void appExit() => SystemChannels.platform.invokeMethod('SystemNavigator.pop');
