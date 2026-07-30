// ============================================================================
// SARTHEE AI — ROUTE NAMES
// ============================================================================
//
// Central source of truth for every named route in Sarthee AI.
//
// Route names are intentionally independent from URL paths.
//
// WHY:
// • Paths can change without breaking navigation calls.
// • Named navigation remains readable.
// • Deep links stay separate from application navigation.
// • Refactoring becomes safer.
// • Analytics can identify screens consistently.
// • Tests can reference stable route identifiers.
//
// USAGE:
//
// context.goNamed(RouteNames.home);
//
// context.pushNamed(
//   RouteNames.destinationDetails,
//   pathParameters: {
//     'destinationId': destinationId,
//   },
// );
//
// IMPORTANT:
// Never hard-code route names inside feature widgets.
// ============================================================================

abstract final class RouteNames {
  RouteNames._();

  // ==========================================================================
  // ROOT
  // ==========================================================================

  static const String root = 'root';

  // ==========================================================================
  // STARTUP
  // ==========================================================================

  static const String splash = 'splash';

  static const String onboarding = 'onboarding';

  // ==========================================================================
  // AUTHENTICATION
  // ==========================================================================

  static const String login = 'login';

  static const String signup = 'signup';

  static const String register = 'register';

  static const String forgotPassword = 'forgotPassword';

  static const String verifyOtp = 'verifyOtp';

  static const String resetPassword = 'resetPassword';

  // ==========================================================================
  // MAIN APPLICATION
  // ==========================================================================

  static const String home = 'home';

  // ==========================================================================
  // AI ASSISTANT
  // ==========================================================================

  static const String aiChat = 'aiChat';

  static const String aiChatSession = 'aiChatSession';

  // ==========================================================================
  // DESTINATIONS
  // ==========================================================================

  static const String destinations = 'destinations';

  static const String destinationDetails = 'destinationDetails';

  // ==========================================================================
  // CULTURE
  // ==========================================================================

  static const String culture = 'culture';

  static const String cultureDetails = 'cultureDetails';

  // ==========================================================================
  // FOOD
  // ==========================================================================

  static const String food = 'food';

  static const String foodDetails = 'foodDetails';

  // ==========================================================================
  // HOTELS
  // ==========================================================================

  static const String hotels = 'hotels';

  static const String hotelDetails = 'hotelDetails';

  // ==========================================================================
  // TRIP PLANNER
  // ==========================================================================

  static const String tripPlanner = 'tripPlanner';

  static const String tripDetails = 'tripDetails';

  static const String tripEdit = 'tripEdit';

  // ==========================================================================
  // NAVIGATION
  // ==========================================================================

  static const String navigation = 'navigation';

  static const String activeNavigation = 'activeNavigation';

  // ==========================================================================
  // WEATHER
  // ==========================================================================

  static const String weather = 'weather';

  // ==========================================================================
  // USER
  // ==========================================================================

  static const String favorites = 'favorites';

  static const String history = 'history';

  static const String notifications = 'notifications';

  static const String profile = 'profile';

  static const String editProfile = 'editProfile';

  static const String profileSetup = 'profileSetup';

  static const String completeProfile = 'completeProfile';

  static const String privacyCenter = 'privacyCenter';

  static const String safetyCenter = 'safetyCenter';

  // ==========================================================================
  // SETTINGS
  // ==========================================================================

  static const String settings = 'settings';

  static const String appearanceSettings = 'appearanceSettings';

  static const String languageSettings = 'languageSettings';

  static const String privacySettings = 'privacySettings';

  static const String notificationSettings = 'notificationSettings';

  // ==========================================================================
  // SAFETY
  // ==========================================================================

  static const String safety = 'safety';

  static const String emergency = 'emergency';

  // ==========================================================================
  // BUDGET
  // ==========================================================================

  static const String budget = 'budget';

  static const String budgetDetails = 'budgetDetails';

