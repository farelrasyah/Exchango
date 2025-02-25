import 'package:flutter/material.dart';

class CurrencyCard extends StatelessWidget {
  final String currency;
  final double rate;
  final double amount;

  const CurrencyCard({
    Key? key,
    required this.currency,
    required this.rate,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currency,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              (rate * amount).toStringAsFixed(2),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}