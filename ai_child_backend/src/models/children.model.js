const db = require('../config/db');

exports.insertChild = async (data) => {
  const { user_id, full_name, gender, birth_date, guardian_name } = data;

  const [result] = await db.execute(
    `INSERT INTO children
     (user_id, full_name, gender, birth_date, guardian_name)
     VALUES (?, ?, ?, ?, ?)`,
    [user_id, full_name, gender, birth_date, guardian_name || null]
  );

  return {
    id: result.insertId,
    ...data
  };
};

exports.getChildrenByUserId = async (userId) => {
  const [rows] = await db.execute(
    'SELECT * FROM children WHERE user_id = ?',
    [userId]
  );
  return rows;
};

exports.updateChild = async (id, data) => {
  const { full_name, gender, birth_date, guardian_name } = data;

  const [result] = await db.execute(
    `UPDATE children
     SET full_name = ?, gender = ?, birth_date = ?, guardian_name = ?
     WHERE id = ?`,
    [full_name, gender, birth_date, guardian_name, id]
  );

  return result.affectedRows > 0;
};

exports.deleteChild = async (id) => {
  const [result] = await db.execute(
    'DELETE FROM children WHERE id = ?',
    [id]
  );

  return result.affectedRows > 0;
};