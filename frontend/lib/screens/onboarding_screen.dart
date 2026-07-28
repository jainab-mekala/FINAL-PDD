import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Neural Risk Analytics',
      description:
          'Experience clinical precision with our multi-layer neural network trained on over 50,000 implant cases.',
      icon: Icons.psychology_rounded,
      accentColor: const Color(0xFF00F0FF),
    ),
    OnboardingData(
      title: 'Real-time Surveillance',
      description:
          'Autonomous monitoring system that alerts you at the first sign of peri-implant pathology.',
      icon: Icons.biotech_rounded,
      accentColor: const Color(0xFF00FF9F),
    ),
    OnboardingData(
      title: 'Enterprise Security',
      description:
          'HIPAA-compliant data architecture ensures patient confidentiality through end-to-end encryption.',
      icon: Icons.shield_rounded,
      accentColor: const Color(0xFFB388FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'v2.4.0-STABLE',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: () => context.go('/auth/login'),
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0284C7),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) =>
                      OnboardingPage(data: _pages[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentPage == index ? 32 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFF0284C7)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    GradientButton(
                      text: _currentPage == _pages.length - 1
                          ? 'AUTHORIZE ACCESS'
                          : 'PROCEED',
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          context.go('/auth/login');
                        }
                      },
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

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF0284C7).withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withOpacity(0.12),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Icon(data.icon, size: 72, color: const Color(0xFF0284C7)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: const Color(0xFF475569),
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
