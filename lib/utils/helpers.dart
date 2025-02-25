import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    final formatters = {
      'IDR': NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ),
      'USD': NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
      ),
      'EUR': NumberFormat.currency(
        locale: 'de_DE',
        symbol: '€',
      ),
      // Add more currency formats as needed
    };

    return formatters[currencyCode]?.format(amount) ??
        NumberFormat.currency(symbol: currencyCode).format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }
}