import 'package:flutter/material.dart';
import 'package:oyeshi_des/config/onboarding/onboarding_model.dart';
import 'package:oyeshi_des/pages/pay_wall/hard_paywall.dart';

import '../../config/analytics/google_analytics.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  final OnboardingPayloadConfig config;
  final int currentIndex;

  const OnboardingQuestionScreen({
    super.key,
    required this.config,
    required this.currentIndex,
  });

  @override
  State<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  String? _selectedOptionId;
  double _backgroundOpacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _backgroundOpacity = 1);
    });
  }

  OnboardingQuestion get _currentQuestion =>
      widget.config.questions[widget.currentIndex];
  bool get _isFirstQuestion => widget.currentIndex == 0;
  bool get _isLastQuestion => widget.currentIndex == widget.config.total - 1;
  bool get _isFinalCTA => _currentQuestion.type == 'final_cta';

  void _onOptionSelected(String optionId) {
    setState(() {
      _selectedOptionId = optionId;
    });
  }

  void _handleBack() {
    Navigator.pop(context);
  }

  void _handleContinue() async {
    if (_isLastQuestion) {
     
      Map<String, Object> parameters = {
        'verdict': "onboarding_completed_successfully",
      };

      await analyticsService.logCustomEvent(
          name: "onboarding_completed", parameters: parameters);

      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        );
      }
    } else {
      // Navigate to next question
      String option = _currentQuestion.options
          .where((opt) => opt.id == _selectedOptionId)
          .first
          .text;
      Map<String, Object> parameters = {
        'question_id': _currentQuestion.text,
        'answer_id': option,
      };

      await analyticsService.logCustomEvent(
          name: "onboarding_inprogress", parameters: parameters);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingQuestionScreen(
            config: widget.config,
            currentIndex: widget.currentIndex + 1,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = (widget.currentIndex + 1) / widget.config.total;

    return AnimatedOpacity(
      opacity: _backgroundOpacity,
      duration: const Duration(milliseconds: 400),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Premium Header with Back Button & Progress
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Back Button - Hidden on first screen
                        if (!_isFirstQuestion)
                          GestureDetector(
                            onTap: _handleBack,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 40),

                        const Spacer(),

                        // Elegant Step Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF22C55E).withValues(alpha: 0.1),
                                const Color(0xFF22C55E).withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'STEP ${widget.currentIndex + 1}/${widget.config.total}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Refined Progress Bar
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 6,
                            backgroundColor: Colors.grey[100],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF22C55E),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: -18,
                          child: Text(
                            '${(progressValue * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question with Dynamic Icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _currentQuestion.text,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                _getQuestionIcon(),
                                color: const Color(0xFF22C55E),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Options or CTA
                        if (_isFinalCTA)
                          _buildFinalCTA()
                        else
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuad,
                            builder: (context, opacity, child) {
                              return Opacity(
                                opacity: opacity,
                                child: child,
                              );
                            },
                            child: Column(
                              children: _currentQuestion.options
                                  .map(
                                    (option) => _buildLuxuryOptionCard(
                                      option: option,
                                      isSelected:
                                          _selectedOptionId == option.id,
                                      onTap: () => _onOptionSelected(option.id),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Section with Next/CTA Button
              if (_isFinalCTA || _selectedOptionId != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: _isFinalCTA ? _buildCTAButton() : _buildNextButton(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getQuestionIcon() {
    switch (widget.currentIndex) {
      case 0:
        return Icons.shopping_cart_rounded;
      case 1:
        return Icons.delete_outline_rounded;
      case 2:
        return Icons.attach_money_rounded;
      case 3:
        return Icons.balance_rounded;
      case 4:
        return Icons.timer_rounded;
      case 5:
        return Icons.person_outline_rounded;
      case 6:
        return Icons.celebration_rounded;
      default:
        return Icons.restaurant_menu_rounded;
    }
  }

  Widget _buildLuxuryOptionCard({
    required QuestionOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF22C55E),
                        const Color(0xFF16A34A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey[200]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF22C55E).withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isSelected ? 20 : 10,
                  offset: Offset(0, isSelected ? 8 : 4),
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Custom Radio Indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey[400]!,
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFF22C55E),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Option Text
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
                // Decorative Element
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
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
              _isLastQuestion ? 'Finish' : 'Continue',
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
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isLastQuestion
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalCTA() {
    return Column(
      children: [
        // Hero illustration
        Container(
          width: 120,
          height: 120,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                const Color(0xFF22C55E).withValues(alpha: 0.2),
                const Color(0xFF22C55E).withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 48,
                color: Color(0xFF22C55E),
              ),
            ),
          ),
        ),

        // Summary text
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.celebration_rounded,
                color: Color(0xFF22C55E),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ve answered ${widget.config.total} questions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your personalized meal plan is ready',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // CTA Message
        Text(
          _currentQuestion.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
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
              _currentQuestion.buttonText ?? 'See My Plan',
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
