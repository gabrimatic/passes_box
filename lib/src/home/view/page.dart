import '../../../core/index.dart';
import '../controller/controller.dart';
import '../dialogs/dialogs.dart';
import '../widgets/password_card.dart';
import '../widgets/search_sort_bar.dart';
import '../widgets/vault_health_summary.dart';

class HomePage extends StatelessWidget {
  static const name = '/index.html';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appBackground,
        body: Obx(() {
          final controller = HomeController.to;
          final list = controller.filteredList;

          if (list.isNotEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child:
                          _HomeHeader(totalCount: controller.passesList.length),
                    ),
                    const SliverToBoxAdapter(child: SearchSortBar()),
                    SliverToBoxAdapter(
                      child: VaultHealthSummary(issues: controller.auditIssues),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                      sliver: SliverList.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) =>
                            PasswordCard(model: list[index]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (controller.passesList.isEmpty) {
            return Center(
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
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: appSurfaceMuted,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: appBorder),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: appColor2,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Your vault is empty',
                            style: TextStyle(
                              color: appTextPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add the first credential, import a CSV, or restore an encrypted backup from settings.',
                            style: TextStyle(
                              color: appTextSecondary,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add password'),
                            onPressed: () => passwordDialog(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: appBorder),
                  SizedBox(height: 16),
                  Text(
                    'No matches found',
                    style: TextStyle(color: appTextSecondary, fontSize: 18),
                  ),
                ],
              ),
            );
          }
        }),
        floatingActionButton: Obx(
          () => HomeController.to.passesList.isEmpty
              ? const SizedBox.shrink()
              : FloatingActionButton.extended(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Add password',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => passwordDialog(),
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                color: appColor3,
                onPressed: settings,
              ),
              const SizedBox(width: 8),
              const Text(
                'PassesBox',
                style: TextStyle(
                  color: appTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final int totalCount;

  const _HomeHeader({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: appSurfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: appBorder),
            ),
            child: const Icon(Icons.lock_outline_rounded, color: appColor2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PassesBox',
                  style: TextStyle(
                    color: appTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$totalCount saved ${totalCount == 1 ? 'entry' : 'entries'}',
                  style: const TextStyle(color: appTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
