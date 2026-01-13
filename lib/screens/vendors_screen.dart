import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/vendor.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/layout/mobile_scaffold.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  late List<Vendor> vendors;
  String selectedCity = 'All';
  String selectedCategory = 'All';
  int selectedPrice = 0;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    vendors = seedVendors();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleShortlist(String vendorId) {
    setState(() {
      vendors = vendors
          .map((vendor) => vendor.id == vendorId
              ? vendor.copyWith(shortlisted: !vendor.shortlisted)
              : vendor)
          .toList();
    });
  }

  List<Vendor> get filteredVendors {
    return vendors.where((vendor) {
      final matchesCity = selectedCity == 'All' || vendor.city == selectedCity;
      final matchesCategory =
          selectedCategory == 'All' || vendor.category == selectedCategory;
      final matchesPrice = selectedPrice == 0 || vendor.priceRange == selectedPrice;
      final query = searchQuery.toLowerCase();
      final matchesSearch = vendor.name.toLowerCase().contains(query) ||
          vendor.description.toLowerCase().contains(query);
      return matchesCity && matchesCategory && matchesPrice && matchesSearch;
    }).toList();
  }

  bool get hasActiveFilters =>
      selectedCity != 'All' || selectedCategory != 'All' || selectedPrice != 0;

  void clearFilters() {
    setState(() {
      selectedCity = 'All';
      selectedCategory = 'All';
      selectedPrice = 0;
    });
  }

  void openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateFilters(void Function() updater) {
              setState(updater);
              setModalState(() {});
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                      if (hasActiveFilters)
                        TextButton(
                          onPressed: () => updateFilters(clearFilters),
                          child: const Text('Clear all'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCity,
                    items: [
                      const DropdownMenuItem(value: 'All', child: Text('All Cities')),
                      ...cities
                          .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              )),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      updateFilters(() => selectedCity = value);
                    },
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: [
                      const DropdownMenuItem(value: 'All', child: Text('All Categories')),
                      ...categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              )),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      updateFilters(() => selectedCategory = value);
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedPrice,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('All Budgets')),
                      DropdownMenuItem(value: 1, child: Text('₹ - Budget')),
                      DropdownMenuItem(value: 2, child: Text('₹₹ - Moderate')),
                      DropdownMenuItem(value: 3, child: Text('₹₹₹ - Premium')),
                      DropdownMenuItem(value: 4, child: Text('₹₹₹₹ - Luxury')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      updateFilters(() => selectedPrice = value);
                    },
                    decoration: const InputDecoration(labelText: 'Budget'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Show ${filteredVendors.length} Results'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredVendors;

    return MobileScaffold(
      currentIndex: 2,
      title: 'Vendors',
      showLogo: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Search vendors...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: openFilters,
                  icon: Icon(
                    Icons.tune,
                    color: hasActiveFilters ? AppColors.primary : AppColors.textMuted,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (selectedCity != 'All')
                    InputChip(
                      label: Text(selectedCity),
                      onDeleted: () => setState(() => selectedCity = 'All'),
                    ),
                  if (selectedCategory != 'All')
                    InputChip(
                      label: Text(selectedCategory),
                      onDeleted: () => setState(() => selectedCategory = 'All'),
                    ),
                  if (selectedPrice != 0)
                    InputChip(
                      label: Text(priceRangeLabel(selectedPrice)),
                      onDeleted: () => setState(() => selectedPrice = 0),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} vendors',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                _OutlineBadge(
                  text: '${vendors.where((vendor) => vendor.shortlisted).length} saved',
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...filtered.map((vendor) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              vendor.image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: _PillBadge(text: vendor.category),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      vendor.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => toggleShortlist(vendor.id),
                                    icon: Icon(
                                      vendor.shortlisted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: vendor.shortlisted
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    vendor.wedScore.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 2),
                                  Text(
                                    vendor.city,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                  const Spacer(),
                                  Text(
                                    priceRangeLabel(vendor.priceRange),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                vendor.description,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  child: const Text('Contact'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'No vendors found',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextButton(
                        onPressed: clearFilters,
                        child: const Text('Clear all filters'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _OutlineBadge extends StatelessWidget {
  const _OutlineBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
