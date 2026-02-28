const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

router.use(verifyToken);

router.get('/me', userController.getProfile);
router.put('/me', userController.updateProfile);
router.put('/me/change-password', userController.changePassword);

module.exports = router;