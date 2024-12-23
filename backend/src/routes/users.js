import express from "express";
import { body, validationResult } from "express-validator";

import UserController from "../app/controllers/user.js";

const router = express.Router();
router.get("/email", UserController.getByEmail);
router.get("/test", UserController.testGemini);
router.get("/:id", UserController.getById);
router.post("/upload", UserController.uploadImage);
router.get("/", UserController.getAll);

export default router;
