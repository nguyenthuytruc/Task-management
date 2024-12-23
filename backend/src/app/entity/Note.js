import mongoose from "mongoose";
import mongooseDelete from "mongoose-delete";
const Schema = mongoose.Schema;

const Note = new Schema({
  name: { type: String, require: true },
  description: { type: String },
  type: {
    type: String,
    default: "Normal"
  },
  isPinned: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Users",
    required: true
  },
  board: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Boards",
    required: true
  }
});

Note.plugin(mongooseDelete);
Note.plugin(mongooseDelete, { deletedAt: true, overrideMethods: "all" });

export default mongoose.model("Notes", Note);
