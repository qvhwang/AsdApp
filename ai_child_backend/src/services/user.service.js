const bcrypt = require('bcryptjs');
const userModel = require('../models/user.model');

exports.getById = async (id) => {
  return await userModel.getById(id);
};

exports.updateName = async (id, full_name) => {
  await userModel.updateName(id, full_name);
  return await userModel.getById(id);
};

exports.changePassword = async (id, old_password, new_password) => {
  const user = await userModel.getFullUserById(id);

  if (!user) {
    throw new Error('User không tồn tại');
  }

  const isMatch = await bcrypt.compare(
    old_password,
    user.password
  );

  if (!isMatch) {
    throw new Error('Mật khẩu cũ không đúng');
  }

  const hashedPassword = await bcrypt.hash(new_password, 10);

  await userModel.updatePassword(id, hashedPassword);
};