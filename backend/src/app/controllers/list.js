import listServices from "../services/listServices.js";
import Result from "../common/Result.js";

const getAll = async function (req, res) {
  try {
    const lists = await listServices.getAll();
    res.status(200).json(
      new Result(
        {
          list: lists
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
    const lists = await listServices.getAllByIdBoard(req.params?.idBoard);
    res.status(200).json({
      message: "GET by ID Board",
      data: {
        list: lists
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
    const existsList = await listServices.getById(req.params?.id);
    if (existsList != null) {
      res.status(200).json({
        message: "success",
        data: {
          list: existsList
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

const create = async function (req, res) {
  console.log(req.body);

  const newlist = await listServices.create(req.body);

  if (newlist != null) {
    res.status(200).json({
      message: "create",
      data: {
        list: newlist
      }
    });
  } else {
    res.status(400).json({
      message: "error",
      data: {}
    });
  }
};

const updateById = async function (req, res) {
  const update = await listServices.updateById(req.params.id.trim(), req.body);

  if (update !== null) {
    res.status(200).json({
      message: "Update successful",
      data: {
        list: update
      }
    });
  } else {
    res.status(400).json({
      message: "Update failed",
      data: {}
    });
  }
};

const deleteById = async function (req, res) {
  const deleteSuccess = await listServices.deleteById(req.params?.id);
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

const getArrListByIdList = async function (req, res) {
  const arrList = await listServices.getArrListByIdTask(req.params?.idList);
  res.status(200).json({
    message: "Delete successful",
    data: arrList
  });
};

export default {
  getAll,
  getAllByIdBoard,
  getArrListByIdList,
  getById,
  create,
  updateById,
  deleteById
};
