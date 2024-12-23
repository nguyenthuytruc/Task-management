import express from "express";

import TaskController from "../app/controllers/task.js";
const router = express.Router();

// CHECKED
router.get("/l/:idList", TaskController.getAllByIdList);
// CHECKED
router.get("/:id", TaskController.getById);
// CHECKED
router.post("/", TaskController.create);
// CHECKED
router.get("/", TaskController.getAll);
// CHECKED
router.put("/:id", TaskController.updateById);
// CHECKED
router.delete("/delete/:id", TaskController.deleteById);
//
router.post("/register/:id", TaskController.registerEmail);
export default router;
