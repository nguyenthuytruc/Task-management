import User from "../entity/User.js";
import Noti from "../entity/Noti.js";

import bycrypt from "bcrypt";

import jwt from "jsonwebtoken";

import JwtManage from "../../util/JwtManage.js";

const getByEmail = async function (email) {
  const userExists = await User.findOne({
    email
  });

  return userExists ?? null;
};

const getById = async function (id) {
  const userExists = await User.findById(id);
  userExists.password = "";

  return userExists ?? null;
};

const getAll = async function () {
  let userExists = await User.find();
  return userExists ?? null;
};

const getAllNotiByUserId = async function (userId) {
  const listNoti = await Noti.find({
    userId: userId
  });
  return listNoti ?? null;
};

const deleteNotiById = async function (notiId) {
  try {
    const deletedNoti = await Noti.findByIdAndDelete(notiId); // Xóa thông báo theo ID
    return deletedNoti ?? null; // Trả về thông báo đã xóa hoặc null nếu không tìm thấy
  } catch (error) {
    throw new Error("Failed to delete notification");
  }
};

const login = async function ({ email, password }) {
  try {
    const userExists = await User.findOne({
      email
    });

    console.log(userExists);

    if (userExists == null) {
      return null;
    }

    const isMatched = await bycrypt.compare(password, userExists.password);
    console.log("isMatched: ", isMatched);

    if (isMatched) {
      console.log("Success");

      const token = JwtManage.generateToken(userExists);
      console.log(token);
      userExists.password = "";
      return {
        userExists,
        token
      };
    }
    return null;
  } catch (exception) {
    console.log(exception);
    return null;
  }
};

const register = async function ({ email, username, password }) {
  const hashedPass = (
    await bycrypt.hash(password, parseInt(process.env.SALT_ROUND))
  ).toString();
  try {
    const newUser = new User({
      email,
      username,
      password: hashedPass
    });
    await newUser.save();
    let token = JwtManage.generateToken(newUser);
    newUser.password = "";

    return {
      newUser,
      token
    };
  } catch (err) {
    return err;
  }
};

const updateImages = async function () {};

export default {
  getByEmail,
  getById,
  getAll,
  register,
  login,
  getAllNotiByUserId,
  deleteNotiById
};
