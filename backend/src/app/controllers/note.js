import Result from "../common/Result.js";
import noteServices from "../services/noteServices.js";
const getAll = async function (req, res) {
  try {
    const notes = await noteServices.getAll();
    res.status(200).json(
      new Result(
        {
          list: notes
        },
        "GET All",
        true
      )
    );
  } catch (exception) {
    res.status(400).json(new Result(null, exception.message, false));
  }
};
const getAllByIdBoard = async function (req, res) {
  try {
    console.log(req.params?.idBoard);

    const notes = await noteServices.getAllByIdBoard(req.params?.idBoard);
    res.status(200).json({
      message: "GET by ID Board",
      data: {
        list: notes
      }
    });
  } catch (exception) {
    res.status(400).json({
      message: "Error",
      data: {}
    });
  }
};
const getAllByIdUser = async function (req, res) {
  try {
    const notes = await noteServices.getAllByIdUser(req.params?.idUser);
    res.status(200).json({
      message: "GET by ID Note",
      data: {
        list: notes
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
    const existsNote = await noteServices.getById(req.params?.id);
    if (existsNote != null) {
      res.status(200).json({
        message: "success",
        data: {
          list: existsNote
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

const create = function (req, res) {
  console.log(req.body);

  const newNote = noteServices.create(req.body);

  if (newNote != null) {
    res.status(200).json({
      message: "create",
      data: {
        list: newNote
      }
    });
  } else {
    res.status(400).json({
      message: "error",
      data: {}
    });
  }
};
// update status
const updateStatus = async function (req, res) {
  try {
    const { id } = req.params; // Lấy id của ghi chú từ URL

    const updatedNote = await noteServices.updateStatus(id); // Gọi hàm updateStatus từ repository

    if (updatedNote) {
      return res
        .status(200)
        .json(
          new Result({ note: updatedNote }, `Note status updated to `, true)
        );
    } else {
      return res.status(404).json(new Result(null, "Note not found", false));
    }
  } catch (exception) {
    console.error("Error in updateStatus:", exception);
    return res
      .status(500)
      .json(new Result(null, "Internal server error", false));
  }
};

const updateById = async function (req, res) {
  const update = await noteServices.updateById(req.params.id.trim(), req.body);

  if (update !== null) {
    res.status(200).json({
      message: "Update successful",
      data: {
        list: update
      }
    });
    // Lỗi chỗ name kìa
  } else {
    res.status(400).json({
      message: "Update failed",
      data: {}
    });
  }
};

const deleteById = async function (req, res) {
  const deleteSuccess = await noteServices.deleteById(req.params?.id);
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

export default {
  getById,
  getAllByIdBoard,
  getAllByIdUser,
  getAll,
  create,
  updateStatus,
  updateById,
  deleteById
};
