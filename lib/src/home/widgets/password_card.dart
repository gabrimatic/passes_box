import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/index.dart';
import '../../../core/models/password.dart';
import '../../qr/qr_export_dialog.dart';
import '../controller/io.dart';
import '../dialogs/dialogs.dart';
import '../dialogs/history_dialog.dart';
import 'totp_widget.dart';

class PasswordCard extends StatelessWidget {
  final PasswordModel model;

  const PasswordCard({super.key, required this.model});

  Color? get _ageColor {
    final changedAt = model.updatedAt ?? model.createdAt;
    if (changedAt == null) return null;
    final age = DateTime.now().difference(changedAt).inDays;
    if (age > 180) return appDanger;
    if (age > 90) return appWarning;
    return null;
  }

  IconData? get _ageIcon {
    if (_ageColor == null) return null;
    return _ageColor == appDanger
        ? Icons.warning_rounded
        : Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: appSurfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/${model.imageName ?? 'social'}.png',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              model.title?.trim().isEmpty ?? true
                                  ? 'Untitled'
                                  : model.title!,
                              style: const TextStyle(
                                color: appTextPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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
                          fontSize: 13,
                          color: appTextSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (model.totpSecret != null && model.totpSecret!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TotpWidget(secret: model.totpSecret!),
              ),
            if (model.url != null && model.url!.isNotEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final normalizedUrl =
                      CredentialPolicy.normalizeUrl(model.url);
                  if (normalizedUrl != null) {
                    launchUrl(
                      Uri.parse(normalizedUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    appShowSnackbar(message: 'This URL is not valid.');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link, size: 14, color: appColor2),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          model.url!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: appColor2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => passwordDialog(model: model),
                  color: appColor3,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete',
                  color: appColor3,
                  onPressed: () => deleteDialog(model),
                ),
                if (model.passwordHistory != null &&
                    model.passwordHistory!.isNotEmpty)
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
                      child: Text('Copy Username'),
                    ),
                    PopupMenuItem<String>(
                      value: 'pass',
                      child: Text('Copy Password'),
                    ),
                    PopupMenuItem<String>(
                      value: 'qr_export',
                      child: Text('Export as QR'),
                    ),
                  ],
                  onSelected: (value) async {
                    HapticFeedback.lightImpact();
                    if (value == 'qr_export') {
                      await showQrExportDialog(model);
                      return;
                    }

                    final isPassword = value == 'pass';
                    await ClipboardService.copyWithAutoClear(
                      isPassword
                          ? (model.password ?? '')
                          : (model.username ?? ''),
                    );
                    appShowSnackbar(
                      message:
                          '${isPassword ? 'Password' : 'Username'} copied to clipboard.',
                    );
                    if (isPassword &&
                        (model.password?.isNotEmpty ?? false) &&
                        appSettingBool('hibp_enabled')) {
                      unawaited(checkHibp(model.password!).then((count) {
                        if (count > 0) {
                          appShowSnackbar(
                            message:
                                'This password appeared in $count data breaches. Consider changing it.',
                          );
                        }
                      }));
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
