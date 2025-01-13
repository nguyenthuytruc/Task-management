import userServices from "../services/userServices.js";
import Result from "../common/Result.js";

import fs from "fs";
import path from "path";

const getById = async function (req, res) {
  const id = req?.params?.id ?? "";
  if (id != "") {
    const userExists = await userServices.getById(id);

    if (userExists) {
      res.status(200).json(new Result({ user: userExists }, "success", true));
    } else {
      res.status(400).json(new Result(null, "Not found", false));
    }
  } else {
    res.status(400).json(new Result(null, "Not have id", false));
  }
};

const getByEmail = async function (req, res) {
  const email = req.query?.email ?? "";

  if (email === "") {
    return res.status(400).json({
      message: `Not email to find !`,
      data: {}
    });
  } else {
    const userExists = await userServices.getByEmail(email);
    if (userExists) {
      res.status(200).json(new Result(userExists, "success", true));
    } else {
      res.status(400).json(new Result("Not found", false));
    }
  }
};

const getAll = async function (req, res) {
  const userExists = await userServices.getAll();
  res.status(200).json({
    message: `Get all success !`,
    data: {
      users: userExists
    }
  });
};

const uploadImage = async function (req, res) {
  const { base64, fileName } = req.body;

  // Extract base64 data (skip the metadata part)
  const base64Data = base64.replace(/^data:([A-Za-z-+/]+);base64,/, "");

  const pathFile = "D:/Code Project/TaskManagement/core/src/assets";
  // Create a path to save the file
  const filePath = path.join(pathFile, "images", fileName);

  // Write file to the server
  fs.writeFile(filePath, base64Data, "base64", (err) => {
    if (err) {
      return res
        .status(500)
        .send({ message: "File upload failed", error: err });
    }
    res.status(200).send({
      message: "File uploaded successfully",
      path: filePath
    });
  });
};

const getListNoti = async function (req, res) {
  const id = req?.params?.id ?? "";
  if (id != "") {
    const list = await userServices.getAllNotiByUserId(id);
    res.status(200).json(new Result({ list: list }, "success", true));
  } else {
    res.status(400).json(new Result(null, "Not have id", false));
  }
};

const deleteNotiById = async function (req, res) {
  const id = req?.params?.id ?? "";
  if (id !== "") {
    try {
      // Gọi service để xóa thông báo theo ID
      const result = await userServices.deleteNotiById(id);

      if (result) {
        // Thành công
        res
          .status(200)
          .json(new Result(null, "Notification deleted successfully", true));
      } else {
        // Thông báo không tồn tại
        res.status(404).json(new Result(null, "Notification not found", false));
      }
    } catch (error) {
      // Xử lý lỗi
      res
        .status(500)
        .json(
          new Result(
            null,
            `Error deleting notification: ${error.message}`,
            false
          )
        );
    }
  } else {
    // Trường hợp không có ID
    res
      .status(400)
      .json(new Result(null, "Notification ID is required", false));
  }
};

import { GoogleGenerativeAI } from "@google/generative-ai";

const testGemini = async function (req, res) {
  const genAI = new GoogleGenerativeAI(
    "AIzaSyDcL4IDc0V_qQMpEQNY4u8FZBewbA2pnsE"
  );
  const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

  const prompt = req.body.message;

  const result = await model.generateContent(prompt);
  console.log(result.response.text());
  res.json(result.response.text());
};

export default {
  getById,
  getAll,
  getByEmail,
  getListNoti,
  uploadImage,
  testGemini,
  deleteNotiById
};
