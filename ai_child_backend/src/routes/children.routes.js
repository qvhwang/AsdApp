const express = require('express');
const router = express.Router();
const childController = require('../controllers/children.controller');

router.post('/', childController.createChild);
router.get('/user/:userId', childController.getChildrenByUser);
router.put('/:id', childController.updateChild);
router.delete('/:id', childController.deleteChild);

module.exports = router;