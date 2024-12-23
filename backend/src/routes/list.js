import express from "express";

import ListController from "../app/controllers/list.js";
const router = express.Router();

// CHECKED
router.get("/b/:idBoard", ListController.getAllByIdBoard);
// CHECKED
router.get("/:id", ListController.getById);
// CHECKED
router.put("/:id", ListController.updateById);
// CHECKED
router.delete("/delete/:id", ListController.deleteById);
// CHECKED
router.post("/", ListController.create);
// CHECKED
router.get("/", ListController.getAll);

export default router;
