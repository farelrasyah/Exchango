import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    final formatters = {
      'IDR': NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
          customPattern: '#,##0 ¤'),
      'USD': NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      ),
      'EUR': NumberFormat.currency(
        locale: 'de_DE',
        symbol: '€',
        decimalDigits: 2,
      ),
      'GBP': NumberFormat.currency(
        locale: 'en_GB',
        symbol: '£',
        decimalDigits: 2,
      ),
      'JPY': NumberFormat.currency(
        locale: 'ja_JP',
        symbol: '¥',
        decimalDigits: 0,
      ),
    };

    final formatter = formatters[currencyCode] ??
        NumberFormat.currency(
          symbol: '$currencyCode ',
          decimalDigits: 2,
          locale: 'en_US',
        );

    try {
      // Add thousand separators and proper decimal places
      String result = formatter.format(amount);

      // For IDR, ensure proper grouping
      if (currencyCode == 'IDR') {
        // Remove any existing spaces
        result = result.replaceAll(' ', '');

        // Format with proper thousand separators
        final parts = result.split('Rp');
        if (parts.length > 1) {
          final number = double.parse(parts[1].replaceAll('.', ''));
          result = 'Rp ${NumberFormat('#,###').format(number)}';
        }
      }

      return result;
    } catch (e) {
      // Fallback formatting
      return '${currencyCode} ${NumberFormat('#,##0.00').format(amount)}';
    }
  }

  static String formatWithSeparators(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${formatWithSeparators(amount / 1000000000)}B';
    } else if (amount >= 1000000) {
      return '${formatWithSeparators(amount / 1000000)}M';
    } else if (amount >= 1000) {
      return '${formatWithSeparators(amount / 1000)}K';
    }
    return formatWithSeparators(amount);
  }
}
