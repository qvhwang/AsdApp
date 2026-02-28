const mchatModel = require('../models/mchat.model');

exports.getQuestions = async (req, res) => {
  try {
    const questions = await mchatModel.getAllQuestions();
    res.json(questions);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.createQuestion = async (req, res) => {
  const { question_text, risk_answer, is_active } = req.body;

  if (!question_text || !risk_answer) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }

  try {
    await mchatModel.insertQuestion(
      question_text,
      risk_answer,
      is_active ?? 1
    );

    res.json({ message: 'Thêm thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.updateQuestion = async (req, res) => {
  const { id } = req.params;
  const { question_text, risk_answer, is_active } = req.body;

  try {
    const updated = await mchatModel.updateQuestion(
      id,
      question_text,
      risk_answer,
      is_active ?? 1
    );

    if (!updated) {
      return res.status(404).json({ message: 'Không tìm thấy câu hỏi' });
    }

    res.json({ message: 'Cập nhật thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.toggleQuestion = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await mchatModel.toggleQuestion(id);

    if (!result) {
      return res.status(404).json({ message: 'Không tìm thấy câu hỏi' });
    }

    res.json({
      message: 'Cập nhật thành công',
      is_active: result
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};