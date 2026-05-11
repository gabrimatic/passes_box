import '../../../core/index.dart';
import '../dialogs/dialogs.dart';

class VaultHealthSummary extends StatelessWidget {
  final List<CredentialIssue> issues;

  const VaultHealthSummary({
    super.key,
    required this.issues,
  });

  int _count(CredentialIssueType type) {
    return issues.where((issue) => issue.type == type).length;
  }

  @override
  Widget build(BuildContext context) {
    final dangerCount = issues
        .where((issue) => issue.severity == CredentialIssueSeverity.danger)
        .length;
    final warningCount = issues.length - dangerCount;
    final healthTitle = issues.isEmpty
        ? 'Vault health looks good'
        : dangerCount > 0
            ? '$dangerCount high-risk issue${dangerCount == 1 ? '' : 's'} need attention'
            : '$warningCount warning${warningCount == 1 ? '' : 's'} need attention';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Material(
        color: issues.isEmpty ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: issues.isEmpty ? null : () => _showIssues(context, issues),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      issues.isEmpty
                          ? Icons.verified_user_outlined
                          : Icons.health_and_safety_outlined,
                      color: issues.isEmpty ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        healthTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (issues.isNotEmpty)
                      const Icon(Icons.chevron_right, color: appColor3),
                  ],
                ),
                if (issues.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _IssueChip(
                        label: 'Weak',
                        count: _count(CredentialIssueType.weakPassword),
                      ),
                      _IssueChip(
                        label: 'Reused',
                        count: _count(CredentialIssueType.reusedPassword),
                      ),
                      _IssueChip(
                        label: 'Old',
                        count: _count(CredentialIssueType.oldPassword),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIssues(BuildContext context, List<CredentialIssue> issues) {
    Get.bottomSheet(
      SafeArea(
        child: Material(
          color: Colors.white,
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: issues.length + 1,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Row(
                  children: [
                    const Icon(Icons.health_and_safety_outlined,
                        color: appColor3),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Vault Health',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: Get.back,
                    ),
                  ],
                );
              }

              final issue = issues[index - 1];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  issue.severity == CredentialIssueSeverity.danger
                      ? Icons.warning_rounded
                      : Icons.schedule_rounded,
                  color: issue.severity == CredentialIssueSeverity.danger
                      ? Colors.red
                      : Colors.orange,
                ),
                title: Text(issue.title),
                subtitle: Text(issue.detail),
                trailing: TextButton(
                  onPressed: () {
                    Get.back();
                    passwordDialog(model: issue.model);
                  },
                  child: const Text('Fix'),
                ),
              );
            },
          ),
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
}

class _IssueChip extends StatelessWidget {
  final String label;
  final int count;

  const _IssueChip({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label $count'),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
