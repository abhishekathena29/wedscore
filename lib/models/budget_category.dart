import 'package:flutter/material.dart';

class BudgetCategory {
  const BudgetCategory({
    required this.id,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.icon,
  });

  final String id;
  final String name;
  final int allocated;
  final int spent;
  final IconData icon;
}
