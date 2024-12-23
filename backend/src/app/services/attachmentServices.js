import mongoose from "mongoose";
import Attachment from "../entity/Attachment.js";
import Task from "../entity/Task.js";

// Lấy tất cả attachment có id trùng với id truyền vào
const getById = async function (id) {
  try {
    const existsAttachment = await Attachment.findOne({ _id: id });
    return existsAttachment;
  } catch (exception) {
    console.log(exception);

    return null;
  }
};
// Lấy tất cả Attachment có idTask trùng với id Task truyền vào
const getAllByIdTask = async function (idTask) {
  try {
    const attachments = await Attachment.find({
      taskId: idTask
    });
    return attachments;
  } catch (exception) {
    console.log("Error get all Attachment by Task", exception.message);
    return null;
  }
};
// Lấy tất cả Attachment trong database
const getAll = async function () {
  try {
    const listAttachment = await Attachment.find({});
    return listAttachment;
  } catch (exception) {
    return null;
  }
};

const create = async ({ taskId, filePath, fileName }) => {
  try {
    const newAttachment = await Attachment.create({
      taskId,
      filePath,
      fileName,
      uploadedAt: new Date()
    });
    await newAttachment.save();
    const task = await Task.findById(taskId);
    task.attachments.push(newAttachment._id);
    await task.save();
    return newAttachment;
  } catch (error) {
    console.error("Error saving attachment:", error);
    throw new Error("Could not save attachment");
  }
};

const deleteById = async function (id) {
  try {
    const existsAttachment = await Attachment.findOne({ _id: id });
    const result = await Attachment.deleteOne({
      _id: id
    });
    const task = await Task.findById(existsAttachment.taskId);
    task.attachments.filter((e) => e != id);
    await task.save();
    return result;
  } catch (exception) {
    console.log(exception.message);
    return false;
  }
};
export default {
  create,
  getAll,
  getAllByIdTask,
  getById,
  deleteById
};
