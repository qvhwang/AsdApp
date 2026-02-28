const express = require('express');
const router = express.Router();
const mchatController = require('../controllers/mchat.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

router.use(verifyToken);

router.post('/sessions', mchatController.createSession);
router.get('/questions', mchatController.getQuestions);
router.post('/answers', mchatController.saveAnswer);
router.put('/sessions/:id/finish', mchatController.finishSession);

router.get('/history/:childId', mchatController.getHistoryByChild);
router.get('/session/:id', mchatController.getSessionDetail);

module.exports = router;