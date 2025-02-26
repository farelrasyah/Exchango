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
    for (int i = 0; i < 8; i++) {
      _floatingIcons.add(
        AnimatedIconData(
          icon: _getRandomIcon(),
          position: Offset(
            _random.nextDouble() * (size.width - 40),
            _random.nextDouble() * 200,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 2,
            (_random.nextDouble() - 0.5) * 2,
          ),
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
        ),
      );
    }
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
      final result = await _apiService.getExchangeRates(fromCurrency);
      setState(() => rates = result.conversionRates);
    } catch (e) {
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load exchange rates'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
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
                  // Animated Background Patterns
                  Positioned.fill(
                    child: CustomPaint(
                      painter: AnimatedBackgroundPainter(
                        color: Colors.white.withOpacity(0.1),
                        animation: _controller,
                      ),
                    ),
                  ),
                  // Floating Currency Icons
                  _buildFloatingIcons(),
                  // Main Content with Amount Display
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          // Animated Amount Display with Shimmer Effect
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                                Colors.white,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              transform: GradientRotation(
                                  _controller.value * 2 * math.pi),
                            ).createShader(bounds),
                            child: _buildAnimatedAmount(),
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
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: amount),
      builder: (context, value, child) {
        return Column(
          children: [
            Text(
              CurrencyFormatter.format(value, fromCurrency),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36,
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
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '≈ ${CurrencyFormatter.format(value * (rates[toCurrency] ?? 0), toCurrency)}',
                key: ValueKey(toCurrency),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
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

  Widget _buildFloatingIcons() {
    if (_floatingIcons.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _floatingIcons.map((iconData) {
            // Update position
            iconData.position += iconData.velocity;
            iconData.rotation += iconData.rotationSpeed;

            // Bounce off edges
            final size = MediaQuery.of(context).size;
            if (iconData.position.dx <= 0 ||
                iconData.position.dx >= size.width - 40) {
              iconData.velocity =
                  Offset(-iconData.velocity.dx, iconData.velocity.dy);
            }
            if (iconData.position.dy <= 0 || iconData.position.dy >= 200) {
              iconData.velocity =
                  Offset(iconData.velocity.dx, -iconData.velocity.dy);
            }

            return Positioned(
              left: iconData.position.dx,
              top: iconData.position.dy,
              child: Transform.rotate(
                angle: iconData.rotation,
                child: Icon(
                  iconData.icon,
                  color: Colors.white.withOpacity(0.3),
                  size: 24,
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

class AnimatedBackgroundPainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;

  AnimatedBackgroundPainter({
    required this.color,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    var x = 0.0;
    final offset = animation.value * spacing;

    while (x < size.width + spacing) {
      canvas.drawLine(
        Offset(x - offset, 0),
        Offset(x + spacing - offset, size.height),
        paint,
      );
      x += spacing * 2;
    }
  }

  @override
  bool shouldRepaint(AnimatedBackgroundPainter oldDelegate) =>
      color != oldDelegate.color;
}

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    return '${currencyCode} ${amount.toStringAsFixed(2)}';
  }
}

class AnimatedIconData {
  IconData icon;
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;

  AnimatedIconData({
    required this.icon,
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
  });
}
