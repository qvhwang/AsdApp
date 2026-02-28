const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
require('dotenv').config();
const authModel = require('../models/user.model');
const { hashPassword, comparePassword } = require('../utils/password.util');

exports.register = async (req, res) => {
  const { full_name, email, password } = req.body;

  if (!full_name || !email || !password) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }
  if (!email.endsWith('@gmail.com')) {
    return res.status(400).json({ message: 'Email phải là @gmail.com' });
  }
  if (password.length < 6) {
    return res.status(400).json({ message: 'Mật khẩu tối thiểu 6 ký tự' });
  }

  try {
    const existingUser = await authModel.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ message: 'Email đã tồn tại' });
    }

    const hashedPassword = await hashPassword(password);
    await authModel.createUser(full_name, email, hashedPassword, 'USER');
    res.json({ message: 'Đăng ký thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Thiếu email hoặc mật khẩu' });
  }

  try {
    const user = await authModel.findByEmail(email);

    if (!user) {
      return res.status(401).json({ message: 'Email không tồn tại trong hệ thống' });
    }

    const ok = await comparePassword(password, user.password);
    if (!ok) {
      return res.status(401).json({ message: 'Mật khẩu không đúng' });
    }

    if (user.status === 0) {
      return res.status(403).json({ message: 'Tài khoản đã bị khóa. Liên hệ admin để được hỗ trợ.' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    delete user.password;
    res.json({ message: 'Đăng nhập thành công', token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.forgotPassword = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Vui lòng nhập email' });
  }

  try {
    const user = await authModel.findByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'Email không tồn tại trong hệ thống' });
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // hết hạn sau 10 phút

    await authModel.saveResetCode(email, code, expiresAt);

    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
      },
    });

    await transporter.sendMail({
      from: `"M-CHAT App" <${process.env.MAIL_USER}>`,
      to: email,
      subject: 'Mã xác nhận đặt lại mật khẩu',
      html: `
        <div style="font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:24px;border:1px solid #e0e0e0;border-radius:12px">
          <h2 style="color:#00897B">Đặt lại mật khẩu</h2>
          <p>Xin chào <strong>${user.full_name}</strong>,</p>
          <p>Mã xác nhận của bạn là:</p>
          <div style="font-size:36px;font-weight:bold;letter-spacing:8px;color:#00897B;text-align:center;padding:16px 0">
            ${code}
          </div>
          <p style="color:#666;font-size:13px">Mã có hiệu lực trong <strong>10 phút</strong>. Không chia sẻ mã này với ai.</p>
          <p style="color:#999;font-size:12px">Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này.</p>
        </div>
      `,
    });

    res.json({ message: 'Mã xác nhận đã được gửi đến email của bạn' });
  } catch (err) {
    console.error('MAIL ERROR:', err.message); // thêm dòng này
    res.status(500).json({ message: 'Không gửi được email. Thử lại sau.' });
  }

};

exports.resetPassword = async (req, res) => {
  const { email, code, new_password } = req.body;

  if (!email || !code || !new_password) {
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  }
  if (new_password.length < 6) {
    return res.status(400).json({ message: 'Mật khẩu tối thiểu 6 ký tự' });
  }

  try {
    const record = await authModel.getResetCode(email, code);
    if (!record) {
      return res.status(400).json({ message: 'Mã xác nhận không đúng hoặc đã hết hạn' });
    }

    const hashed = await hashPassword(new_password);
    const user = await authModel.findByEmail(email);
    await authModel.updatePassword(user.id, hashed);
    await authModel.deleteResetCode(email);

    res.json({ message: 'Đặt lại mật khẩu thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
};