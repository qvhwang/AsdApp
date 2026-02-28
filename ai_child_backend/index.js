require('dotenv').config();

const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');

const { hashPassword, comparePassword } = require('./src/utils/password.util');

const app = express();
app.use(cors());
app.use(express.json());

// ===== DB POOL (dùng promise để await được) =====
const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '123456',
  database: 'autism_support_system',
});

db.getConnection()
  .then(() => console.log('✅ Kết nối MySQL thành công'))
  .catch((err) => console.error('❌ MySQL lỗi:', err));

app.get('/', (req, res) => res.send('SERVER OK'));

// ===== REGISTER =====
app.post('/api/auth/register', async (req, res) => {
  const { full_name, email, password } = req.body;

  if (!full_name || !email || !password)
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  if (!email.endsWith('@gmail.com'))
    return res.status(400).json({ message: 'Email phải là @gmail.com' });
  if (password.length < 6)
    return res.status(400).json({ message: 'Mật khẩu tối thiểu 6 ký tự' });

  try {
    const [rows] = await db.execute(
      'SELECT id FROM users WHERE email = ?', [email]
    );
    if (rows.length > 0)
      return res.status(400).json({ message: 'Email đã tồn tại' });

    const hashed = await hashPassword(password);
    await db.execute(
      "INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, 'USER')",
      [full_name, email, hashed]
    );
    res.json({ message: 'Đăng ký thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// ===== LOGIN =====
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password)
    return res.status(400).json({ message: 'Thiếu email hoặc mật khẩu' });

  try {
    const [rows] = await db.execute(
      'SELECT id, full_name, email, password, role, status FROM users WHERE email = ?',
      [email]
    );

    if (rows.length === 0)
      return res.status(401).json({ message: 'Email không tồn tại trong hệ thống' });

    const user = rows[0];

    if (user.status === 0)
      return res.status(403).json({ message: 'Tài khoản đã bị khóa. Liên hệ admin để được hỗ trợ.' });

    const ok = await comparePassword(password, user.password);
    if (!ok)
      return res.status(401).json({ message: 'Mật khẩu không đúng' });

    delete user.password;

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'SECRET_KEY',
      { expiresIn: '7d' }
    );

    res.json({ message: 'Đăng nhập thành công', token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// ===== FORGOT PASSWORD: gửi mã 6 số =====
app.post('/api/auth/forgot-password', async (req, res) => {
  const { email } = req.body;

  if (!email)
    return res.status(400).json({ message: 'Vui lòng nhập email' });

  try {
    const [rows] = await db.execute(
      'SELECT id, full_name FROM users WHERE email = ?', [email]
    );

    if (rows.length === 0)
      return res.status(404).json({ message: 'Email không tồn tại trong hệ thống' });

    const user = rows[0];

    // Tạo mã 6 số
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 phút

    // Lưu mã vào DB
    await db.execute(
      `INSERT INTO password_reset_codes (email, code, expires_at)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE code = ?, expires_at = ?`,
      [email, code, expiresAt, code, expiresAt]
    );

    // Gửi email
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
          <p style="color:#666;font-size:13px">Mã có hiệu lực trong <strong>10 phút</strong>.</p>
          <p style="color:#999;font-size:12px">Nếu bạn không yêu cầu, hãy bỏ qua email này.</p>
        </div>
      `,
    });

    console.log(`📧 Đã gửi mã ${code} đến ${email}`);
    res.json({ message: 'Mã xác nhận đã được gửi đến email của bạn' });
  } catch (err) {
    console.error('MAIL ERROR:', err.message);
    res.status(500).json({ message: 'Không gửi được email: ' + err.message });
  }
});

// ===== RESET PASSWORD: xác minh mã + đổi mật khẩu =====
app.post('/api/auth/reset-password', async (req, res) => {
  const { email, code, new_password } = req.body;

  if (!email || !code || !new_password)
    return res.status(400).json({ message: 'Thiếu dữ liệu' });
  if (new_password.length < 6)
    return res.status(400).json({ message: 'Mật khẩu tối thiểu 6 ký tự' });

  try {
    const [rows] = await db.execute(
      `SELECT * FROM password_reset_codes
       WHERE email = ? AND code = ? AND expires_at > NOW()`,
      [email, code]
    );

    if (rows.length === 0)
      return res.status(400).json({ message: 'Mã xác nhận không đúng hoặc đã hết hạn' });

    const hashed = await bcrypt.hash(new_password, 10);
    await db.execute('UPDATE users SET password = ? WHERE email = ?', [hashed, email]);
    await db.execute('DELETE FROM password_reset_codes WHERE email = ?', [email]);

    res.json({ message: 'Đặt lại mật khẩu thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// ===== AI ROUTES =====
const aiRoutes = require('./src/routes/ai.consultation.routes');
app.use('/api/ai', aiRoutes);

// ===== CÁC ROUTES KHÁC =====
const childRoutes = require('./src/routes/children.routes');
const mchatRoutes = require('./src/routes/mchat.routes');
const userRoutes = require('./src/routes/user.routes');
const adminRoutes = require('./src/routes/admin.users.routes');
const adminMchatRoutes = require('./src/routes/admin.mchat.routes');
const statsRoutes = require('./src/routes/stats.routes');

app.use('/api/admin/stats', statsRoutes);
app.use('/api/admin/mchat', adminMchatRoutes);
app.use('/api/children', childRoutes);
app.use('/api/mchat', mchatRoutes);
app.use('/api/users', userRoutes);
app.use('/api/admin/users', adminRoutes);

app.listen(3000, () => {
  console.log('🚀 Server chạy tại http://localhost:3000');
});