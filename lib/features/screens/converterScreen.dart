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
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 1),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.currency_exchange,
                          color: Colors.white.withOpacity(value),
                          size: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.9),
                      ],
                    ).createShader(bounds),
                    child: const Text('Exchango'),
                  ),
                ],
              ),
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.secondaryColor.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Animated Background Patterns
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BackgroundPatternPainter(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Main Content
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Animated Amount Display
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween(begin: 0.0, end: amount),
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  Text(
                                    CurrencyFormatter.format(
                                        value, fromCurrency),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(0, 4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      '≈ ${CurrencyFormatter.format(value * (rates[toCurrency] ?? 0), toCurrency)}',
                                      key: ValueKey(toCurrency),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + spacing, size.height),
        paint,
      );
      x += spacing * 2;
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) => false;
}

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    return '${currencyCode} ${amount.toStringAsFixed(2)}';
  }
}
