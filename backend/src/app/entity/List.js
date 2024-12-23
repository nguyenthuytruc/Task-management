import mongoose from "mongoose";
import mongooseDelete from "mongoose-delete";
// import User from "./User"
const Schema = mongoose.Schema;

const List = new Schema({
  name: { type: String, required: true },
  description: { type: String },
  color: { type: String },
  createAt: { type: Date, default: Date.now },
  updateAt: { type: Date, default: Date.now },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Users",
    required: true
  },
  boardId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Boards",
    required: true
  },
  tasks: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Tasks"
    }
  ]
});

List.plugin(mongooseDelete);
List.plugin(mongooseDelete, { deletedAt: true, overrideMethods: "all" });

export default mongoose.model("Lists", List);
