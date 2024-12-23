import taskServices from "../services/taskServices.js";
import Result from "../common/Result.js";

const getAll = async function (req, res) {
  try {
    const tasks = await taskServices.getAll();
    res.status(200).json(
      new Result(
        {
          list: tasks
        },
        "GET All",
        true
      )
    );
  } catch (exception) {
    res.status(400).json(new Result(null, exception.message, false));
  }
};

const getAllByIdList = async function (req, res) {
  try {
    const tasks = await taskServices.getAllByIdList(req.params?.idList);
    res.status(200).json({
      message: "GET by ID List",
      data: {
        list: tasks
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
    const existsTask = await taskServices.getById(req.params?.id);
    if (existsTask != null) {
      res.status(200).json({
        message: "success",
        data: {
          list: existsTask
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

  const newTask = await taskServices.create(req.body);

  if (newTask != null) {
    res.status(200).json({
      message: "create",
      data: {
        list: newTask
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
  const update = await taskServices.updateById(req.params.id.trim(), req.body);

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
  const deleteSuccess = await taskServices.deleteById(req.params?.id);
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

const registerEmail = async function (req, res) {
  const taskId = req.params.id;
  const { permited } = req.body;

  if (!permited || !Array.isArray(permited)) {
    return res.status(400).json({
      status: "error",
      message: "Invalid request. 'permited' must be an array of emails."
    });
  }

  try {
    const result = await taskServices.registerEmail(taskId, permited);
    return res.status(200).json({
      status: "success",
      message: "Emails processed.",
      data: result
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      message: "Error processing emails.",
      error: error.message
    });
  }
};
export default {
  getAll,
  getAllByIdList,
  getById,
  create,
  updateById,
  deleteById,
  registerEmail
};
