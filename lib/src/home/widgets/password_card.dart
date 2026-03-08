import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/index.dart';
import '../../../core/models/password.dart';
import '../../qr/qr_export_dialog.dart';
import '../dialogs/dialogs.dart';
import '../dialogs/history_dialog.dart';
import 'totp_widget.dart';

class PasswordCard extends StatelessWidget {
  final PasswordModel model;

  const PasswordCard({super.key, required this.model});

  Color? get _ageColor {
    if (model.createdAt == null) return null;
    final age = DateTime.now().difference(model.createdAt!).inDays;
    if (age > 180) return Colors.red;
    if (age > 90) return Colors.orange;
    return null;
  }

  IconData? get _ageIcon {
    if (_ageColor == null) return null;
    return _ageColor == Colors.red
        ? Icons.warning_rounded
        : Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: OutlineInputBorder(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(32)),
        borderSide:
            BorderSide(width: 1, color: Colors.grey.withValues(alpha: 0.4)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          model.title ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_ageIcon != null) ...[
                          const SizedBox(width: 4),
                          Icon(_ageIcon, color: _ageColor, size: 16),
                        ],
                      ],
                    ),
                    Text(
                      model.username ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Image.asset(
                  'assets/images/${model.imageName ?? 'social'}.png',
                  width: 32,
                  height: 32,
                ),
              ],
            ),
            if (model.totpSecret != null && model.totpSecret!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: TotpWidget(secret: model.totpSecret!),
              ),
            if (model.url != null && model.url!.isNotEmpty)
              InkWell(
                onTap: () {
                  final uri = Uri.tryParse(model.url!);
                  if (uri != null) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link, size: 14, color: appColor2),
                      const SizedBox(width: 4),
                      Text(
                        model.url!,
                        style: TextStyle(fontSize: 12, color: appColor2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => passwordDialog(model: model),
                  color: appColor3,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: appColor3,
                  onPressed: () => deleteDialog(model),
                ),
                if (model.passwordHistory != null && model.passwordHistory!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.history),
                    color: appColor3,
                    tooltip: 'Password history',
                    onPressed: () => showHistoryDialog(model),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: appColor3),
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'username',
                      child: Text(
                        'Copy Username',
                        style: TextStyle(fontSize: 15, color: appColor3),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'pass',
                      child: Text(
                        'Copy Password',
                        style: TextStyle(fontSize: 15, color: appColor3),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'qr_export',
                      child: Text(
                        'Export as QR',
                        style: TextStyle(fontSize: 15, color: appColor3),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    HapticFeedback.lightImpact();
                    switch (value) {
                      case 'qr_export':
                        showQrExportDialog(model);
                      default:
                        final text = value == 'pass'
                            ? (model.password ?? '')
                            : (model.username ?? '');
                        Clipboard.setData(ClipboardData(text: text));
                        appShowSnackbar(
                          message:
                              '${value == 'pass' ? 'Password' : 'Username'} copied to clipboard.',
                        );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
