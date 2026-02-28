const userModel = require('../models/user.model');
const { hashPassword } = require('../utils/password.util');

exports.getAllUsers = async (req, res) => {
  try {
    const users = await userModel.getAllUsers();
    res.json(users);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.toggleStatus = async (req, res) => {
  const { id, status } = req.body;
  try {
    await userModel.updateStatus(id, status === 1 ? 0 : 1);
    res.json({ message: 'OK' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.changeRole = async (req, res) => {
  const { id, role } = req.body;
  const newRole = role === 'ADMIN' ? 'USER' : 'ADMIN';
  try {
    await userModel.updateRole(id, newRole);
    res.json({ message: 'OK' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.updateUser = async (req, res) => {
  const { id } = req.params;
  const { full_name, email, role, status } = req.body;

  if (!full_name || !email || !role) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }

  try {
    await userModel.updateUser(id, { full_name, email, role, status });
    res.json({ message: 'Cập nhật thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.deleteUser = async (req, res) => {
  try {
    const user = await userModel.getById(req.params.id);
    if (!user) return res.status(404).json({ message: 'Không tìm thấy tài khoản' });
    if (user.role === 'ADMIN') {
      return res.status(403).json({ message: 'Không thể xóa tài khoản ADMIN. Vui lòng đổi role trước.' });
    }
    await userModel.deleteUser(req.params.id);
    res.json({ message: 'Đã xóa' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.createUser = async (req, res) => {
  const { full_name, email, password, role } = req.body;

  if (!full_name || !email || !password) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }

  try {
    const hashed = await hashPassword(password);
    await userModel.createUser(full_name, email, hashed, role || 'USER');
    res.json({ message: 'Tạo user thành công' });
  } catch (err) {
    console.error(err);
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ message: 'Email đã tồn tại' });
    }
    res.status(500).json({ message: 'Lỗi server' });
  }
};