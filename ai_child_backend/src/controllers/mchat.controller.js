const mchatModel = require('../models/mchat.model');
const mchatService = require('../services/mchat.service');

exports.createSession = async (req, res) => {
  try {
    const { user_id, child_id } = req.body;
    const sessionId = await mchatModel.createSession(user_id, child_id);
    res.json({ session_id: sessionId });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getQuestions = async (req, res) => {
  try {
    const rows = await mchatModel.getQuestions();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.saveAnswer = async (req, res) => {
  try {
    const { session_id, question_id, answer } = req.body;

    const isRisk = await mchatService.calculateRisk(question_id, answer);

    await mchatModel.saveAnswer(session_id, question_id, answer, isRisk);

    res.json({ is_risk: isRisk });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.finishSession = async (req, res) => {
  try {
    const result = await mchatService.finishSession(req.params.id);
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getHistoryByChild = async (req, res) => {
  try {
    const rows = await mchatModel.getHistoryByChild(req.params.childId);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getSessionDetail = async (req, res) => {
  try {
    const rows = await mchatModel.getSessionDetail(req.params.id);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};