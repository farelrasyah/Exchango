import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/apiService.dart';
import '../widgets/currencyCard.dart';
import '../widgets/currencySelector.dart';
import '../widgets/amountInput.dart';
import '../widgets/quickConvert.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({Key? key}) : super(key: key);

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController =
      TextEditingController(text: '1');
  String fromCurrency = 'IDR';
  String toCurrency = 'USD';
  double amount = 1.0;
  Map<String, double> rates = {};
  List<String> favorites = ['USD', 'EUR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
    _amountController.addListener(() => _updateAmount(_amountController.text));
  }

  void _updateAmount(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 0;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _loadExchangeRates() async {
    try {
      final result = await _apiService.getExchangeRates(fromCurrency);
      setState(() => rates = result.conversionRates);
    } catch (e) {
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load exchange rates')),
    );
  }

  void _swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
    });
    HapticFeedback.mediumImpact();
    _loadExchangeRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchango'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {/* Show history */},
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Convert Section
          QuickConvert(favorites: favorites),

          // Main Converter
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AmountInput(
                    controller: _amountController,
                    onChanged: _updateAmount,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CurrencySelector(
                          selectedCurrency: fromCurrency,
                          onChanged: (value) {
                            setState(() => fromCurrency = value!);
                            _loadExchangeRates();
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: _swapCurrencies,
                      ),
                      Expanded(
                        child: CurrencySelector(
                          selectedCurrency: toCurrency,
                          onChanged: (value) {
                            setState(() => toCurrency = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Conversion Result
          if (rates.isNotEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      (amount * (rates[toCurrency] ?? 1)).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      toCurrency,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
