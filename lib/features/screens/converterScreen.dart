import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/apiService.dart';
import '../widgets/currencyCard.dart';
import '../widgets/currencySelector.dart';
import '../widgets/amountInput.dart';
import '../widgets/quickConvert.dart';
import '../widgets/currencyChart.dart' as chart;
import '../../core/theme/Theme.dart';
import '../widgets/currencyPicker.dart';
import '../widgets/currencyConverterPanel.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({Key? key}) : super(key: key);

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController =
      TextEditingController(text: '1');
  String fromCurrency = 'IDR';
  String toCurrency = 'USD';
  double amount = 1.0;
  Map<String, double> rates = {};
  List<String> favorites = ['USD', 'EUR', 'GBP', 'JPY'];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Exchango'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          '${amount.toStringAsFixed(2)} $fromCurrency',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Currency Converter Card
                  _buildConverterCard(),

                  const SizedBox(height: 16),

                  // Exchange Rate Chart
                  _buildExchangeRateChart(),

                  const SizedBox(height: 16),

                  // Quick Actions
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _swapCurrencies,
        child: const Icon(Icons.swap_horiz),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildConverterCard() {
    final conversionRate = rates[toCurrency] ?? 0.0;

    return CurrencyConverterPanel(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      conversionRate: conversionRate,
      onSwap: _swapCurrencies,
      onAmountChanged: _updateAmount,
      onFromCurrencyChanged: (currency) {
        setState(() {
          fromCurrency = currency;
          _loadExchangeRates();
        });
      },
      onToCurrencyChanged: (currency) {
        setState(() {
          toCurrency = currency;
        });
      },
    );
  }

  Widget _buildExchangeRateChart() {
    // Create some dummy data points for demonstration
    final List<FlSpot> dummySpots = [
      const FlSpot(0, 0),
      const FlSpot(1, 1.2),
      const FlSpot(2, 1.8),
      const FlSpot(3, 1.5),
      const FlSpot(4, 2.0),
      const FlSpot(5, 1.9),
      const FlSpot(6, 2.2),
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: chart.CurrencyChart(
          spots: dummySpots,
          currencyPair: '$fromCurrency/$toCurrency',
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(String currency, bool isFrom) {
    return CurrencySelector(
      selectedCurrency: currency,
      onChanged: (String? newCurrency) {
        if (newCurrency != null) {
          setState(() {
            if (isFrom) {
              fromCurrency = newCurrency;
              _loadExchangeRates();
            } else {
              toCurrency = newCurrency;
            }
          });
        }
      },
    );
  }

  Widget _buildQuickActions() {
    return QuickConvert(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rates: rates,
      amount: amount,
      favorites: favorites,
    );
  }
}
