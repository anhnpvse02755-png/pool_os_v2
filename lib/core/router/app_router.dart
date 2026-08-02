import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/interest_selection_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/home/notification_screen.dart';
import '../../presentation/screens/training/training_center_screen.dart';
import '../../presentation/screens/training/drill_list_screen.dart';
import '../../presentation/screens/training/drill_detail_screen.dart';
import '../../presentation/screens/training/drill_session_screen.dart';
import '../../presentation/screens/training/learning_path_screen.dart';
import '../../presentation/screens/training/knowledge_screen.dart';
import '../../presentation/screens/training/knowledge_detail_screen.dart';
import '../../presentation/screens/training/certification_list_screen.dart';
import '../../presentation/screens/training/certification_detail_screen.dart';
import '../../presentation/screens/play/match_recording_screen.dart';
import '../../presentation/screens/play/match_history_screen.dart';
import '../../presentation/screens/training/training_history_screen.dart';
import '../../presentation/screens/training/recommended_screen.dart';
import '../../presentation/screens/training/progress_screen.dart';
import '../../presentation/screens/coach/analysis_screen.dart';
import '../../presentation/screens/play/tournament_list_screen.dart';
import '../../presentation/screens/play/tournament_detail_screen.dart';
import '../../presentation/screens/play/vision_recording_screen.dart';
import '../../presentation/screens/training/drill_result_screen.dart';
import '../../presentation/screens/play/play_screen.dart';
import '../../presentation/screens/play/quick_match_screen.dart';
import '../../presentation/screens/play/friendly_match_screen.dart';
import '../../presentation/screens/session/session_list_screen.dart';
import '../../presentation/screens/session/create_session_screen.dart';
import '../../presentation/screens/training/assessment_screen.dart';
import '../../presentation/screens/coach/coach_screen.dart';
import '../../presentation/screens/coach/training_plan_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/equipment_screen.dart';
import '../../presentation/screens/community/community_screen.dart';
import '../../presentation/screens/shell/main_shell.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      // Onboarding Flow
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/interests',
        name: 'interests',
        builder: (context, state) => const InterestSelectionScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Notification
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // Main App (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Training Center
          GoRoute(
            path: '/training',
            name: 'training',
            builder: (context, state) => const TrainingCenterScreen(),
          ),
          GoRoute(
            path: '/training/assessment',
            name: 'assessment',
            builder: (context, state) => const AssessmentScreen(),
          ),
          GoRoute(
            path: '/training/recommended',
            name: 'recommended',
            builder: (context, state) => const RecommendedScreen(),
          ),
          GoRoute(
            path: '/training/drills',
            name: 'drillCategories',
            builder: (context, state) => const DrillCategoriesScreen(),
          ),
          GoRoute(
            path: '/training/drills/:categoryId',
            name: 'drillList',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              return DrillListScreen(categoryId: categoryId);
            },
          ),
          GoRoute(
            path: '/training/drill/:drillCode',
            name: 'drillDetail',
            builder: (context, state) {
              final drillCode = state.pathParameters['drillCode']!;
              return DrillDetailScreen(drillCode: drillCode);
            },
          ),
          GoRoute(
            path: '/training/path',
            name: 'learningPath',
            builder: (context, state) => const LearningPathScreen(),
          ),
          GoRoute(
            path: '/training/knowledge',
            name: 'knowledgeList',
            builder: (context, state) => const KnowledgeScreen(),
          ),
          GoRoute(
            path: '/training/knowledge/:slug',
            name: 'knowledgeDetail',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return KnowledgeDetailScreen(slug: slug);
            },
          ),
          GoRoute(
            path: '/training/certification',
            name: 'certificationList',
            builder: (context, state) => const CertificationListScreen(),
          ),
          GoRoute(
            path: '/training/certification/:certId',
            name: 'certificationDetail',
            builder: (context, state) {
              final certId = state.pathParameters['certId']!;
              return CertificationDetailScreen(certificationId: certId);
            },
          ),
          GoRoute(
            path: '/play/recording',
            name: 'matchRecording',
            builder: (context, state) => const MatchRecordingScreen(),
          ),
          GoRoute(
            path: '/play/history',
            name: 'matchHistory',
            builder: (context, state) => const MatchHistoryScreen(),
          ),
          GoRoute(
            path: '/training/history',
            name: 'trainingHistory',
            builder: (context, state) => const TrainingHistoryScreen(),
          ),
          GoRoute(
            path: '/training/session/new',
            name: 'newDrillSession',
            builder: (context, state) {
              final drillCode = state.uri.queryParameters['drill'] ?? 'STRAIGHT_POT';
              return DrillSessionScreen(drillCode: drillCode);
            },
          ),
          GoRoute(
            path: '/training/session/active',
            name: 'activeDrillSession',
            builder: (context, state) {
              // Default drill for daily training
              return const DrillSessionScreen(drillCode: 'DRAW_SHOT');
            },
          ),
          GoRoute(
            path: '/training/progress',
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/coach/analysis',
            name: 'analysis',
            builder: (context, state) => const AnalysisScreen(),
          ),
          GoRoute(
            path: '/coach/plan',
            name: 'trainingPlan',
            builder: (context, state) => const TrainingPlanScreen(),
          ),
          GoRoute(
            path: '/play/tournament',
            name: 'tournamentList',
            builder: (context, state) => const TournamentListScreen(),
          ),
          GoRoute(
            path: '/play/tournament/:tournamentId',
            name: 'tournamentDetail',
            builder: (context, state) {
              final id = state.pathParameters['tournamentId']!;
              return TournamentDetailScreen(tournamentId: id);
            },
          ),
          GoRoute(
            path: '/play/vision',
            name: 'visionRecording',
            builder: (context, state) => const VisionRecordingScreen(),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            builder: (context, state) => const CommunityScreen(),
          ),
          // Play
          GoRoute(
            path: '/play',
            name: 'play',
            builder: (context, state) => const PlayScreen(),
          ),
          GoRoute(
            path: '/play/quick',
            name: 'quickMatch',
            builder: (context, state) => const QuickMatchScreen(),
          ),
          GoRoute(
            path: '/play/friendly',
            name: 'friendlyMatch',
            builder: (context, state) => const FriendlyMatchScreen(),
          ),
          GoRoute(
            path: '/play/history',
            name: 'matchHistory',
            builder: (context, state) => const MatchHistoryScreen(),
          ),

          // Coach
          GoRoute(
            path: '/coach',
            name: 'coach',
            builder: (context, state) => const CoachScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/profile/equipment',
            name: 'equipment',
            builder: (context, state) => const EquipmentScreen(),
          ),
        ],
      ),

      // Full Screen Routes
      GoRoute(
        path: '/session/create',
        name: 'createSession',
        builder: (context, state) => const CreateSessionScreen(),
      ),
    ],
  );
});

// Placeholder screens for features not yet implemented
class AssessmentPlaceholder extends StatelessWidget {
  const AssessmentPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá kỹ năng')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Đánh giá kỹ năng', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class RecommendedPlaceholder extends StatelessWidget {
  const RecommendedPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI đề xuất')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('AI đề xuất bài tập', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class TrainingHistoryPlaceholder extends StatelessWidget {
  const TrainingHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử tập luyện')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Lịch sử tập luyện', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
