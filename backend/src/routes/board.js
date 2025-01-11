import express from "express";

import BoardController from "../app/controllers/board.js";
const router = express.Router();

router.get("/c/:idUser", BoardController.getCoopboardByIdUser);
router.get("/getAll/:idUser", BoardController.getAllByIdUser);
router.get("/:id", BoardController.getById);
router.post("/:id/add-members", BoardController.addMembers);
router.post("/:id/remove-members", BoardController.removeMembers);
router.put("/:id", BoardController.updateById);
router.delete("/delete/:id", BoardController.deleteById);
router.post("/", BoardController.create);
router.get("/", BoardController.getAll);
router.get("/:id/members", BoardController.getMembersByBoardId);

export default router;
