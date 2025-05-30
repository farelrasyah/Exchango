import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'dart:ui';
import '../../data/services/apiService.dart';
import '../widgets/currencyConverterPanel.dart';
import '../widgets/quickConvert.dart';
import '../widgets/currencyChart.dart' as chart;
import '../../core/theme/Theme.dart';
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
    with TickerProviderStateMixin {
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

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_backgroundController);

    _loadExchangeRates();
    _amountController.addListener(() => _updateAmount(_amountController.text));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    _backgroundController.dispose();
    super.dispose();
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
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppTheme.dangerColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _loadExchangeRates();
          },
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
      backgroundColor: const Color(0xFFF6F4FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _CustomHeaderDelegate(
              minHeight: 90,
              maxHeight: 200,
              child: Builder(
                builder: (context) {
                  return Stack(
                    children: [
                      // Interactive animated background
                      AnimatedBuilder(
                        animation: _backgroundAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: InteractiveBackgroundPainter(
                              animation: _backgroundAnimation.value,
                              primaryColor: const Color(0xFF9747FF),
                              secondaryColor: const Color(0xFFB47AFF),
                            ),
                            child: Container(),
                          );
                        },
                      ),
                      // Interactive particle overlay
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: InteractiveParticlesPainter(
                            color: Colors.white.withOpacity(0.15),
                            animation: _shimmerAnimation.value,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                      // Dynamic wave effect
                      Positioned(
                        bottom: -2,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper: WaveClipper(
                                animation: _shimmerAnimation.value,
                              ),
                              child: Container(
                                height: 40,
                                color: const Color(0xFFF6F4FF),
                              ),
                            );
                          },
                        ),
                      ),
                      // Main content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Animated logo and title
                                  Row(
                                    children: [
                                      _buildAnimatedLogo(),
                                      const SizedBox(width: 12),
                                      _buildAnimatedTitle(),
                                    ],
                                  ),
                                  // Animated settings button
                                  _buildAnimatedSettingsButton(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildMainAmount(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainConverter(),
                      const SizedBox(height: 32),
                        _buildSectionTitle('Tren Nilai Tukar'),
                      const SizedBox(height: 16),
                      _buildExchangeRateChart(),
                      const SizedBox(height: 32),
                        _buildSectionTitle('Konversi Cepat'),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMainAmount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            const Color(0xFF9747FF),
            const Color(0xFFB47AFF),
            const Color(0xFFC78FFF),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9747FF).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
                'Jumlah Saat Ini',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.format(amount, fromCurrency),
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.format(
                      amount * (rates[toCurrency] ?? 0), toCurrency),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainConverter() {
    final conversionRate = rates[toCurrency] ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9747FF).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF9747FF).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: CurrencyConverterPanel(
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
      ),
    );
  }

  Widget _buildExchangeRateChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9747FF).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFF9747FF).withOpacity(0.03),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9747FF).withOpacity(0.1),
                  const Color(0xFFB47AFF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$fromCurrency / $toCurrency',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9747FF),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: chart.CurrencyChart(
              spots: [
                const FlSpot(0, 1.5),
                const FlSpot(1, 1.7),
                const FlSpot(2, 1.6),
                const FlSpot(3, 1.9),
                const FlSpot(4, 1.8),
                const FlSpot(5, 2.1),
                const FlSpot(6, 2.0),
              ],
              currencyPair: '$fromCurrency/$toCurrency',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9747FF).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white,
            const Color(0xFFB47AFF).withOpacity(0.03),
          ],
        ),
      ),
      child: QuickConvert(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        rates: rates,
        amount: amount,
        favorites: favorites,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9747FF),
            Color(0xFFB47AFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9747FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _swapCurrencies,
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.swap_horiz, size: 24),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF9747FF),
                Color(0xFFB47AFF),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(
                Icons.currency_exchange,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.white,
              Colors.white.withOpacity(0.8),
            ],
            stops: [
              _shimmerAnimation.value - 1,
              _shimmerAnimation.value,
              _shimmerAnimation.value + 1,
            ],
          ).createShader(bounds),
          child: Text(
            'Exchango',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSettingsButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 1),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _shimmerAnimation.value * 0.05,
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        );
      },
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

