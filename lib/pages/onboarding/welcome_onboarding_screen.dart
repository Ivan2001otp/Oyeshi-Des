import 'package:flutter/material.dart';
import 'package:oyeshi_des/config/analytics/google_analytics.dart';
import 'package:oyeshi_des/constants/fonts.dart';
import 'package:oyeshi_des/pages/onboarding/onboarding_question_screen.dart';

import '../../config/onboarding/remote_config.dart';

class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top dec

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Animated leaf icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    const Color.fromARGB(255, 197, 156, 34)
                                        .withValues(alpha: 0.2),
                                    const Color.fromARGB(255, 197, 156, 34)
                                        .withValues(alpha: 0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 197, 156, 34)
                                          .withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                /*child: const Icon(
                                  // give my app logo
                                  Icons.eco_rounded,
                                  size: 64,
                                  color: Color(0xFF22C55E),
                                ),*/
                                child: Image.asset(
                                  "assets/app_logo/playstore.png",
                                  scale: 2,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),
                    /*
                      // Welcome title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOut,
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: const Text(
                              'Oyishi Des',
                              style: TextStyle(
                                fontSize: 36,
                                fontFamily: FontConstants.fontFamily,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      */
                      // Tagline
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                'Save food  •  Save money',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: FontConstants.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 48),

                      // Stats cards
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeIn,
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  icon:
                                      "assets/images/icons/save_food_icon.png",
                                  value: 'Food Saved',
                                  label: '30%',
                                  color: Colors.orange,
                                  trailingText: '+15%',
                                ),
                                _buildStatCard(
                                    icon:
                                        "assets/images/icons/save_money_icon.png",
                                    value: "Money Saved",
                                    label: '\$1,600',
                                    color: const Color(0xFF22C55E),
                                    trailingText: '+\$500'),
                                _buildStatCard(
                                  icon:
                                      "assets/images/icons/meals_shared_icon.png",
                                  value: 'Meals Shared',
                                  label: '2M+',
                                  color: Colors.blue,
                                  trailingText: '500K+',
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom button
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
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => _startOnboarding(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🫶 Let\'s go',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: FontConstants.fontFamily,
                            fontWeight: FontWeight.w900,
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
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
    required String trailingText,
  }) {
    return Card(
      elevation: 4,
      color: Colors.grey[50],
      shadowColor: Colors.black54,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          spacing: 8,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 40,
              height: 40,
              child: Image.asset(
                icon,
                width: 10,
                height: 10,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: FontConstants.fontFamily,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: FontConstants.fontFamily,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailingText,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: FontConstants.fontFamily,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startOnboarding(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF22C55E),
        ),
      ),
    );

    // Load config
    final remoteConfigService = RemoteConfigService();
    final config = await remoteConfigService.getOnboardingConfig();

    if (!context.mounted) return;

    // Pop loading dialog
    Navigator.pop(context);

    // Navigate to onboarding
    if (config != null && config.onboarding_config.active) {
      Map<String, Object> parameters = {
        'onboarding_step': 'start',
      };

      await analyticsService.logCustomEvent(
          name: "onboarding_started", parameters: parameters);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingQuestionScreen(
            config: config.onboarding_config,
            currentIndex: 0,
          ),
        ),
      );
    } else {
      // Handle error - show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to load onboarding. Please try again.'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
