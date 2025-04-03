import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Transport':
      return Icons.directions_car;
    case 'Food':
      return Icons.fastfood;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Entertainment':
      return Icons.movie;
    case 'Health':
      return Icons.healing;
    case 'Bills':
      return Icons.receipt_long;
    case 'Travel':
      return Icons.flight;
    case 'Salary':
      return Icons.attach_money;
    case 'Freelance':
      return Icons.laptop_mac;
    case 'Business':
      return Icons.business_center;
    case 'Investment':
      return Icons.trending_up;
    case 'Gift':
      return Icons.card_giftcard;
    case 'Other':
      return Icons.help_outline;
    default:
      return Icons.category;
  }
}

final Map<String, Color> categoryColors = {
  'Transport': Colors.deepOrange,
  'Food': Colors.pink,
  'Shopping': Colors.purple,
  'Entertainment': Colors.indigo,
  'Health': Colors.red,
  'Bills': Colors.brown,
  'Travel': Colors.teal,
  'Salary': Colors.green,
  'Freelance': Colors.blue,
  'Business': Colors.amber,
  'Investment': Colors.cyan,
  'Gift': Colors.orange,
  'Other': Colors.grey,
};


Color getCategoryColor(String category) {
  return categoryColors[category] ?? Colors.grey.withAlpha((0.7 * 255).toInt());
}
