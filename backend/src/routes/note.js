import express from "express";

import NoteController from "../app/controllers/note.js";
const router = express.Router();

// CHECKED
router.get("/b/:idBoard", NoteController.getAllByIdBoard);
// CHECKED
router.get("/:idUser", NoteController.getAllByIdUser);
// CHECKED
router.get("/:id", NoteController.getById);
// CHECKED
router.put("/:id", NoteController.updateById);
// CHECKED
router.delete("/delete/:id", NoteController.deleteById);
// CHECKED
router.post("/", NoteController.create);
// CHECKED
router.get("/", NoteController.getAll);

router.put("/updateStatus/:id", NoteController.updateStatus);

export default router;
