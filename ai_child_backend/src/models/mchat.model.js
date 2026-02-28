const db = require('../config/db');

exports.createSession = async (user_id, child_id) => {
  const [result] = await db.execute(
    'INSERT INTO mchat_sessions (user_id, child_id) VALUES (?, ?)',
    [user_id, child_id]
  );
  return result.insertId;
};

exports.getQuestions = async () => {
  const [rows] = await db.execute(
    'SELECT * FROM mchat_questions WHERE is_active = 1 ORDER BY id'
  );
  return rows;
};

exports.getAllQuestions = async () => {
  const [rows] = await db.execute(
    'SELECT * FROM mchat_questions ORDER BY id'
  );
  return rows;
};

exports.insertQuestion = async (question_text, risk_answer, is_active) => {
  const [result] = await db.execute(
    'INSERT INTO mchat_questions (question_text, risk_answer, is_active) VALUES (?, ?, ?)',
    [question_text, risk_answer, is_active]
  );
  return result.insertId;
};

exports.updateQuestion = async (id, question_text, risk_answer, is_active) => {
  const [result] = await db.execute(
    'UPDATE mchat_questions SET question_text=?, risk_answer=?, is_active=? WHERE id=?',
    [question_text, risk_answer, is_active, id]
  );
  return result.affectedRows > 0;
};

exports.toggleQuestion = async (id) => {
  const [result] = await db.execute(
    'UPDATE mchat_questions SET is_active = IF(is_active = 1, 0, 1) WHERE id=?',
    [id]
  );
  if (result.affectedRows === 0) return null;

  const [[row]] = await db.execute(
    'SELECT is_active FROM mchat_questions WHERE id=?',
    [id]
  );
  return row.is_active;
};

exports.getQuestionById = async (id) => {
  const [[row]] = await db.execute(
    'SELECT risk_answer FROM mchat_questions WHERE id = ?',
    [id]
  );
  return row;
};

exports.saveAnswer = async (session_id, question_id, answer, is_risk) => {
  await db.execute(
    `INSERT INTO mchat_answers
     (session_id, question_id, answer, is_risk)
     VALUES (?, ?, ?, ?)`,
    [session_id, question_id, answer, is_risk]
  );
};

exports.countRiskAnswers = async (sessionId) => {
  const [rows] = await db.execute(
    'SELECT COUNT(*) total FROM mchat_answers WHERE session_id = ? AND is_risk = 1',
    [sessionId]
  );
  return rows[0].total;
};

exports.updateSession = async (id, total, risk) => {
  await db.execute(
    'UPDATE mchat_sessions SET total_score=?, risk_level=? WHERE id=?',
    [total, risk, id]
  );
};

exports.getHistoryByChild = async (childId) => {
  const [rows] = await db.execute(
    `SELECT id, total_score, risk_level, DATE(created_at) as created_at
     FROM mchat_sessions
     WHERE child_id = ?
     ORDER BY created_at DESC`,
    [childId]
  );
  return rows;
};

exports.getSessionDetail = async (id) => {
  const [rows] = await db.execute(
    `SELECT q.question_text, a.answer, a.is_risk
     FROM mchat_answers a
     JOIN mchat_questions q ON a.question_id = q.id
     WHERE a.session_id = ?
     ORDER BY q.id`,
    [id]
  );
  return rows;
};