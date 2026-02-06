import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/layout/mobile_scaffold.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String selectedStyle = 'All';

  final List<_StyleFilter> styleFilters = const [
    _StyleFilter(label: 'All', value: 'All', icon: Icons.apps_rounded),
    _StyleFilter(
      label: 'Traditional',
      value: 'Traditional',
      icon: Icons.temple_hindu_rounded,
    ),
    _StyleFilter(
      label: 'Modern',
      value: 'Modern',
      icon: Icons.architecture_rounded,
    ),
    _StyleFilter(label: 'Rustic', value: 'Rustic', icon: Icons.nature_rounded),
    _StyleFilter(
      label: 'Beach',
      value: 'Beach',
      icon: Icons.beach_access_rounded,
    ),
  ];

  final List<_InspirationItem> inspirations = const [
    _InspirationItem(
      title: 'Royal Rajasthani Mandap',
      style: 'Traditional',
      image:
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
    ),
    _InspirationItem(
      title: 'Garden Ceremony',
      style: 'Modern',
      image:
          'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=400',
    ),
    _InspirationItem(
      title: 'Beachside Vows',
      style: 'Beach',
      image:
          'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=400',
    ),
    _InspirationItem(
      title: 'Heritage Palace',
      style: 'Traditional',
      image:
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
    ),
    _InspirationItem(
      title: 'Boho Elegance',
      style: 'Rustic',
      image:
          'https://images.unsplash.com/photo-1519657337289-c4e3a3c86a1c?w=400',
    ),
    _InspirationItem(
      title: 'Minimal Modern',
      style: 'Modern',
      image:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    ),
    _InspirationItem(
      title: 'Sunset Romance',
      style: 'Beach',
      image:
          'https://images.unsplash.com/photo-1520854221256-17451cc331bf?w=400',
    ),
    _InspirationItem(
      title: 'Barn Wedding',
      style: 'Rustic',
      image:
          'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?w=400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredInspirations = selectedStyle == 'All'
        ? inspirations
        : inspirations.where((item) => item.style == selectedStyle).toList();

    return MobileScaffold(
      currentIndex: 3,
      title: 'Inspiration Gallery',
      showLogo: false,
      allowBack: false,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wedding Inspiration',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find your dream wedding style',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${filteredInspirations.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter chips
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: styleFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final filter = styleFilters[index];
                      final selected = selectedStyle == filter.value;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedStyle = filter.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? AppColors.primaryGradient
                                : null,
                            color: selected ? null : AppColors.surface,
                            borderRadius: BorderRadius.circular(23),
                            border: selected
                                ? null
                                : Border.all(color: AppColors.border),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                filter.icon,
                                size: 16,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                filter.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Gallery grid
          Expanded(
            child: filteredInspirations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 56,
                          color: AppColors.textMuted.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No inspirations found',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try selecting a different style',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: filteredInspirations.length,
                    itemBuilder: (context, index) {
                      final item = filteredInspirations[index];
                      return _InspirationCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StyleFilter {
  const _StyleFilter({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _InspirationItem {
  const _InspirationItem({
    required this.title,
    required this.style,
    required this.image,
  });

  final String title;
  final String style;
  final String image;
}

class _InspirationCard extends StatelessWidget {
  const _InspirationCard({required this.item});

  final _InspirationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              item.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(gradient: AppColors.cardGradient),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_rounded,
                    size: 40,
                    color: AppColors.textMuted.withOpacity(0.5),
                  ),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.style,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Favorite button
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
