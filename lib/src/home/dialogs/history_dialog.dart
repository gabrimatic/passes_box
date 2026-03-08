import 'package:flutter/services.dart';

import '../../../core/index.dart';
import '../../../core/models/password.dart';

Future<void> showHistoryDialog(PasswordModel model) async {
  final history = model.passwordHistory ?? [];

  await Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: appColor3),
              const SizedBox(width: 8),
              const Text(
                'Password History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: appPopDialog),
            ],
          ),
          const Divider(),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No previous passwords recorded.',
                style: TextStyle(color: Colors.black38),
              ),
            )
          else
            ...history.asMap().entries.map((entry) {
              final index = entry.key;
              final pass = entry.value;
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: appColor3.withValues(alpha: 0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 12, color: appColor3),
                  ),
                ),
                title: Text(
                  '\u2022' * pass.length,
                  style: const TextStyle(letterSpacing: 2, color: Colors.black54),
                ),
                subtitle: Text(
                  index == 0 ? 'Most recent' : '${index + 1} changes ago',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: appColor3),
                  tooltip: 'Copy',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: pass));
                    appShowSnackbar(message: 'Old password copied.');
                  },
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
    ),
  );
}
