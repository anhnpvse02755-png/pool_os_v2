import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/training/training_center_screen.dart';
import '../../presentation/screens/training/drill_list_screen.dart';
import '../../presentation/screens/training/drill_session_screen.dart';
import '../../presentation/screens/training/drill_result_screen.dart';
import '../../presentation/screens/play/play_screen.dart';
import '../../presentation/screens/session/session_list_screen.dart';
import '../../presentation/screens/session/create_session_screen.dart';
import '../../presentation/screens/coach/coach_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';

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
            builder: (context, state) => const AssessmentPlaceholder(),
          ),
          GoRoute(
            path: '/training/recommended',
            name: 'recommended',
            builder: (context, state) => const RecommendedPlaceholder(),
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
            path: '/training/history',
            name: 'trainingHistory',
            builder: (context, state) => const TrainingHistoryPlaceholder(),
          ),

          // Play (Match Recording)
          GoRoute(
            path: '/play',
            name: 'play',
            builder: (context, state) => const PlayScreen(),
          ),
          GoRoute(
            path: '/play/quick',
            name: 'quickMatch',
            builder: (context, state) => const QuickMatchPlaceholder(),
          ),
          GoRoute(
            path: '/play/friendly',
            name: 'friendlyMatch',
            builder: (context, state) => const FriendlyMatchPlaceholder(),
          ),
          GoRoute(
            path: '/play/recording',
            name: 'matchRecording',
            builder: (context, state) => const MatchRecordingPlaceholder(),
          ),
          GoRoute(
            path: '/play/history',
            name: 'matchHistory',
            builder: (context, state) => const MatchHistoryPlaceholder(),
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

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainBottomNav(),
    );
  }
}

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/training')) return 1;
    if (location.startsWith('/play')) return 2;
    if (location.startsWith('/coach')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.goNamed('home');
            break;
          case 1:
            context.goNamed('training');
            break;
          case 2:
            context.goNamed('play');
            break;
          case 3:
            context.goNamed('coach');
            break;
          case 4:
            context.goNamed('profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Tập',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_outlined),
          selectedIcon: Icon(Icons.sports),
          label: 'Chơi',
        ),
        NavigationDestination(
          icon: Icon(Icons.psychology_outlined),
          selectedIcon: Icon(Icons.psychology),
          label: 'Coach',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ],
    );
  }
}

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
