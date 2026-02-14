import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oyeshi_des/constants/fonts.dart';

class PaywallUtilityWidgets {

  static 
  Widget buildHeader(bool isDark) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF22C55E).withValues(alpha: 0.2),
                            const Color(0xFF16A34A).withValues(alpha: 0.1)
                          ]
                        : [
                            const Color(0xFF22C55E).withValues(alpha: 0.1),
                            const Color(0xFFDC2626).withValues(alpha: 0.05)
                          ],
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
                      color: isDark
                          ? const Color(0xFF22C55E)
                          : const Color.fromARGB(255, 226, 146, 17),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Oyishi Des',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: FontConstants.fontFamily,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF22C55E)
                            : const Color.fromARGB(255, 226, 146, 17),
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
  }


  static Widget buildTermsLinks(bool isDark) {
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
            ),
          ),
        ),
        Text(
          ' • ',
          style: TextStyle(
            fontSize: 13,
            fontFamily: FontConstants.fontFamily,
            fontWeight: FontWeight.w800,
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
            ),
          ),
        ),
      ],
    );
  }


  static Widget buildCTAButton(bool isDark, String _selectedPlan) {
  return SizedBox(
    width: 300,
    height: 60,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF22C55E).withValues(alpha:0.9),
                  const Color(0xFF059669),
                  const Color(0xFF047857),
                ]
              : [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF22C55E).withValues(alpha:0.3)
                : const Color(0xFF0F172A).withValues(alpha:0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark
                ? const Color(0xFF22C55E).withValues(alpha:0.15)
                : Colors.white.withValues(alpha:0.2),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Stack(
          children: [
            // Glass morphism effect
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha:0.5),
                        Colors.white.withValues(alpha:0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Inner glow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha:0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Button content
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start with $_selectedPlan',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: FontConstants.fontFamily,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.25),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha:0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
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
}
}