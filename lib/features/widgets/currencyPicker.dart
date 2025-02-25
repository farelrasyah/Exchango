import 'package:flutter/material.dart';
import '../../core/theme/Theme.dart';

class CurrencyPicker extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onSelect;
  final bool isSource;

  const CurrencyPicker({
    Key? key,
    required this.selectedCurrency,
    required this.onSelect,
    this.isSource = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCurrencySheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/flags/${selectedCurrency.toLowerCase()}.png',
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) => const Icon(Icons.money),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCurrency,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _getCurrencyName(selectedCurrency),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencyName(String code) {
    final names = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'IDR': 'Indonesian Rupiah',
      // Add more currencies as needed
    };
    return names[code] ?? code;
  }

  void _showCurrencySheet(BuildContext context) {
    // Implementation for currency picker bottom sheet
    // This will be implemented in the next update
  }
}
