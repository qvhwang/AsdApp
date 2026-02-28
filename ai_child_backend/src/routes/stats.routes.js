const express = require('express');
const router = express.Router();
const statsController = require('../controllers/stats.controller');
const { verifyToken, isAdmin } = require('../middlewares/auth.middleware');

router.use(verifyToken, isAdmin);

router.get('/screening', statsController.getScreeningStats);

router.get('/users', statsController.getUserStats);

module.exports = router;