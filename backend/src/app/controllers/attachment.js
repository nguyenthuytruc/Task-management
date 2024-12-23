import attachmentServices from "../services/attachmentServices.js";
import Result from "../common/Result.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { getFilename } from "../../util/getFilename.js";

// Thư mục lưu file (nên cấu hình nơi lưu file phù hợp)
const UPLOADS_DIR =
  "D://Code Project\\TaskManagement\\core\\src\\assets\\files";
const getAll = async function (req, res) {
  try {
    const attachments = await attachmentServices.getAll();
    res.status(200).json(
      new Result(
        {
          list: attachments
        },
        "GET All",
        true
      )
    );
  } catch (exception) {
    res.status(400).json(new Result(null, exception.message, false));
  }
};

const getAllByIdTask = async function (req, res) {
  try {
    const attachments = await attachmentServices.getAllByIdTask(
      req.params?.idTask
    );
    console.log(req.params?.idTask);

    res.status(200).json({
      message: "GET by ID Task",
      data: {
        list: attachments
      }
    });
  } catch (exception) {
    res.status(400).json({
      message: "Error",
      data: {}
    });
  }
};

const getById = async function (req, res) {
  try {
    const existsAttachment = await attachmentServices.getById(req.params?.id);
    if (existsAttachment != null) {
      res.status(200).json({
        message: "success",
        data: {
          list: existsAttachment
        }
      });
    } else {
      res.status(400).json({
        message: "Not found",
        data: {}
      });
    }
  } catch (exception) {
    res.status(400).json({
      message: "Error",
      data: {}
    });
  }
};

const create = async (req, res) => {
  try {
    const taskId = req.params.id;
    const { base64, fileName } = req.body;

    if (!taskId || !base64 || !fileName) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // Tách phần header và dữ liệu base64
    const matches = base64.match(/^data:(.+);base64,(.+)$/);
    if (!matches || matches.length !== 3) {
      return res.status(400).json({ message: "Invalid base64 format" });
    }

    const fileData = matches[2]; // Lấy phần dữ liệu base64
    const buffer = Buffer.from(fileData, "base64"); // Chuyển base64 thành Buffer

    const filePath = path.join(UPLOADS_DIR, fileName);

    // Ghi file vào hệ thống
    fs.writeFileSync(filePath, buffer);

    // Lưu thông tin vào database
    const savedAttachment = await attachmentServices.create({
      taskId,
      filePath,
      fileName
    });

    res.status(201).json({
      message: "Attachment created successfully",
      data: savedAttachment
    });
  } catch (error) {
    console.error("Error creating attachment:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

const deleteById = async function (req, res) {
  const deleteSuccess = await attachmentServices.deleteById(req.params?.id);
  if (deleteSuccess.deletedCount > 0) {
    res.status(200).json({
      message: "Delete successful",
      data: {}
    });
  } else {
    res.status(400).json({
      message: "Delete failed"
    });
  }
};

// Controller để xử lý yêu cầu tải file
const downloadFile = (req, res) => {
  const fileName = req.query.filename; // Lấy tên file từ query params
  console.log(req.query.fileName);
  // Get the filename and directory name in ES modules
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  if (!fileName) {
    return res.status(400).send({ message: "Filename is required!" });
  }

  const directoryPath = path.join(__dirname, "../../assets/files/"); // Thư mục chứa file
  const filePath = path.join(directoryPath, fileName);

  res.download(filePath, fileName, (err) => {
    if (err) {
      console.error(`Error downloading file: ${err.message}`);
      res.status(500).send({ message: "Unable to download the file." });
    }
  });
};

export default {
  create,
  getAll,
  getAllByIdTask,
  getById,
  deleteById,
  downloadFile
};
