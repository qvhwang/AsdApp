const userService = require('../services/user.service');

exports.getProfile = async (req, res) => {
  try {
    const user = await userService.getById(req.user.id);
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { full_name } = req.body;

    if (!full_name || full_name.trim() === '') {
      return res.status(400).json({ message: 'Thiếu tên' });
    }

    const user = await userService.updateName(
      req.user.id,
      full_name.trim()
    );

    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { old_password, new_password } = req.body;

    if (!old_password || !new_password) {
      return res.status(400).json({ message: 'Thiếu dữ liệu' });
    }

    await userService.changePassword(
      req.user.id,
      old_password,
      new_password
    );

    res.json({ message: 'Đổi mật khẩu thành công' });

  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};