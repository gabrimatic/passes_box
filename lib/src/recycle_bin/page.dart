import '../../core/index.dart';
import '../../core/models/password.dart';
import '../home/controller/controller.dart';

class RecycleBinPage extends StatefulWidget {
  static const name = '/recycle-bin';

  const RecycleBinPage({super.key});

  @override
  State<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends State<RecycleBinPage> {
  List<PasswordModel> _deleted = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await PassesDB.purgeExpiredDeleted();
    final list = await PassesDB.selectDeleted();
    if (mounted) {
      setState(() {
        _deleted = list;
        _loading = false;
      });
    }
  }

  Future<void> _restore(PasswordModel model) async {
    await PassesDB.restore(model);
    setState(() => _deleted.removeWhere((e) => e.key == model.key));
    try {
      HomeController.to.loadAll();
    } catch (_) {}
    appShowSnackbar(message: '"${model.title}" restored.');
  }

  Future<void> _permanentDelete(PasswordModel model) async {
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Delete Permanently',
      content: Text('Permanently delete "${model.title}"? This cannot be undone.'),
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed == true) {
      await PassesDB.permanentDelete(model);
      setState(() => _deleted.removeWhere((e) => e.key == model.key));
    }
  }

  String _deletedAgo(PasswordModel model) {
    if (model.deletedAt == null) return 'recently';
    final days = DateTime.now().difference(model.deletedAt!).inDays;
    if (days == 0) return 'today';
    if (days == 1) return '1 day ago';
    return '$days days ago';
  }

  String _expiresIn(PasswordModel model) {
    if (model.deletedAt == null) return '';
    final expiresAt = model.deletedAt!.add(const Duration(days: 30));
    final daysLeft = expiresAt.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return 'expires soon';
    if (daysLeft == 1) return 'expires in 1 day';
    return 'expires in $daysLeft days';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Bin'),
        actions: [
          if (_deleted.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await Get.defaultDialog<bool>(
                  title: 'Empty Recycle Bin',
                  content: const Text('Permanently delete all items in the recycle bin?'),
                  textConfirm: 'Delete All',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () => Get.back(result: true),
                  onCancel: () => Get.back(result: false),
                );
                if (confirmed == true) {
                  for (final m in List.of(_deleted)) {
                    await PassesDB.permanentDelete(m);
                  }
                  setState(() => _deleted.clear());
                }
              },
              child: const Text('Empty', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _deleted.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 64, color: Colors.black12),
                      SizedBox(height: 16),
                      Text(
                        'Recycle bin is empty',
                        style: TextStyle(color: Colors.black38, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Deleted items are kept for 30 days',
                        style: TextStyle(color: Colors.black26, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: _deleted.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final model = _deleted[index];
                    return ListTile(
                      leading: Image.asset(
                        'assets/images/${model.imageName ?? 'social'}.png',
                        width: 36,
                        height: 36,
                      ),
                      title: Text(model.title ?? 'Untitled'),
                      subtitle: Text(
                        '${model.username ?? ''} \u2022 ${_deletedAgo(model)} \u2022 ${_expiresIn(model)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore, color: Colors.green),
                            tooltip: 'Restore',
                            onPressed: () => _restore(model),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            tooltip: 'Delete permanently',
                            onPressed: () => _permanentDelete(model),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
