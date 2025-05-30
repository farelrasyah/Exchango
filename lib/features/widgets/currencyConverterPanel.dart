import 'package:flutter/material.dart';
import '../../core/theme/Theme.dart';
import '../../utils/helpers.dart';

class CurrencyConverterPanel extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double conversionRate;
  final VoidCallback onSwap;
  final Function(String) onAmountChanged;
  final Function(String) onFromCurrencyChanged;
  final Function(String) onToCurrencyChanged;

  const CurrencyConverterPanel({
    Key? key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.conversionRate,
    required this.onSwap,
    required this.onAmountChanged,
    required this.onFromCurrencyChanged,
    required this.onToCurrencyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final convertedAmount = amount * conversionRate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Amount Input Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Anda Kirim',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.headlineMedium,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                        onChanged: onAmountChanged,
                      ),
                    ),
                    _CurrencyButton(
                      currency: fromCurrency,
                      onPressed: () => onFromCurrencyChanged(fromCurrency),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Swap Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.swap_vert, color: Colors.white),
            ),
            onPressed: onSwap,
          ),

          // Converted Amount Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Anda Terima',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        CurrencyFormatter.format(convertedAmount, toCurrency),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ),
                    _CurrencyButton(
                      currency: toCurrency,
                      onPressed: () => onToCurrencyChanged(toCurrency),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Exchange Rate Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '1 $fromCurrency = ${CurrencyFormatter.formatWithSeparators(conversionRate)} $toCurrency',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyButton extends StatelessWidget {
  final String currency;
  final VoidCallback onPressed;

  const _CurrencyButton({
    Key? key,
    required this.currency,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Text(
                currency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
