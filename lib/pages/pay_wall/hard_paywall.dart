import 'package:flutter/material.dart';
import 'dart:ui';

import '../../themes/app_theme.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedPlan = 'monthly';
  bool _isAnnualSelected = false;

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
      body: Container(
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
                    Color(0xFFF7FEE7),
                    Color(0xFFF0FDF4),
                    Color(0xFFE6F7E6),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(isDark),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Hero Section
                            _buildHeroSection(isDark),
                            const SizedBox(height: 32),
                            
                            // Savings Badge
                            _buildSavingsBadge(isDark),
                            const SizedBox(height: 32),
                            
                            // Plan Toggle
                            _buildPlanToggle(isDark),
                            const SizedBox(height: 32),
                            
                            // Plan Cards
                            if (!_isAnnualSelected) ...[
                              _buildWeeklyPlan(isDark),
                              const SizedBox(height: 16),
                              _buildMonthlyPlan(isDark),
                              const SizedBox(height: 16),
                              _buildQuarterlyPlan(isDark),
                              const SizedBox(height: 16),
                              _buildYearlyPlan(isDark),
                            ] else ...[
                              _buildAnnualPlan(isDark),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            // CTA Button
                            _buildCTAButton(isDark),
                            const SizedBox(height: 16),
                            
                            // Guarantee & Legal
                            const SizedBox(height: 16),
                            
                            // Terms Links
                            _buildTermsLinks(isDark),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF0A0F1E).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: .05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF22C55E).withValues(alpha: 0.2), const Color(0xFF16A34A).withValues(alpha: 0.1)]
                    : [const Color(0xFF22C55E).withValues(alpha: 0.1), const Color(0xFFDC2626).withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                    : const Color(0xFF22C55E).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 6),
                Text(
                  '80% SAVING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: isDark
                  ? [const Color(0xFF22C55E).withValues(alpha: 0.3), Colors.transparent]
                  : [const Color(0xFF22C55E).withValues(alpha: 0.2), Colors.transparent],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2E1A) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                        : const Color(0xFF22C55E).withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF22C55E),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Unlock Your Food-Saving Journey',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Get personalized AI meal plans, scan receipts, and never waste food again',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSavingsBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A2A), const Color(0xFF1E2A3A)]
              : [const Color(0xFFE6F7E6), const Color(0xFFE6F0FA)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF22C55E).withValues(alpha: 0.3)
              : const Color(0xFF22C55E).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_rounded,
            color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF22C55E),
            size: 24,
          ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              children: [
                const TextSpan(
                  text: 'Average user saves ',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: '\$47/month',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnualSelected = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isAnnualSelected
                      ? isDark
                          ? const Color(0xFF334155)
                          : Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: !_isAnnualSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Monthly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: !_isAnnualSelected
                        ? isDark
                            ? Colors.white
                            : const Color(0xFF22C55E)
                        : isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnualSelected = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isAnnualSelected
                      ? isDark
                          ? const Color(0xFF334155)
                          : Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: _isAnnualSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Annual',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isAnnualSelected
                            ? isDark
                                ? Colors.white
                                : const Color(0xFF22C55E)
                            : isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        '-20%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlan(bool isDark) {
    return _buildPlanCard(
      isDark: isDark,
      title: 'Weekly',
      price: '\$89.99',
      period: 'week',
      savings: null,
      isPopular: false,
      features: ['7 days AI meal plans', 'Receipt scanning', 'Voice input', 'Basic analytics'],
    );
  }

  Widget _buildMonthlyPlan(bool isDark) {
    return _buildPlanCard(
      isDark: isDark,
      title: 'Monthly',
      price: '\$69.99',
      period: 'month',
      savings: 'Save 50%',
      isPopular: true,
      features: ['Unlimited AI meal plans', 'Receipt scanning', 'Voice input', 'Advanced analytics', 'Export shopping lists'],
    );
  }

  Widget _buildQuarterlyPlan(bool isDark) {
    return _buildPlanCard(
      isDark: isDark,
      title: 'Quarterly',
      price: '\$139.99',
      period: '3 months',
      savings: 'Save 60%',
      isPopular: false,
      features: ['Everything in Monthly', 'Priority support', 'Recipe customization', 'Waste tracking reports'],
    );
  }

  Widget _buildYearlyPlan(bool isDark) {
    return _buildPlanCard(
      isDark: isDark,
      title: 'Half-Yearly',
      price: '\$399.99',
      period: '6 months',
      savings: 'Save 65%',
      isPopular: false,
      features: ['Everything in Quarterly', 'Family sharing (3 users)', 'Nutrition insights', 'Carbon footprint tracking'],
    );
  }

  Widget _buildAnnualPlan(bool isDark) {
    return _buildPlanCard(
      isDark: isDark,
      title: 'Annual',
      price: '\$499.99',
      period: 'year',
      savings: 'Save 70%',
      isPopular: true,
      features: [
        'Everything in Half-Yearly',
        'Family sharing (5 users)',
        'Premium AI chef',
        'Restaurant partner discounts',
        'Exclusive recipes',
      ],
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
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = title.toLowerCase()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: isPopular && isSelected
                    ? LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E3A2A), const Color(0xFF1E2A3A)]
                            : [const Color(0xFFE6F7E6), const Color(0xFFF0FDF4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : isSelected
                        ? LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                : [Colors.white, const Color(0xFFFAFAFA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1A1E2A), const Color(0xFF141824)]
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
                          color: const Color(0xFF22C55E).withOpacity(isDark ? 0.3 : 0.15),
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
                      right: 24,
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
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '/ $period',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
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

  Widget _buildCTAButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          // Handle subscription
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF22C55E) : const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue with $_selectedPlan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildTermsLinks(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text(
            'Terms',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text(
          ' • ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Privacy',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text(
          ' • ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Restore',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}