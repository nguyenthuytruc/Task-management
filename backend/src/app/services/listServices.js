import List from "../entity/List.js";
import Task from "../entity/Task.js";
// Lấy tất cả list có id trùng với id truyền vào
const getById = async function (id) {
  try {
    const existsList = await List.findOne({ _id: id }).populate("tasks");
    return existsList;
  } catch (exception) {
    console.log(exception);

    return null;
  }
};
// Lấy tất cả list có idBoard trùng với id Board truyền vào
const getAllByIdBoard = async function (idBoard) {
  try {
    const lists = await List.find({
      boardId: idBoard
    }).populate("tasks");
    return lists;
  } catch (exception) {
    console.log("Error get all List by Board", exception.message);
    return null;
  }
};
// Lấy tất cả List trong database
const getAll = async function () {
  try {
    const listBoard = await List.find({});
    return listBoard;
  } catch (exception) {
    return null;
  }
};

// Tạo List trong database
const create = function ({ name, description, color, createdBy, boardId }) {
  try {
    const newList = new List({
      name,
      description,
      color,

      createdBy,
      boardId
    });
    newList.save();
    return newList;
  } catch (exception) {
    return null;
  }
};
const updateById = async function (
  id,
  { name, description, color, userId, boardId, tasks }
) {
  const session = await List.startSession(); // Dùng session để đảm bảo tính nhất quán nếu cần.
  session.startTransaction();

  try {
    // 1. Update thông tin List
    const update = await List.updateOne(
      { _id: id },
      { name, description, color, userId, boardId, tasks }
    );

    if (update.matchedCount === 0) {
      console.log("No List found with the provided ID.");
      await session.abortTransaction();
      session.endSession();
      return null;
    }

    // 2. Xử lý cập nhật Task
    const currentTasks = await Task.find({ listId: id }); // Lấy các task hiện tại của list.
    const currentTaskIds = currentTasks.map((task) => task._id.toString());
    const newTaskIds = tasks.map((task) => task._id.toString());

    // 2.1. Xóa các task không còn trong list
    const tasksToRemove = currentTaskIds.filter(
      (taskId) => !newTaskIds.includes(taskId)
    );
    if (tasksToRemove.length > 0) {
      await Task.updateMany(
        { _id: { $in: tasksToRemove } },
        { $unset: { listId: "" } } // Xóa listId của task không còn trong list.
      );
    }

    // 2.2. Cập nhật listId cho các task mới được thêm vào
    const tasksToAdd = newTaskIds.filter(
      (taskId) => !currentTaskIds.includes(taskId)
    );
    if (tasksToAdd.length > 0) {
      await Task.updateMany(
        { _id: { $in: tasksToAdd } },
        { $set: { listId: id } } // Gán listId mới.
      );
    }

    await session.commitTransaction();
    session.endSession();

    // 3. Trả về list đã được cập nhật
    const updatedList = await List.findById(id).populate("tasks"); // Populate để lấy thông tin đầy đủ các task nếu cần.
    return updatedList;
  } catch (exception) {
    console.error("Error updating List:", exception);
    await session.abortTransaction(); // Hủy giao dịch nếu có lỗi.
    session.endSession();
    return null;
  }
};

const deleteById = async function (id) {
  try {
    const result = await List.deleteOne({
      _id: id
    });
    console.log(result);
    return result;
  } catch (exception) {
    console.log(exception.message);
    return false;
  }
};
export default {
  getAll,
  getById,
  getAllByIdBoard,
  create,
  updateById,
  deleteById
};
