const childModel = require('../models/children.model');

exports.createChild = async (req, res) => {
  const { user_id, full_name, gender, birth_date, guardian_name } = req.body;

  if (!user_id || !full_name || !gender || !birth_date) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }

  try {
    const newChild = await childModel.insertChild({
      user_id,
      full_name,
      gender,
      birth_date,
      guardian_name
    });

    res.status(201).json(newChild);
  } catch (err) {
    console.error('ADD CHILD ERROR:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getChildrenByUser = async (req, res) => {
  try {
    const children = await childModel.getChildrenByUserId(req.params.userId);
    res.json(children);
  } catch (err) {
    console.error('GET CHILD ERROR:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.updateChild = async (req, res) => {
  const { full_name, gender, birth_date, guardian_name } = req.body;

  if (!full_name || !gender || !birth_date) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }

  try {
    const updated = await childModel.updateChild(
      req.params.id,
      { full_name, gender, birth_date, guardian_name }
    );

    if (!updated) {
      return res.status(404).json({ message: 'Không tìm thấy hồ sơ' });
    }

    res.json({ message: 'Cập nhật thành công' });
  } catch (err) {
    console.error('UPDATE CHILD ERROR:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.deleteChild = async (req, res) => {
  try {
    const deleted = await childModel.deleteChild(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: 'Không tìm thấy hồ sơ' });
    }

    res.status(200).json({ message: 'Xóa thành công' });
  } catch (err) {
    console.error('DELETE CHILD ERROR:', err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};