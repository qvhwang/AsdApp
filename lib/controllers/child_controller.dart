import '../services/child_service.dart';

class ChildController {
  Future<bool> addChild({
    required int userId,
    required String fullName,
    required String gender,
    required String birthDate,
    required String guardianName,
  }) async {
    try {
      await ChildService.createChild(
        userId: userId,
        fullName: fullName,
        gender: gender,
        birthDate: birthDate,
        guardianName: guardianName,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateChild({
    required int id,
    required String fullName,
    required String gender,
    required String birthDate,
    required String guardianName,
  }) async {
    try {
      await ChildService.updateChild(
        id: id,
        fullName: fullName,
        gender: gender,
        birthDate: birthDate,
        guardianName: guardianName,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteChild(int childId) async {
    try {
      await ChildService.deleteChild(childId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
