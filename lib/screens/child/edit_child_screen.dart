import 'package:flutter/material.dart';

import '../../controllers/child_controller.dart';
import '../../models/child_model.dart';
import '../../utils/utils.dart';

class EditChildModal extends StatefulWidget {
  final ChildModel child;

  const EditChildModal({Key? key, required this.child}) : super(key: key);

  @override
  State<EditChildModal> createState() => _EditChildModalState();
}

class _EditChildModalState extends State<EditChildModal> {
  final ChildController _controller = ChildController();

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final guardianController = TextEditingController();

  DateTime? selectedBirthDate;

  bool nameError = false;
  bool dobError = false;
  bool guardianError = false;

  String gender = 'Male';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.child.fullName;
    guardianController.text = widget.child.guardianName ?? '';

    final raw = widget.child.birthDate;
    if (raw != null && raw.isNotEmpty) {
      final datePart = raw.split('T').first;
      final parts = datePart.split('-');
      if (parts.length == 3) {
        selectedBirthDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        dobController.text = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    final g = widget.child.gender?.toLowerCase() ?? '';
    gender = (g == 'female' || g == 'nữ' || g == 'nu') ? 'Female' : 'Male';
  }

  Future<void> _update() async {
    setState(() {
      nameError = nameController.text.isEmpty;
      dobError = selectedBirthDate == null;
      guardianError = guardianController.text.isEmpty;
    });

    if (nameError || dobError || guardianError) {
      showToast(context, 'Vui lòng nhập đầy đủ thông tin', success: false);
      return;
    }

    final birthDateForApi =
        '${selectedBirthDate!.year}-'
        '${selectedBirthDate!.month.toString().padLeft(2, '0')}-'
        '${selectedBirthDate!.day.toString().padLeft(2, '0')}';

    setState(() => isLoading = true);

    final success = await _controller.updateChild(
      id: widget.child.id,
      fullName: nameController.text.trim(),
      gender: gender,
      birthDate: birthDateForApi,
      guardianName: guardianController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      showToast(context, '✅ Cập nhật hồ sơ thành công');
      Navigator.pop(context, true);
    } else {
      showToast(context, '❌ Cập nhật hồ sơ thất bại', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chỉnh sửa hồ sơ trẻ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Họ tên',
                errorText: nameError ? 'Không được để trống' : null,
              ),
            ),

            TextField(
              controller: dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Ngày sinh',
                errorText: dobError ? 'Vui lòng chọn ngày sinh' : null,
                suffixIcon: const Icon(Icons.calendar_month),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedBirthDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedBirthDate = picked;
                    dobController.text =
                        '${picked.day.toString().padLeft(2, '0')}-'
                        '${picked.month.toString().padLeft(2, '0')}-'
                        '${picked.year}';
                  });
                }
              },
            ),

            TextField(
              controller: guardianController,
              decoration: InputDecoration(
                labelText: 'Người giám hộ',
                errorText: guardianError ? 'Không được để trống' : null,
              ),
            ),

            DropdownButton<String>(
              value: gender,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Nam')),
                DropdownMenuItem(value: 'Female', child: Text('Nữ')),
              ],
              onChanged: (v) => setState(() => gender = v!),
            ),

            const SizedBox(height: 12),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _update,
                    child: const Text('Lưu thay đổi'),
                  ),
          ],
        ),
      ),
    );
  }
}
