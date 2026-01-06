import 'package:intl/intl.dart';

String formatRupees(int amount) {
  if (amount >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)}L';
  }
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(amount);
}

String priceRangeLabel(int range) => List.filled(range, '₹').join();
