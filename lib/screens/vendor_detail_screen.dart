import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/budget_category.dart';
import '../models/vendor.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/layout/app_card.dart';

class VendorDetailScreen extends StatelessWidget {
  const VendorDetailScreen({super.key, required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final contacts = vendor.contacts.isNotEmpty
        ? vendor.contacts
        : (vendor.contact
                  ?.split(',')
                  .where((c) => c.trim().isNotEmpty)
                  .toList() ??
              []);
    final imageUrl = vendor.image.isNotEmpty
        ? vendor.image
        : 'https://images.unsplash.com/photo-1519741497674-611481863552?w=900&h=700&fit=crop';

    return Scaffold(
      appBar: AppBar(title: Text(vendor.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: AppColors.border,
                    alignment: Alignment.center,
                    child: const Icon(Icons.photo, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(icon: Icons.category, text: vendor.category),
                      _InfoPill(icon: Icons.location_on, text: vendor.city),
                      _InfoPill(
                        icon: Icons.star,
                        text: vendor.wedScore.toStringAsFixed(1),
                      ),
                      _InfoPill(
                        icon: Icons.payments,
                        text: priceRangeLabel(vendor.priceRange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vendor.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Budget Section
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget & Spending',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _openAllocateBudget(context),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Add Expense'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (contacts.isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contacts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: contacts
                          .map(
                            (contact) => _InfoPill(
                              icon: Icons.call,
                              text: contact,
                              onTap: () => _launchDialer(contact),
                              isActionable: true,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            if (contacts.isNotEmpty) const SizedBox(height: 16),
            if ((vendor.profileName ?? '').isNotEmpty ||
                (vendor.link ?? '').isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Online',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if ((vendor.profileName ?? '').isNotEmpty)
                      _InfoRow(label: 'Profile', value: vendor.profileName!),
                    if ((vendor.link ?? '').isNotEmpty)
                      _InfoRow(label: 'Link', value: vendor.link!),
                  ],
                ),
              ),
            if ((vendor.remarks ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vendor.remarks!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openAllocateBudget(BuildContext context) async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final categories = budgetProvider.categories;

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a budget category first')),
      );
      return;
    }

    // Try to find a matching category based on vendor category
    BudgetCategory? selectedCategory;
    try {
      selectedCategory = categories.firstWhere(
        (c) =>
            c.name.toLowerCase().contains(vendor.category.toLowerCase()) ||
            vendor.category.toLowerCase().contains(c.name.toLowerCase()),
      );
    } catch (_) {
      selectedCategory = categories.first;
    }

    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Allocate to Budget'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Category:',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                DropdownButton<BudgetCategory>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    helperText:
                        'This will be added to the spent amount for this category',
                    helperMaxLines: 2,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCategory == null) return;
                  final amount = int.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;

                  final newSpent = selectedCategory!.spent + amount;
                  await budgetProvider.updateCategory(
                    id: selectedCategory!.id,
                    allocated: selectedCategory!.allocated,
                    spent: newSpent,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added ₹$amount to ${selectedCategory!.name}',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
    }
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    this.onTap,
    this.isActionable = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool isActionable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActionable
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(999),
          border: isActionable
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActionable ? AppColors.primary : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActionable ? AppColors.primary : AppColors.textPrimary,
                decoration: isActionable ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
