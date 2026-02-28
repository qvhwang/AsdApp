import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController {
  Future<UserModel?> getUserById(int id) async {
    try {
      return await UserService.getUserById(id);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> updateProfile({
    required int id,
    required String fullName,
  }) async {
    try {
      return await UserService.updateProfile(id: id, fullName: fullName);
    } catch (e) {
      return null;
    }
  }

  Future<String?> changePassword({
    required int id,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await UserService.changePassword(
        id: id,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
