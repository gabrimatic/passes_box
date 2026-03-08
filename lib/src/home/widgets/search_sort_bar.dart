import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';

class SearchSortBar extends StatelessWidget {
  const SearchSortBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.to;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search passwords…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => controller.searchQuery.value = '',
                      )
                    : const SizedBox.shrink(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (v) => controller.searchQuery.value = v,
          ),
        ),
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _SortChip(
                    label: 'Newest', value: 'newest', controller: controller),
                _SortChip(
                    label: 'Oldest', value: 'oldest', controller: controller),
                _SortChip(label: 'A–Z', value: 'az', controller: controller),
                _SortChip(label: 'Z–A', value: 'za', controller: controller),
                const SizedBox(width: 12),
                _CategoryChip(
                    label: 'All', value: 'all', controller: controller),
                _CategoryChip(
                    label: 'Bank', value: 'bank', controller: controller),
                _CategoryChip(
                    label: 'Card', value: 'card', controller: controller),
                _CategoryChip(
                    label: 'Email', value: 'email', controller: controller),
                _CategoryChip(
                    label: 'Social', value: 'social', controller: controller),
                _CategoryChip(
                    label: 'Web', value: 'web', controller: controller),
                _CategoryChip(
                    label: 'Wi-Fi', value: 'wifi', controller: controller),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final HomeController controller;

  const _SortChip({
    required this.label,
    required this.value,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: controller.sortOption.value == value,
          onSelected: (_) => controller.sortOption.value = value,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String value;
  final HomeController controller;

  const _CategoryChip({
    required this.label,
    required this.value,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FilterChip(
          label: Text(label),
          selected: controller.categoryFilter.value == value,
          onSelected: (_) => controller.categoryFilter.value = value,
        ),
      ),
    );
  }
}
