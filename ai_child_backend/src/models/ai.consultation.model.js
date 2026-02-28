const db = require('../config/db');

exports.saveConsultation = async (user_id, child_id, question, aiResponse) => {
  await db.execute(
    `INSERT INTO ai_consultations
     (user_id, child_id, question, ai_response, ai_provider, created_at)
     VALUES (?, ?, ?, ?, ?, NOW())`,
    [
      user_id,
      child_id || null,
      question,
      aiResponse,
      'Llama 3.1 8B (Groq)',
    ]
  );
};

exports.getByChild = async (childId) => {
  const [rows] = await db.execute(
    `SELECT id, question, ai_response, created_at
     FROM ai_consultations
     WHERE child_id = ?
     ORDER BY created_at ASC`,
    [childId]
  );
  return rows;
};

exports.getByUser = async (userId) => {
  const [rows] = await db.execute(
    `SELECT ac.id, ac.question, ac.ai_response,
            ac.created_at, c.full_name as child_name,
            ac.child_id
     FROM ai_consultations ac
     LEFT JOIN children c ON ac.child_id = c.id
     WHERE ac.user_id = ?
     ORDER BY ac.created_at DESC`,
    [userId]
  );
  return rows;
};

exports.deleteById = async (id) => {
  await db.execute(
    'DELETE FROM ai_consultations WHERE id = ?',
    [id]
  );
};