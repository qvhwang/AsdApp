import '../models/user_model.dart';
import '../services/admin_user_service.dart';

class AdminUserController {
  Future<List<UserModel>> getUsers() async {
    try {
      return await AdminUserService.getUsers();
    } catch (e) {
      throw Exception('Không tải được danh sách user: $e');
    }
  }

  Future<void> toggleStatus(int id, int currentStatus) async {
    await AdminUserService.toggleStatus(id, currentStatus);
  }

  Future<void> changeRole(int id, String currentRole) async {
    await AdminUserService.changeRole(id, currentRole);
  }

  Future<void> deleteUser(int id) async {
    await AdminUserService.deleteUser(id);
  }

  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    await AdminUserService.createUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }

  Future<void> updateUser({
    required int id,
    required String fullName,
    required String email,
    required String role,
    required int status,
  }) async {
    await AdminUserService.updateUser(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      status: status,
    );
  }
}
