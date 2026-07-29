import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/controller/presentation/controller_screen.dart';
import '../../features/controller/presentation/robot_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/controller',
      builder: (context, state) => const ControllerScreen(),
    ),
    GoRoute(
      path: '/robot',
      builder: (context, state) => const RobotScreen(),
    ),
  ],
);