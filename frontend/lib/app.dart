import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:implantguard_ai/screens/splash_screen.dart';
import 'package:implantguard_ai/screens/onboarding_screen.dart';
import 'package:implantguard_ai/screens/diagnostic_wizard_screen.dart';
import 'package:implantguard_ai/screens/result_screen.dart';
import 'package:implantguard_ai/screens/auth/login_screen.dart';
import 'package:implantguard_ai/screens/auth/register_screen.dart';
import 'package:implantguard_ai/screens/dashboard/dashboard_screen.dart';
import 'package:implantguard_ai/screens/patients/patients_list_screen.dart';
import 'package:implantguard_ai/screens/patients/add_patient_screen.dart';
import 'package:implantguard_ai/screens/patients/patient_detail_screen.dart';
import 'package:implantguard_ai/screens/implants/add_implant_screen.dart';
import 'package:implantguard_ai/screens/implants/implant_detail_screen.dart';
import 'package:implantguard_ai/screens/monitoring/monitoring_screen.dart';
import 'package:implantguard_ai/screens/monitoring/add_assessment_screen.dart';
import 'package:implantguard_ai/screens/reports/reports_screen.dart';
import 'package:implantguard_ai/screens/reports/report_detail_screen.dart';
import 'package:implantguard_ai/screens/ai/ai_prediction_screen.dart';
import 'package:implantguard_ai/screens/public_analyzer_screen.dart';
import 'package:implantguard_ai/screens/settings/settings_screen.dart';
import 'package:implantguard_ai/screens/settings/profile_edit_screen.dart';
import 'package:implantguard_ai/screens/settings/terms_screen.dart';
import 'package:implantguard_ai/screens/settings/about_screen.dart';
import 'package:implantguard_ai/screens/settings/privacy_screen.dart';
import 'package:implantguard_ai/screens/settings/change_password_screen.dart';
import 'package:implantguard_ai/screens/settings/suggestions_screen.dart';
import 'package:implantguard_ai/models/prediction_result.dart';

class ImplantGuardApp extends ConsumerWidget {
  const ImplantGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: '/wizard', builder: (c, s) => const DiagnosticWizardScreen()),
        GoRoute(path: '/result', builder: (c, s) => ResultScreen(result: s.extra as PredictionResult)),
        
        // Auth
        GoRoute(path: '/auth/login', builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/auth/register', builder: (c, s) => const RegisterScreen()),
        
        // Dashboard
        GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
        
        // Patients
        GoRoute(path: '/patients', builder: (c, s) => const PatientsListScreen()),
        GoRoute(path: '/patients/add', builder: (c, s) => const AddPatientScreen()),
        GoRoute(path: '/patients/:id', builder: (c, s) => PatientDetailScreen(patientId: s.pathParameters['id']!)),
        
        // Implants
        GoRoute(path: '/implants/add', builder: (c, s) => AddImplantScreen(patientId: s.uri.queryParameters['patientId']!)),
        GoRoute(path: '/implants/:id', builder: (c, s) => ImplantDetailScreen(implantId: s.pathParameters['id']!)),
        
        // Monitoring & Reports
        GoRoute(path: '/monitoring', builder: (c, s) => const MonitoringScreen()),
        GoRoute(path: '/monitoring/add/:implantId', builder: (c, s) => AddAssessmentScreen(implantId: s.pathParameters['implantId']!)),
        GoRoute(path: '/reports', builder: (c, s) => const ReportsScreen()),
        GoRoute(
          path: '/reports/detail',
          builder: (c, s) => ReportDetailScreen(report: s.extra as Map<String, dynamic>),
        ),
        
        // AI
        GoRoute(path: '/ai-prediction/:implantId', builder: (c, s) => AIPredictionScreen(implantId: s.pathParameters['implantId']!)),
        GoRoute(path: '/public-analyzer', builder: (c, s) => const PublicAnalyzerScreen()),
        
        // Settings
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        GoRoute(path: '/settings/profile', builder: (c, s) => const ProfileEditScreen()),
        GoRoute(path: '/settings/terms', builder: (c, s) => const TermsScreen()),
        GoRoute(path: '/settings/about', builder: (c, s) => const AboutScreen()),
        GoRoute(path: '/settings/privacy', builder: (c, s) => const PrivacyScreen()),
        GoRoute(path: '/settings/change-password', builder: (c, s) => const ChangePasswordScreen()),
        GoRoute(path: '/suggestions', builder: (c, s) => const SuggestionsScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'ImplantGuard AI™',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAF7F2),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: const Color(0xFF26231F),
        displayColor: const Color(0xFF26231F),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD97757),
        secondary: Color(0xFFC15C3D),
        tertiary: Color(0xFFD97706),
        surface: Colors.white,
        onSurface: Color(0xFF26231F),
        onPrimary: Colors.white,
        error: Color(0xFFDC2626),
        surfaceContainerHighest: Color(0xFFF5F0E8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF26231F)),
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF26231F),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: const Color(0x0F26231F),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: const Color(0xFFE8E2D9), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E2D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E2D9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD97757), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6E6860), fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: Color(0xFFA39C93)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD97757),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0x3DD97757),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, letterSpacing: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
