enum AppRole { weddingPlanner, client }

extension AppRoleX on AppRole {
  String get storageValue {
    switch (this) {
      case AppRole.weddingPlanner:
        return 'wedding_planner';
      case AppRole.client:
        return 'client';
    }
  }

  String get label {
    switch (this) {
      case AppRole.weddingPlanner:
        return 'Wedding Planner';
      case AppRole.client:
        return 'Client';
    }
  }

  String get shortLabel {
    switch (this) {
      case AppRole.weddingPlanner:
        return 'Planner';
      case AppRole.client:
        return 'Client';
    }
  }
}

AppRole appRoleFromStorage(String? value) {
  switch (value) {
    case 'planner':
    case 'wedding_planner':
      return AppRole.weddingPlanner;
    case 'couple':
    case 'family':
    case 'client':
    default:
      return AppRole.client;
  }
}
