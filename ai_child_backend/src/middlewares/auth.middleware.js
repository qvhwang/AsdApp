const jwt = require('jsonwebtoken');

exports.verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: 'Không có token' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'SECRET_KEY'
    );
    req.user = decoded;
    next();
  } catch (err) {
    console.log('❌ Token error:', err.message);
    return res.status(403).json({ message: 'Token không hợp lệ' });
  }
};

exports.isAdmin = (req, res, next) => {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({ message: 'Không có quyền' });
  }
  next();
};