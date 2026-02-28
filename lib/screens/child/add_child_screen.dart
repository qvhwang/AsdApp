import 'package:flutter/material.dart';

import '../../controllers/child_controller.dart';
import '../../utils/utils.dart';

class AddChildModal extends StatefulWidget {
  final int userId;

  const AddChildModal({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddChildModal> createState() => _AddChildModalState();
}

class _AddChildModalState extends State<AddChildModal> {
  final ChildController _controller = ChildController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController guardianController = TextEditingController();

  bool nameError = false;
  bool dobError = false;
  bool guardianError = false;

  String gender = 'Male';
  bool isLoading = false;
  DateTime? selectedBirthDate;

  Future<void> _submit() async {
    setState(() {
      nameError = nameController.text.isEmpty;
      dobError = selectedBirthDate == null;
      guardianError = guardianController.text.isEmpty;
    });

    if (nameError || dobError || guardianError) {
      showToast(context, 'Vui lòng nhập đầy đủ thông tin', success: false);
      return;
    }

    setState(() => isLoading = true);

    final birthDateForApi =
        '${selectedBirthDate!.year}-'
        '${selectedBirthDate!.month.toString().padLeft(2, '0')}-'
        '${selectedBirthDate!.day.toString().padLeft(2, '0')}';

    final success = await _controller.addChild(
      userId: widget.userId,
      fullName: nameController.text.trim(),
      gender: gender,
      birthDate: birthDateForApi,
      guardianName: guardianController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      showToast(context, '🎉 Thêm hồ sơ trẻ thành công');
      Navigator.pop(context, true);
    } else {
      showToast(context, '❌ Không thể thêm hồ sơ trẻ', success: false);
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
              'Thêm hồ sơ trẻ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Họ tên trẻ',
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
                : ElevatedButton(onPressed: _submit, child: const Text('Thêm')),
          ],
        ),
      ),
    );
  }
}
