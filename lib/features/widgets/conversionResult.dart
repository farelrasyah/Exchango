import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/helpers.dart';

class ConversionResult extends StatelessWidget {
  final double amount;
  final double rate;
  final String fromCurrency;
  final String toCurrency;

  const ConversionResult({
    Key? key,
    required this.amount,
    required this.rate,
    required this.fromCurrency,
    required this.toCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final convertedAmount = amount * rate;
    
    return FadeIn(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(amount, fromCurrency),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.arrow_forward),
                  Text(
                    CurrencyFormatter.format(convertedAmount, toCurrency),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '1 $fromCurrency = ${rate.toStringAsFixed(4)} $toCurrency',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}