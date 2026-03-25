import 'package:flutter_test/flutter_test.dart';
import 'package:wedscore/models/app_role.dart';

void main() {
  test('planner and client roles map to stable labels', () {
    expect(appRoleFromStorage('wedding_planner'), AppRole.weddingPlanner);
    expect(appRoleFromStorage('planner'), AppRole.weddingPlanner);
    expect(appRoleFromStorage('client'), AppRole.client);
    expect(appRoleFromStorage('couple'), AppRole.client);

    expect(AppRole.weddingPlanner.label, 'Wedding Planner');
    expect(AppRole.client.label, 'Client');
  });
}
