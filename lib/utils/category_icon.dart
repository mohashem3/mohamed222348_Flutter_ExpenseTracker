import 'package:flutter/material.dart';

/// Returns an icon that visually represents a given transaction category.
/// Used to improve UI clarity and quick recognition of transaction types.
IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Transport':
      return Icons.directions_car; // Represents car or commuting expenses
    case 'Food':
      return Icons.fastfood; // Suitable for dining, groceries, or snacks
    case 'Shopping':
      return Icons.shopping_bag; // Covers retail and ecommerce purchases
    case 'Entertainment':
      return Icons.movie; // Applicable to movies, concerts, subscriptions, etc.
    case 'Health':
      return Icons.healing; // For health-related spending like pharmacy or doctor visits
    case 'Bills':
      return Icons.receipt_long; // Used for utilities, rent, or recurring charges
    case 'Travel':
      return Icons.flight; // Represents airplane travel or vacations
    case 'Salary':
      return Icons.attach_money; // Represents income from primary employment
    case 'Freelance':
      return Icons.laptop_mac; // Indicates income from freelance or contract work
    case 'Business':
      return Icons.business_center; // Business-related income or expenses
    case 'Investment':
      return Icons.trending_up; // Used for stocks, crypto, or similar investments
    case 'Gift':
      return Icons.card_giftcard; // Expenses or income classified as gifts
    case 'Other':
      return Icons.help_outline; // Catch-all for unclassified or misc. transactions
    default:
      return Icons.category; // Default fallback icon for unknown categories
  }
}

/// A mapping between category names and corresponding color codes used in the UI.
/// This improves UX by maintaining consistent visual identity per category.
final Map<String, Color> categoryColors = {
  'Transport': Colors.deepOrange,     // Warm, energetic tone for travel
  'Food': Colors.pink,                // Friendly and appetizing color
  'Shopping': Colors.purple,          // Vibrant and consumer-focused
  'Entertainment': Colors.indigo,     // Leisure-oriented, modern color
  'Health': Colors.red,               // Commonly associated with medical services
  'Bills': Colors.brown,              // Neutral and practical
  'Travel': Colors.teal,              // Cool, vacation-like tone
  'Salary': Colors.green,             // Green often represents income and money
  'Freelance': Colors.blue,           // Reflects digital/remote work
  'Business': Colors.amber,           // Professional and optimistic
  'Investment': Colors.cyan,          // Associated with growth and data
  'Gift': Colors.orange,              // Positive and celebratory
  'Other': Colors.grey,               // Neutral for undefined/misc. types
};

/// Returns the color associated with the given category, or a semi-transparent grey fallback.
/// Used to consistently style UI components (icons, chips, badges) per category.
Color getCategoryColor(String category) {
  return categoryColors[category] ?? Colors.grey.withAlpha((0.7 * 255).toInt()); 
  // Fallback ensures UI remains styled even with unknown categories.
}
