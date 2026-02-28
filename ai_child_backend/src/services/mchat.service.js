const mchatModel = require('../models/mchat.model');

exports.calculateRisk = async (question_id, answer) => {
  const q = await mchatModel.getQuestionById(question_id);
  return q.risk_answer === answer ? 1 : 0;
};

exports.finishSession = async (sessionId) => {
  const total = await mchatModel.countRiskAnswers(sessionId);

  let risk = 'Low';
  if (total >= 3 && total <= 7) risk = 'Medium';
  if (total >= 8) risk = 'High';

  await mchatModel.updateSession(sessionId, total, risk);

  return { total_score: total, risk_level: risk };
};