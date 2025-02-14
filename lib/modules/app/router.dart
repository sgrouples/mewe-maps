import 'package:go_router/go_router.dart';
import 'package:mewe_maps/modules/launch/view/launch_page.dart';
import 'package:mewe_maps/modules/login/view/login_page.dart';
import 'package:mewe_maps/modules/map/view/map_page.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LaunchPage(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
