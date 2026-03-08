import 'dart:async';
import 'package:get/get.dart';

class LockService extends GetxService {
  static LockService get to => Get.find<LockService>();

  final isLocked = false.obs;
  Timer? _lockTimer;

  static const _lockTimeout = Duration(minutes: 5);

  void resetTimer() {
    if (isLocked.value) return;
    _lockTimer?.cancel();
    _lockTimer = Timer(_lockTimeout, () {
      isLocked.value = true;
    });
  }

  void lock() {
    _lockTimer?.cancel();
    isLocked.value = true;
  }

  void unlock() {
    isLocked.value = false;
    resetTimer();
  }

  @override
  void onClose() {
    _lockTimer?.cancel();
    super.onClose();
  }
}
