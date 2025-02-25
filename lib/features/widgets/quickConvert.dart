import 'package:flutter/material.dart';
import '../../core/theme/Theme.dart';

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
            Text(
              'Quick Convert',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final currency = favorites[index];
                  final rate = rates[currency] ?? 0.0;
                  return Card(
                    margin: const EdgeInsets.only(right: 8),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currency,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            (amount * rate).toStringAsFixed(2),
                            style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }
}
