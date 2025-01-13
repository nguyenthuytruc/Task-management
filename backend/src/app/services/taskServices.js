import Task from "../entity/Task.js";
import List from "../entity/List.js";
import Noti from "../entity/Noti.js";
import User from "../entity/User.js";
const getById = async function (id) {
  try {
    const existsTask = await Task.findOne({ _id: id });
    return existsTask;
  } catch (exception) {
    console.log(exception);

    return null;
  }
};
// Lấy tất cả task có list id trùng id truyền vào
const getAllByIdList = async function (idList) {
  try {
    const tasks = await Task.find({
      listId: idList
    }).populate("attachments");
    return tasks;
  } catch (exception) {
    console.log("Error get all Task by List Id: ", exception.message);
    return null;
  }
};
// Lấy tất cả Taks trong database
const getAll = async function () {
  try {
    const listTask = await Task.find({});
    return listTask;
  } catch (exception) {
    return null;
  }
};

// Tạo Task trong database
const create = async function ({
  name,
  description,
  status,
  listId,
  createdBy,
  permitted,
  attachments
}) {
  try {
    const newTask = new Task({
      name,
      description,
      status,
      createdBy,
      listId,
      attachments
    });

    const list = await List.findOne({ _id: listId });
    list.tasks.push(newTask._id);

    newTask.permitted.push({ email: permitted });
    await list.save();
    await newTask.save();
    return newTask;
  } catch (exception) {
    console.error("Error creating task: ", exception);
    throw exception;
  }
};

// Cập nhật list theo id
const updateById = async function (
  id,
  { name, description, status, userId, listId, assignee }
) {
  try {
    const update = await Task.updateOne(
      { _id: id },
      {
        name,
        description,
        status,
        permitted: userId,
        listId,
        assignee
      }
    );
    if (update.matchedCount === 0) {
      console.log("No Task found with the provided ID.");
      return null;
    }
    const updateTask = await Task.findById({
      _id: id
    });
    const user = await User.findOne({ email: updateTask.assignee });
    console.log(updateTask);

    const newNoti = new Noti({
      userId: user._id,
      title: "Nhận task mới",
      description: `Bạn đã được gán vào task ${updateTask.name}`
    });
    console.log("New Noti");

    await newNoti.save();
    return updateTask;
  } catch (exception) {
    console.error("Error updating Task:", exception);
    return null;
  }
};
//
const deleteById = async function (id) {
  try {
    const result = await Task.deleteOne({
      _id: id
    });
    console.log(result);
    return result;
  } catch (exception) {
    console.log(exception.message);
    return false;
  }
};

const registerEmail = async function (taskId, emails) {
  try {
    // Lấy task hiện tại để kiểm tra email đã có chưa
    const task = await Task.findById(taskId);
    if (!task) {
      throw new Error("Task not found");
    }

    // Lọc ra các email đã có trong task
    const existingEmails = task.permited.map((item) => item.email);
    const newEmails = emails.filter((email) => !existingEmails.includes(email));
    const alreadyRegistered = emails.filter((email) =>
      existingEmails.includes(email)
    );

    // Nếu có email mới, thì cập nhật vào task
    if (newEmails.length > 0) {
      await Task.findByIdAndUpdate(
        taskId,
        {
          $push: {
            permited: {
              $each: newEmails.map((email) => ({ email }))
            }
          }
        },
        { new: true }
      );
    }

    return {
      alreadyRegistered,
      newEmails,
      task: await Task.findById(taskId) // Trả về task sau khi cập nhật
    };
  } catch (error) {
    console.error("Error adding permitted emails: ", error.message);
    throw error;
  }
};

const moveTask = async function (idTask, idNextList) {
  try {
    // Tìm task hiện tại bằng idTask
    const task = await Task.findById(idTask);
    if (!task) {
      throw new Error("Task not found");
    }

    // Lấy List cũ từ idList trong Task
    const currentList = await List.findById(task.listId);
    if (!currentList) {
      throw new Error("Current List not found");
    }

    // Lấy List mới từ idNextList
    const nextList = await List.findById(idNextList);
    if (!nextList) {
      throw new Error("Next List not found");
    }

    // Xóa idTask khỏi mảng task[] trong List cũ
    currentList.tasks = currentList.tasks.filter(
      (taskId) => taskId.toString() !== idTask
    );
    await currentList.save();

    // Thêm idTask vào mảng task[] trong List mới
    nextList.tasks.push(idTask);
    await nextList.save();

    // Cập nhật idList của Task
    task.listId = idNextList;
    await task.save();

    return true;
  } catch (error) {
    console.log(error);

    return false;
  }
};

export default {
  getAll,
  getById,
  getAllByIdList,
  create,
  updateById,
  deleteById,
  registerEmail,
  moveTask
};