  // ==========================================================================
  // SEARCH
  // ==========================================================================

  static const String search = 'search';

  // ==========================================================================
  // SYSTEM
  // ==========================================================================

  static const String offline = 'offline';

  static const String maintenance = 'maintenance';

  static const String updateRequired = 'updateRequired';

  static const String error = 'error';

  // ==========================================================================
  // GROUPS
  // ==========================================================================

  /// Routes used before the main application becomes available.
  static const Set<String> startupRoutes = <String>{root, splash, onboarding};

  /// Authentication-related route names.
  static const Set<String> authenticationRoutes = <String>{
    login,
    register,
    forgotPassword,
    verifyOtp,
    resetPassword,
  };

  /// Primary navigation destinations.
  static const Set<String> primaryRoutes = <String>{
    home,
    destinations,
    aiChat,
    tripPlanner,
    favorites,
    profile,
  };

  /// Routes associated with user account/settings.
  static const Set<String> accountRoutes = <String>{
    profile,
    editProfile,
    settings,
    appearanceSettings,
    languageSettings,
    privacySettings,
    notificationSettings,
  };

  /// Travel discovery features.
  static const Set<String> discoveryRoutes = <String>{
    destinations,
    destinationDetails,
    culture,
    cultureDetails,
    food,
    foodDetails,
    hotels,
    hotelDetails,
  };

  /// Travel utility features.
  static const Set<String> travelUtilityRoutes = <String>{
    tripPlanner,
    tripDetails,
    tripEdit,
    navigation,
    activeNavigation,
    weather,
    safety,
    emergency,
    budget,
    budgetDetails,
  };

  /// Special application-state routes.
  static const Set<String> systemRoutes = <String>{
    offline,
    maintenance,
    updateRequired,
    error,
  };

  // ==========================================================================
  // ALL REGISTERED NAMES
  // ==========================================================================

  /// Complete registry of Sarthee AI named routes.
  ///
  /// Useful for:
  /// • Router validation
  /// • Debugging
  /// • Automated tests
  /// • Analytics filtering
  /// • Development assertions
  static const Set<String> all = <String>{
    root,

    // Startup
    splash,
    onboarding,

    // Authentication
    login,
    register,
    forgotPassword,
    verifyOtp,
    resetPassword,

    // Main
    home,

    // AI
    aiChat,
    aiChatSession,

    // Discovery
    destinations,
    destinationDetails,
    culture,
    cultureDetails,
    food,
    foodDetails,
    hotels,
    hotelDetails,

    // Planning / Navigation
    tripPlanner,
    tripDetails,
    tripEdit,
    navigation,
    activeNavigation,
    weather,

    // User
    favorites,
    history,
    notifications,
    profile,
    editProfile,
    profileSetup,

    // Settings
    settings,
    appearanceSettings,
    languageSettings,
    privacySettings,
    notificationSettings,

    // Safety
    safety,
    emergency,

    // Budget
    budget,
    budgetDetails,

    // Search
    search,

    // System
    offline,
    maintenance,
    updateRequired,
    error,
  };

  // ==========================================================================
  // VALIDATION HELPERS
  // ==========================================================================

  static bool exists(String? routeName) {
    if (routeName == null || routeName.isEmpty) {
      return false;
    }

    return all.contains(routeName);
  }

  static bool isStartupRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    return startupRoutes.contains(routeName);
  }

  static bool isAuthenticationRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    return authenticationRoutes.contains(routeName);
  }

  static bool isPrimaryRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    return primaryRoutes.contains(routeName);
  }

  static bool isAccountRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    return accountRoutes.contains(routeName);
  }

  static bool isDiscoveryRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    return discoveryRoutes.contains(routeName);
  }

  static bool isTravelUtilityRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    return travelUtilityRoutes.contains(routeName);
  }

  static bool isSystemRoute(String? routeName) {
    if (routeName == null) {
      return false;
    }

    return systemRoutes.contains(routeName);
  }
}
