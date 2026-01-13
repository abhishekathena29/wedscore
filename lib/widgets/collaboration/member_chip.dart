import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MemberChip extends StatelessWidget {
  const MemberChip({
    super.key,
    required this.name,
    required this.role,
    this.isOwner = false,
  });

  final String name;
  final String role;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: AppColors.primarySoft,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      label: Text(name),
      labelStyle: const TextStyle(fontSize: 12),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
