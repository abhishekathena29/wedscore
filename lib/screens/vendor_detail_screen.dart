import 'package:flutter/material.dart';

import '../models/vendor.dart';
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
        : (vendor.contact?.split(',').where((c) => c.trim().isNotEmpty).toList() ?? []);
    final imageUrl = vendor.image.isNotEmpty
        ? vendor.image
        : 'https://images.unsplash.com/photo-1519741497674-611481863552?w=900&h=700&fit=crop';

    return Scaffold(
      appBar: AppBar(
        title: Text(vendor.name),
      ),
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
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                    Text('Contacts', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: contacts
                          .map((contact) => _InfoPill(icon: Icons.call, text: contact))
                          .toList(),
                    ),
                  ],
                ),
              ),
            if (contacts.isNotEmpty) const SizedBox(height: 16),
            if ((vendor.profileName ?? '').isNotEmpty || (vendor.link ?? '').isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Online', style: Theme.of(context).textTheme.titleMedium),
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
                    Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      vendor.remarks!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
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
