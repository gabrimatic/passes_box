import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Future appPush(
//   Widget screen,
//   BuildContext context,
// ) =>
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => screen,
//       ),
//     );

// void appPop(BuildContext context, {dynamic data}) =>
//     Navigator.pop(context, data);

void appPopDialog() => Navigator.of(
      Get.context!,
      rootNavigator: true,
    ).pop();

// void appPopUntil(BuildContext context) => Navigator.of(context).popUntil(
//       (route) => route.isFirst,
//     );

// void appPopAllAndPush(
//   Widget screen,
//   BuildContext context,
// ) =>
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (BuildContext context) => screen),
//       (Route<dynamic> route) => true,
//     );

void appExit() => SystemChannels.platform.invokeMethod('SystemNavigator.pop');
