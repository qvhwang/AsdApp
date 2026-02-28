const aiService = require('../services/ai.service');
const aiModel = require('../models/ai.consultation.model');

exports.askAI = async (req, res) => {
  try {
    const { user_id, child_id, question } = req.body;

    if (!user_id || !question) {
      return res.status(400).json({ message: 'Thiếu dữ liệu' });
    }

    const aiResponse = await aiService.askQwen(question);

    await aiModel.saveConsultation(
      user_id,
      child_id,
      question,
      aiResponse
    );

    res.json({
      message: 'Thành công',
      response: aiResponse,
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getHistoryByChild = async (req, res) => {
  try {
    const rows = await aiModel.getByChild(req.params.childId);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getHistoryByUser = async (req, res) => {
  try {
    const rows = await aiModel.getByUser(req.params.userId);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deleteHistory = async (req, res) => {
  try {
    await aiModel.deleteById(req.params.id);
    res.json({ message: 'Xóa thành công' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};