const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/forgot-password', authController.forgotPassword);   // ✅ gửi mã
router.post('/reset-password', authController.resetPassword);     // ✅ đặt lại mật khẩu

module.exports = router;