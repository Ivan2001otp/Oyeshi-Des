import 'package:flutter/material.dart';
import 'package:oyeshi_des/constants/fonts.dart';
import 'package:oyeshi_des/pages/pay_wall/widget/lottie_animation.dart';
import 'package:oyeshi_des/pages/pay_wall/widget/utility_widgets.dart';
import 'package:oyeshi_des/widgets/utility_widget.dart';
import '../../themes/app_theme.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedPlan = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        primary: true,
        physics: const BouncingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A0F1E),
                      Color(0xFF0F1A1F),
                      Color(0xFF0B1219),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xFFF0FDF4),
                      Color.fromARGB(255, 214, 245, 214),
                    ],
                  ),
          ),
          child: SafeArea(
            child: Column(
              spacing: 6,
              children: [
                // Header
                PaywallUtilityWidgets.buildHeader(isDark),

                UtilityWidgets.DefaultContainerWidget(
                  isMargin: true,
                  hM: 12,
                  vM: 4,
                  child: Text(
                    "Cook what you have. Love what you make.",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: FontConstants.fontFamily,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Stack(
                  children: [
                    Positioned(
                      child: LottieAnimationWidget(
                        assetPath: "assets/lottie/paywall_animation.json",
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                    ),
                    Positioned(
                      left: 1,
                      right: 1,
                      child: Icon(
                        Icons.food_bank_outlined,
                        size: 120,
                        color: isDark
                            ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                            : const Color.fromARGB(255, 18, 163, 71)
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),

                Column(
                  spacing: 12,
                  children: [
                    _buildPlanCard(
                        isDark: isDark,
                        features: [],
                        isPopular: false,
                        period: "week",
                        price: "\$92",
                        title: "Weekly Plan"),
                    _buildPlanCard(
                        isDark: isDark,
                        features: [],
                        isPopular: true,
                        period: "week",
                        price: "\$32",
                        title: "1 Month Plan"),
                    _buildPlanCard(
                        isDark: isDark,
                        features: [],
                        isPopular: false,
                        period: "week",
                        price: "\$18",
                        title: "2 Month Plan"),
                  ],
                ),
                PaywallUtilityWidgets.buildCTAButton(isDark, _selectedPlan),
                PaywallUtilityWidgets.buildTermsLinks(isDark)
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPlanCard({
    required bool isDark,
    required String title,
    required String price,
    required String period,
    String? savings,
    required bool isPopular,
    required List<String> features,
  }) {
    final isSelected = _selectedPlan == title.toLowerCase();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = title.toLowerCase()),
            child: AnimatedContainer(
              margin: EdgeInsets.symmetric(
                horizontal: 12,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: isPopular && isSelected
                    ? LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E3A2A), const Color(0xFF1E2A3A)]
                            : [
                                const Color(0xFFE6F7E6),
                                const Color(0xFFF0FDF4)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : isSelected
                        ? LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF0F172A)
                                  ]
                                : [Colors.white, const Color(0xFFFAFAFA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1A1E2A),
                                    const Color(0xFF141824)
                                  ]
                                : [Colors.white, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isPopular
                      ? const Color(0xFF22C55E)
                      : isSelected
                          ? isDark
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF22C55E).withOpacity(0.5)
                          : isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[200]!,
                  width: isPopular ? 2 : 1.5,
                ),
                boxShadow: isPopular
                    ? [
                        BoxShadow(
                          color: const Color(0xFF22C55E)
                              .withOpacity(isDark ? 0.3 : 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : isSelected
                        ? [
                            BoxShadow(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
              ),
              child: Stack(
                children: [
                  if (isPopular)
                    Positioned(
                      top: -1,
                      right: 52,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'BEST VALUE',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: FontConstants.fontFamily,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: FontConstants.fontFamily,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF22C55E)
                                      : isDark
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.grey[400]!,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? const Color(0xFF22C55E)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: FontConstants.fontFamily,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '/ $period',
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white60
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (savings != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              savings,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ...features.map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: isDark
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFF22C55E),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
