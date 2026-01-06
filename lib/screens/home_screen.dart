import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/dashboard/budget_overview.dart';
import '../widgets/dashboard/checklist_preview.dart';
import '../widgets/dashboard/city_selector.dart';
import '../widgets/dashboard/vendor_preview.dart';
import '../widgets/layout/mobile_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = 'Jaipur';

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Text(
                  'Your Wedding Journey',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Plan your perfect day with ease',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Planning in',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 6),
                    CitySelector(
                      selectedCity: selectedCity,
                      onCityChange: (city) => setState(() => selectedCity = city),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: _StatTile(label: 'Days', value: '120')),
                SizedBox(width: 8),
                Expanded(child: _StatTile(label: 'Booked', value: '8')),
                SizedBox(width: 8),
                Expanded(child: _StatTile(label: 'Budget', value: '65%')),
                SizedBox(width: 8),
                Expanded(child: _StatTile(label: 'Tasks', value: '12')),
              ],
            ),
            const SizedBox(height: 20),
            const BudgetOverview(),
            const SizedBox(height: 16),
            const ChecklistPreview(),
            const SizedBox(height: 16),
            const VendorPreview(),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
