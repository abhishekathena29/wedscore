import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/vendor_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../utils/formatters.dart';
import '../layout/app_card.dart';

class VendorPreview extends StatelessWidget {
  const VendorPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorProvider>(
      builder: (context, vendorProvider, child) {
        final previewVendors = vendorProvider.vendors.take(3).toList();

        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top Vendors',
                      style: Theme.of(context).textTheme.titleLarge),
                  _ChipBadge(text: '${previewVendors.length}'),
                ],
              ),
              const SizedBox(height: 12),
              if (vendorProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (previewVendors.isEmpty)
                Text(
                  'No vendors yet',
                  style: Theme.of(context).textTheme.labelSmall,
                )
              else
                ...previewVendors.map((vendor) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              vendor.image,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 56,
                                  height: 56,
                                  color: AppColors.border,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.photo, size: 16),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        vendor.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.favorite_border,
                                        size: 16,
                                        color: AppColors.textMuted),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _OutlineBadge(text: vendor.category),
                                    const SizedBox(width: 6),
                                    Text(
                                      vendor.city,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 14, color: AppColors.primary),
                                    const SizedBox(width: 2),
                                    Text(
                                      vendor.wedScore.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      priceRangeLabel(vendor.priceRange),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 4),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.vendors),
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('View all vendors'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }
}
