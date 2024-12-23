import mongoose from "mongoose";
import mongooseDelete from "mongoose-delete";
import Attachment from "./Attachment.js";
const Schema = mongoose.Schema;

const Task = new Schema({
  name: { type: String, required: true },
  description: { type: String },
  status: {
    type: String,
    enum: ["Pending", "In Progress", "Completed"],
    default: "Pending"
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Users",
    required: true
  },
  createAt: { type: Date, default: Date.now },
  updateAt: { type: Date, default: Date.now },
  permitted: [
    {
      email: { type: String }
    }
  ],
  listId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Lists",
    required: true
  },
  attachments: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Attachments"
    }
  ]
});

Task.plugin(mongooseDelete);
Task.plugin(mongooseDelete, { deletedAt: true, overrideMethods: "all" });

export default mongoose.model("Tasks", Task);
