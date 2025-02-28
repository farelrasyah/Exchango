import 'package:flutter/material.dart';
import '../../core/theme/Theme.dart';
import '../../utils/helpers.dart';

class QuickConvert extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final Map<String, double> rates;
  final double amount;
  final List<String> favorites;

  const QuickConvert({
    Key? key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rates,
    required this.amount,
    required this.favorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Text(
                  'Quick Convert',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                // Ganti ListView.builder dengan SingleChildScrollView
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: favorites.map((currency) {
                    final rate = rates[currency] ?? 0.0;
                    final convertedAmount = amount * rate;

                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currency,
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(
                                  convertedAmount, currency),
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
