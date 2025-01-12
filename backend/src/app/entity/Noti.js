import mongoose from "mongoose";
import mongooseDelete from "mongoose-delete";
const Schema = mongoose.Schema;

const Noti = new Schema({
  title: { type: String, require: true },
  description: { type: String },
  status: { type: Boolean },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Users",
    required: true
  }
});

Noti.plugin(mongooseDelete);
Noti.plugin(mongooseDelete, { deletedAt: true, overrideMethods: "all" });

export default mongoose.model("Notis", Noti);
