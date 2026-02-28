const express = require('express');
const router = express.Router();
const adminUserController = require('../controllers/admin.users.controller');
const { verifyToken, isAdmin } = require('../middlewares/auth.middleware');

router.use(verifyToken, isAdmin);

router.get('/', adminUserController.getAllUsers);
router.post('/', adminUserController.createUser);
router.put('/toggle-status', adminUserController.toggleStatus);
router.put('/change-role', adminUserController.changeRole);
router.put('/:id', adminUserController.updateUser); // ✅ thêm mới
router.delete('/:id', adminUserController.deleteUser);

module.exports = router;