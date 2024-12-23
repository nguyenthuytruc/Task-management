import userRouter from "./users.js";
import authRouter from "./auth.js";
import boardRouter from "./board.js";
import listRouter from "./list.js";
import taskRouter from "./task.js";
import attachmentRouter from "./attachment.js";
import notesRouter from "./note.js";

// import siteRouter from "./site.js";

function route(app) {
  app.use("/api/auth", authRouter);
  app.use("/api/users", userRouter);
  app.use("/api/board", boardRouter);
  app.use("/api/list", listRouter);
  app.use("/api/task", taskRouter);
  app.use("/api/attachment", attachmentRouter);
  app.use("/api/notes", notesRouter);

  // app.use("/", siteRouter);
}
// được rồi á, giờ làm thêm add đồ thui là oke rùi
export default route;