class _CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _CustomHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_CustomHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class ParticlesPainter extends CustomPainter {
  final Color color;
  final List<Offset> particles = [];
  final Random random = Random();

  ParticlesPainter({required this.color}) {
    // Generate random particles
    for (var i = 0; i < 50; i++) {
      particles.add(
        Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 200,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw particles
    for (var particle in particles) {
      canvas.drawCircle(particle, 1.5, paint);
      // Draw connecting lines between nearby particles
      for (var other in particles) {
        final distance = (particle - other).distance;
        if (distance < 30) {
          paint.color = color.withOpacity(0.3 * (1 - distance / 30));
          canvas.drawLine(particle, other, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlowingParticlesPainter extends CustomPainter {
  final Color color;
  final Color glowColor;
  final List<Offset> particles = [];
  final Random random = Random();

  GlowingParticlesPainter({
    required this.color,
    required this.glowColor,
  }) {
    for (var i = 0; i < 50; i++) {
      particles.add(
        Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 200,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw glow effect
    final glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Draw particles with glow
    for (var particle in particles) {
      canvas.drawCircle(particle, 2.5, glowPaint);
      canvas.drawCircle(
        particle,
        1.5,
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.fill,
      );

      // Draw connecting lines with glow
      for (var other in particles) {
        final distance = (particle - other).distance;
        if (distance < 30) {
          final opacity = 0.3 * (1 - distance / 30);
          canvas.drawLine(
            particle,
            other,
            Paint()
              ..color = glowColor.withOpacity(opacity)
              ..strokeWidth = 1.0
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InteractiveBackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  InteractiveBackgroundPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create dynamic gradient points
    final List<Color> colors = [
      primaryColor,
      secondaryColor,
      primaryColor.withOpacity(0.8),
      secondaryColor.withOpacity(0.8),
    ];

    final List<double> stops = [
      0.0,
      0.3,
      0.6,
      1.0,
    ];

    // Create animated gradient positions
    final center1 = Offset(
      size.width * 0.5 + cos(animation) * size.width * 0.3,
      size.height * 0.5 + sin(animation) * size.height * 0.3,
    );

    final center2 = Offset(
      size.width * 0.5 + cos(animation + pi) * size.width * 0.3,
      size.height * 0.5 + sin(animation + pi) * size.height * 0.3,
    );

    paint.shader = RadialGradient(
      colors: colors,
      stops: stops,
      center: Alignment(
        center1.dx / size.width * 2 - 1,
        center1.dy / size.height * 2 - 1,
      ),
      focal: Alignment(
        center2.dx / size.width * 2 - 1,
        center2.dy / size.height * 2 - 1,
      ),
      focalRadius: 0.5,
      radius: 1.5,
    ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(InteractiveBackgroundPainter oldDelegate) =>
      animation != oldDelegate.animation;
}

class InteractiveParticlesPainter extends CustomPainter {
  final Color color;
  final double animation;
  final List<Offset> particles = [];
  final Random random = Random();

  InteractiveParticlesPainter({
    required this.color,
    required this.animation,
  }) {
    for (var i = 0; i < 30; i++) {
      particles.add(
        Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 200,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final wave = sin(animation * 2 + i * 0.5) * 4;
      
      final position = Offset(
        particle.dx + wave,
        particle.dy + cos(animation + i * 0.5) * 4,
      );

      canvas.drawCircle(position, 2 + sin(animation + i) * 1, paint);

      for (var j = i + 1; j < particles.length; j++) {
        final other = particles[j];
        final distance = (position - other).distance;
        if (distance < 50) {
          paint.color = color.withOpacity(0.3 * (1 - distance / 50));
          canvas.drawLine(position, other, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(InteractiveParticlesPainter oldDelegate) =>
      animation != oldDelegate.animation;
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  WaveClipper({required this.animation});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);

    for (var i = 0.0; i <= size.width; i++) {
      path.lineTo(
        i,
        sin((i / size.width * 4 * pi) + animation * 2) * 8 + 24,
      );
    }

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => animation != oldClipper.animation;
}
