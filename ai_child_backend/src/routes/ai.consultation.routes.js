const express = require('express');
const router = express.Router();
const aiController = require('../controllers/ai.consultation.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

router.use(verifyToken);

router.post('/ask', aiController.askAI);
router.get('/history/:childId', aiController.getHistoryByChild);
router.get('/history/user/:userId', aiController.getHistoryByUser);
router.delete('/:id', aiController.deleteHistory);

module.exports = router;