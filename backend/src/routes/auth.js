import express from "express";
import { body, validationResult } from "express-validator";
import { authController } from "../app/controllers/index.js";

const router = express.Router();

router.post(
  "/login",
  body("email").isEmail(),
  body("password").isLength({ min: 5 }),
  authController.login
);

router.post(
  "/register",
  body("email").isEmail(),
  body("username").isLength({ min: 4, max: 30 }),
  body("password").isLength({ min: 5 }),
  authController.register
);

export default router;
