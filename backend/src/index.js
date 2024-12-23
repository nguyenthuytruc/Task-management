import express from "express";
import * as dotenv from "dotenv";
import connect from "../src/config/db/index.js";
import route from "./routes/index.js";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import { Server } from "socket.io";
import { createServer } from "node:http";

// authen middleware
import checkToken from "./app/authentication/auth.js";
// CORS configuration
const corsOptions = {
  origin: "*", // Cho phép yêu cầu từ bất kỳ nguồn nào
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"], // Các phương thức HTTP cho phép
  allowedHeaders: ["Content-Type", "Authorization"], // Các headers cho phép
  preflightContinue: false,
  optionsSuccessStatus: 204
};

// Get the filename and directory name in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();
const app = express();
app.use(cors(corsOptions));
const PORT = process.env.PORT || 3000;
//app.use("/static", express.static(path.join(__dirname, "public")));
app.use("/static", express.static(path.join(__dirname, "assets/files")));
// app.use(checkToken);
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));
const server = createServer(app);
// const io = new Server(server, {
// 	cors: {
// 		origin: "*", // Cho phép mọi domain kết nối (chỉ dùng cho dev)
// 	},
// });

connect();
route(app);
app.listen(3000, () => {
  console.log("Server started at port 3000");
});
