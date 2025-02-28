import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'dart:math';
import '../../data/services/apiService.dart';
import '../widgets/currencyCard.dart';
import '../widgets/currencySelector.dart';
import '../widgets/amountInput.dart';
import '../widgets/quickConvert.dart';
import '../widgets/currencyChart.dart' as chart;
import '../../core/theme/Theme.dart';
import '../widgets/currencyPicker.dart';
import '../widgets/currencyConverterPanel.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double value, String currencyCode) {
    final formatter = NumberFormat.currency(
      symbol: currencyCode,
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
}

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
  final List<AnimatedIconData> _floatingIcons = [];
  final Random _random = Random();
  final int numberOfIcons = 20; // More icons
  final double maxSpeed = 1.2; // Increased from 0.5
  final double maxRotationSpeed = 0.03; // Slightly increased from 0.02

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16), // 60 FPS
      vsync: this,
    )..repeat(); // Make it continuous

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _loadExchangeRates();
    _amountController.addListener(() => _updateAmount(_amountController.text));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move initialization here since it needs MediaQuery
    if (_floatingIcons.isEmpty) {
      _initializeFloatingIcons();
    }
  }

  void _initializeFloatingIcons() {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < numberOfIcons; i++) {
      _floatingIcons.add(
        AnimatedIconData(
          icon: _getRandomIcon(),
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * 280, // Sesuaikan dengan tinggi AppBar
          ),
          velocity: _getRandomVelocity(),
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * maxRotationSpeed,
          size: _random.nextDouble() * 20 + 30, // Increased size range: 30-50
        ),
      );
    }
  }

  Offset _getRandomVelocity() {
    return Offset(
      (_random.nextDouble() - 0.5) *
          maxSpeed *
          1.5, // Multiply by 1.5 for extra speed
      (_random.nextDouble() - 0.5) * maxSpeed * 1.5,
    );
  }

  IconData _getRandomIcon() {
    final icons = [
      Icons.currency_exchange,
      Icons.attach_money,
      Icons.euro,
      Icons.currency_pound,
      Icons.currency_yen,
      Icons.currency_rupee,
      Icons.currency_bitcoin,
      Icons.savings,
      Icons.account_balance,
      Icons.credit_card,
      Icons.payment,
      Icons.monetization_on,
      Icons.money_off,
      Icons.account_balance_wallet,
      Icons.price_change,
      Icons.price_check,
      Icons.currency_franc,
      Icons.currency_lira,
      Icons.currency_ruble,
      Icons.local_atm,
    ];
    return icons[_random.nextInt(icons.length)];
  }

  void _updateAmount(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 0;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _loadExchangeRates() async {
    try {
      setState(() {
        // Show loading state
        rates = {};
      });

      final result = await _apiService.getExchangeRates(fromCurrency);

      if (mounted) {
        setState(() {
          rates = result.conversionRates;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
        // Use default rates as fallback
        setState(() {
          rates = Map<String, double>.from({
            'USD': 0.000064,
            'EUR': 0.000059,
            'GBP': 0.000051,
            'JPY': 0.009657,
            'IDR': 1.0,
          });
        });
      }
    }
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(error),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadExchangeRates,
        ),
      ),
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
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: _buildAnimatedTitle(),
              background: Stack(
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.deepPurple,
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  // Animated Pattern Background
                  _buildAnimatedPattern(),
                  // Floating Icons dengan animasi yang lebih dinamis
                  _buildFloatingIcons(),
                  // Main Content
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          _buildAnimatedAmount(),
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

  IconData _getCurrencyIcon(int index) {
    final icons = [
      Icons.attach_money,
      Icons.euro,
      Icons.currency_pound,
      Icons.currency_yen,
      Icons.currency_rupee,
      Icons.currency_bitcoin,
    ];
    return icons[index % icons.length];
  }

  Widget _buildAnimatedAmount() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800), // Longer duration
      curve: Curves.easeOutCubic, // Smoother curve
      tween: Tween(begin: 0.0, end: amount),
      builder: (context, value, child) {
        return Column(
          children: [
            Text(
              CurrencyFormatter.format(value, fromCurrency),
              style: GoogleFonts.poppins(
                fontSize: 42, // Larger font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                '≈ ${CurrencyFormatter.format(value * (rates[toCurrency] ?? 0), toCurrency)}',
                key: ValueKey('$toCurrency${value.toStringAsFixed(2)}'),
                style: GoogleFonts.poppins(
                  fontSize: 24, // Larger font size
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
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
    );
  }

  Widget _buildAnimatedPattern() {
    return CustomPaint(
      painter: BackgroundPatternPainter(
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildFloatingIcons() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;

        for (var iconData in _floatingIcons) {
          // Update position with increased speed
          iconData.position += iconData.velocity;
          iconData.rotation += iconData.rotationSpeed;

          // Bounce with higher velocity retention
          if (iconData.position.dx <= 0 ||
              iconData.position.dx >= size.width - 40) {
            iconData.velocity = Offset(
              -iconData.velocity.dx *
                  0.9, // Increased from 0.8 for more momentum
              iconData.velocity.dy,
            );
          }
          if (iconData.position.dy <= 0 || iconData.position.dy >= 280) {
            iconData.velocity = Offset(
              iconData.velocity.dx,
              -iconData.velocity.dy *
                  0.9, // Increased from 0.8 for more momentum
            );
          }

          // Reduce random direction changes
          if (_random.nextDouble() < 0.005) {
            // Reduced probability of direction change
            iconData.velocity = _getRandomVelocity();
          }
        }

        return Stack(
          children: _floatingIcons.map((iconData) {
            return Positioned(
              left: iconData.position.dx,
              top: iconData.position.dy,
              child: Transform.rotate(
                angle: iconData.rotation,
                child: Icon(
                  iconData.icon,
                  color: Colors.white.withOpacity(0.25),
                  size: iconData.size,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder(
          duration: const Duration(seconds: 1),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.rotate(
              angle: value * 2 * pi,
              child: Icon(
                Icons.currency_exchange,
                color: Colors.white.withOpacity(value),
                size: 32,
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              AppTheme.accentColor.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            'Exchango',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
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

class AnimatedIconData {
  IconData icon;
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  double size; // Tambahkan properti size

  AnimatedIconData({
    required this.icon,
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}
