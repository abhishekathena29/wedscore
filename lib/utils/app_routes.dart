class AppRoutes {
  // Onboarding
  static const welcome = '/welcome';
  static const onboardingAuth = '/onboarding/auth';
  
  // Authentication
  static const login = '/auth/login';
  static const signup = '/auth/signup';
  
  // Profile Setup
  static const profileSetup = '/profile-setup';
  
  // Main App
  static const home = '/';
  static const checklist = '/checklist';
  static const vendors = '/vendors';
  static const gallery = '/gallery';

  static String routeForIndex(int index) {
    switch (index) {
      case 0:
        return home;
      case 1:
        return checklist;
      case 2:
        return vendors;
      case 3:
        return gallery;
      default:
        return home;
    }
  }
}
