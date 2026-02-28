const db = require('../config/db');

exports.getById = async (id) => {
  const [rows] = await db.execute(
    'SELECT id, email, full_name, role, status FROM users WHERE id = ?',
    [id]
  );
  return rows[0];
};

exports.getFullUserById = async (id) => {
  const [rows] = await db.execute(
    'SELECT * FROM users WHERE id = ?',
    [id]
  );
  return rows[0];
};

exports.updateName = async (id, full_name) => {
  await db.execute(
    'UPDATE users SET full_name = ? WHERE id = ?',
    [full_name, id]
  );
};

exports.updatePassword = async (id, password) => {
  await db.execute(
    'UPDATE users SET password = ? WHERE id = ?',
    [password, id]
  );
};

exports.getAllUsers = async () => {
  const [rows] = await db.execute(
    'SELECT id, email, full_name, role, status, created_at FROM users ORDER BY id DESC'
  );
  return rows;
};

exports.updateStatus = async (id, status) => {
  await db.execute(
    'UPDATE users SET status = ? WHERE id = ?',
    [status, id]
  );
};

exports.updateRole = async (id, role) => {
  await db.execute(
    'UPDATE users SET role = ? WHERE id = ?',
    [role, id]
  );
};

exports.updateUser = async (id, data) => {
  const { full_name, email, role, status } = data;
  await db.execute(
    'UPDATE users SET full_name=?, email=?, role=?, status=? WHERE id=?',
    [full_name, email, role, status, id]
  );
};

exports.deleteUser = async (id) => {
  await db.execute(
    `DELETE a FROM mchat_answers a
     JOIN mchat_sessions s ON a.session_id = s.id
     WHERE s.user_id = ?`,
    [id]
  );
  await db.execute("DELETE FROM mchat_sessions WHERE user_id = ?", [id]);
  await db.execute("DELETE FROM children WHERE user_id = ?", [id]);
  await db.execute("DELETE FROM users WHERE id = ?", [id]);
};

exports.createUser = async (full_name, email, password, role) => {
  await db.execute(
    'INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, ?)',
    [full_name, email, password, role]
  );
};

exports.findByEmail = async (email) => {
  const [rows] = await db.execute(
    'SELECT id, email, full_name FROM users WHERE email = ?',
    [email]
  );
  return rows[0];
};

exports.saveResetCode = async (email, code, expiresAt) => {
  await db.execute(
    `INSERT INTO password_reset_codes (email, code, expires_at)
     VALUES (?, ?, ?)
     ON DUPLICATE KEY UPDATE code = ?, expires_at = ?`,
    [email, code, expiresAt, code, expiresAt]
  );
};

exports.getResetCode = async (email, code) => {
  const [rows] = await db.execute(
    `SELECT * FROM password_reset_codes
     WHERE email = ? AND code = ? AND expires_at > NOW()`,
    [email, code]
  );
  return rows[0];
};

exports.deleteResetCode = async (email) => {
  await db.execute(
    'DELETE FROM password_reset_codes WHERE email = ?',
    [email]
  );
};