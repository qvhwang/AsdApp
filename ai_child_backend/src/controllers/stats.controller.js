const statsModel = require('../models/stats.model');

exports.getScreeningStats = async (req, res) => {
  try {
    const { from, to } = req.query;
    const fromVal = from && from !== 'undefined' ? from : null;
    const toVal = to && to !== 'undefined' ? to : null;
    console.log('📊 STATS from:', fromVal, 'to:', toVal);
    const data = await statsModel.getScreeningStats(fromVal, toVal);
    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getUserStats = async (req, res) => {
  try {
    const { sort = 'count' } = req.query;
    const data = await statsModel.getUserStats(sort);
    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};