import mongoose from "mongoose";
import mongooseDelete from "mongoose-delete";
const Schema = mongoose.Schema;

const User = new Schema({
  username: { type: String, required: true },
  password: { type: String },
  email: { type: String, required: true },
  phone: { type: String },
  avatar: { type: String },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

User.plugin(mongooseDelete);
User.plugin(mongooseDelete, { deletedAt: true, overrideMethods: "all" });

export default mongoose.model("Users", User);
