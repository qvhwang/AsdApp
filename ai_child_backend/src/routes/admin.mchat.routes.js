const express = require('express');
const router = express.Router();
const adminMchatController = require('../controllers/admin.mchat.controller');

router.get('/questions', adminMchatController.getQuestions);
router.post('/questions', adminMchatController.createQuestion);
router.put('/questions/:id', adminMchatController.updateQuestion);
router.patch('/questions/:id/toggle', adminMchatController.toggleQuestion);

module.exports = router;