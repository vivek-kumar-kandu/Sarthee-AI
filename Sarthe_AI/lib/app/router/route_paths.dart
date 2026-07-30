// ============================================================================
// SARTHEE AI — ROUTE PATHS
// ============================================================================
//
// Central source of truth for every URL/path used by Sarthee AI.
//
// RULES:
// - Never hard-code route paths inside widgets.
// - Use [RoutePaths] everywhere.
// - Route names belong in `route_names.dart`.
// - Dynamic route helpers belong here.
// - Query parameters should NOT be manually concatenated here.
//
// This structure supports:
// - Deep links
// - Nested routes
// - Dynamic parameters
// - Web URLs
// - Authentication
// - Onboarding
// - Future feature expansion
// ============================================================================

abstract final class RoutePaths {
  RoutePaths._();

  // ==========================================================================
  // ROOT
  // ==========================================================================

  static const String root = '/';

  // ==========================================================================
  // STARTUP
  // ==========================================================================

  static const String splash = '/splash';

  static const String onboarding = '/onboarding';

  // ==========================================================================
  // AUTHENTICATION
  // ==========================================================================

  static const String login = '/login';

  static const String signup = '/signup';

  static const String register = '/register';

  static const String forgotPassword = '/forgot-password';

  static const String verifyOtp = '/verify-otp';

  static const String resetPassword = '/reset-password';

  // ==========================================================================
  // MAIN APPLICATION
  // ==========================================================================

  static const String home = '/home';

  static const String explore = '/destinations';

  static const String trips = '/trip-planner';

  static const String ai = '/ai-chat';

  // ==========================================================================
  // AI ASSISTANT
  // ==========================================================================

  static const String aiChat = '/ai-chat';

  static const String aiChatSession = '/ai-chat/:sessionId';

  static String aiChatSessionPath(String sessionId) {
    return '/ai-chat/$sessionId';
  }

  // ==========================================================================
  // DESTINATIONS
  // ==========================================================================

  static const String destinations = '/destinations';

  static const String destinationDetails = '/destinations/:destinationId';

  static String destinationDetailsPath(String destinationId) {
    return '/destinations/$destinationId';
  }

  // ==========================================================================
  // CULTURE
  // ==========================================================================

  static const String culture = '/culture';

  static const String cultureDetails = '/culture/:cultureId';

  static String cultureDetailsPath(String cultureId) {
    return '/culture/$cultureId';
  }

  // ==========================================================================
  // FOOD
  // ==========================================================================

  static const String food = '/food';

  static const String foodDetails = '/food/:foodId';

  static String foodDetailsPath(String foodId) {
    return '/food/$foodId';
  }

  // ==========================================================================
  // HOTELS
  // ==========================================================================

  static const String hotels = '/hotels';

  static const String hotelDetails = '/hotels/:hotelId';

  static String hotelDetailsPath(String hotelId) {
    return '/hotels/$hotelId';
  }

  // ==========================================================================
  // TRIP PLANNER
  // ==========================================================================

  static const String tripPlanner = '/trip-planner';

  static const String tripDetails = '/trip-planner/:tripId';

  static const String tripEdit = '/trip-planner/:tripId/edit';

  static String tripDetailsPath(String tripId) {
    return '/trip-planner/$tripId';
  }

  static String tripEditPath(String tripId) {
    return '/trip-planner/$tripId/edit';
  }

  // ==========================================================================
  // NAVIGATION
  // ==========================================================================

  static const String navigation = '/navigation';

  static const String activeNavigation = '/navigation/:navigationId';

  static String activeNavigationPath(String navigationId) {
    return '/navigation/$navigationId';
  }

  // ==========================================================================
  // WEATHER
  // ==========================================================================

  static const String weather = '/weather';

  // ==========================================================================
  // USER
  // ==========================================================================

  static const String favorites = '/favorites';

  static const String history = '/history';

  static const String notifications = '/notifications';

  static const String profile = '/profile';

  static const String editProfile = '/profile/edit';

  static const String profileSetup = '/profile/setup';

  static const String completeProfile = '/profile/complete';

  static const String privacyCenter = '/profile/privacy';

  static const String safetyCenter = '/profile/safety';

  static const String settings = '/settings';

  // ==========================================================================
  // SETTINGS
  // ==========================================================================

  static const String appearanceSettings = '/settings/appearance';

  static const String languageSettings = '/settings/language';

  static const String privacySettings = '/settings/privacy';

  static const String notificationSettings = '/settings/notifications';

  // ==========================================================================
  // SAFETY
  // ==========================================================================

  static const String safety = '/safety';

  static const String emergency = '/safety/emergency';

  // ==========================================================================
  // BUDGET
  // ==========================================================================

  static const String budget = '/budget';

  static const String budgetDetails = '/budget/:budgetId';

  static String budgetDetailsPath(String budgetId) {
    return '/budget/$budgetId';
  }

  // ==========================================================================
  // SEARCH
  // ==========================================================================

  static const String search = '/search';

  // ==========================================================================
  // OFFLINE
  // ==========================================================================

  static const String offline = '/offline';

  // ==========================================================================
  // SYSTEM / FALLBACK
  // ==========================================================================

  static const String maintenance = '/maintenance';

  static const String updateRequired = '/update-required';

  static const String error = '/error';

  // ==========================================================================
  // ROUTE CLASSIFICATION
  // ==========================================================================

  /// Routes accessible without authentication.
  static const Set<String> publicRoutes = <String>{
    root,
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
    verifyOtp,
    resetPassword,
    maintenance,
    updateRequired,
    offline,
    error,
  };

  /// Routes specifically related to authentication.
  static const Set<String> authenticationRoutes = <String>{
    login,
    register,
    forgotPassword,
    verifyOtp,
    resetPassword,
  };

  /// Routes used before entering the primary application.
  static const Set<String> startupRoutes = <String>{root, splash, onboarding};

  /// Routes representing special system states.
  static const Set<String> systemRoutes = <String>{
    maintenance,
    updateRequired,
    offline,
    error,
  };

  // ==========================================================================
  // ROUTE HELPERS
  // ==========================================================================

  /// Returns true when [location] belongs to a public route.
  ///
  /// Handles query parameters and fragments safely.
  static bool isPublicRoute(String location) {
    final path = _normalizedPath(location);

    return publicRoutes.contains(path);
  }

  /// Returns true when [location] is an authentication route.
  static bool isAuthenticationRoute(String location) {
    final path = _normalizedPath(location);

    return authenticationRoutes.contains(path);
  }

  /// Returns true when [location] belongs to startup flow.
  static bool isStartupRoute(String location) {
    final path = _normalizedPath(location);

    return startupRoutes.contains(path);
  }

  /// Returns true when [location] represents a system route.
  static bool isSystemRoute(String location) {
    final path = _normalizedPath(location);

    return systemRoutes.contains(path);
  }

  /// Determines whether a location represents the main application.
  ///
  /// Dynamic child routes such as:
  ///
  /// `/destinations/123`
  ///
  /// are also considered application routes.
  static bool isApplicationRoute(String location) {
    final path = _normalizedPath(location);

    if (isPublicRoute(path)) {
      return false;
    }

    return path.startsWith('/');
  }

  // ==========================================================================
  // INTERNAL HELPERS
  // ==========================================================================

  static String _normalizedPath(String location) {
    if (location.isEmpty) {
      return root;
    }

    try {
      final uri = Uri.parse(location);

      if (uri.path.isEmpty) {
        return root;
      }

      return uri.path;
    } catch (_) {
      return location;
    }
  }
}
