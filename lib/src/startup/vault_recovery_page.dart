import '../../core/index.dart';
import '../home/view/page.dart';

class VaultRecoveryPage extends StatefulWidget {
  final VaultOpenException issue;

  const VaultRecoveryPage({
    super.key,
    required this.issue,
  });

  @override
  State<VaultRecoveryPage> createState() => _VaultRecoveryPageState();
}

class _VaultRecoveryPageState extends State<VaultRecoveryPage> {
  var _isResetting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: appBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock_reset_rounded,
                        color: appDanger,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vault needs recovery',
                        style: TextStyle(
                          color: appTextPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This local vault was created with an older encryption format. PassesBox cannot open it safely in this version.',
                        style: TextStyle(
                          color: appTextSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Keep an older app copy if you still need to export that vault. Reset this device only when you are ready to start fresh or import a backup.',
                        style: TextStyle(
                          color: appTextSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: _isResetting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.delete_outline_rounded),
                          label: const Text('Reset local vault'),
                          style: FilledButton.styleFrom(
                            backgroundColor: appDanger,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isResetting ? null : _confirmReset,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Reset local vault?',
      content: const Text(
        'This deletes the encrypted vault stored on this device. Backups and vaults on other devices are not touched.',
      ),
      textConfirm: 'Reset',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: appDanger,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed != true) return;

    setState(() => _isResetting = true);
    try {
      await resetLocalVaultStorage();
      await appOpenDatabase();
      Get.offAllNamed(HomePage.name);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isResetting = false);
      appShowSnackbar(message: 'Vault reset failed. Try again.');
    }
  }
}
