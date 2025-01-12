import Board from "../entity/Board.js";
import Noti from "../entity/Noti.js";
import User from "../entity/User.js";
import mongoose from "mongoose";
const getById = async function (id) {
  try {
    console.log(id);
    const existsBoard = await Board.findOne({ _id: id });
    return existsBoard;
  } catch (exception) {
    console.log(exception);

    return null;
  }
};

const getAllByIdUser = async function (idUser) {
  try {
    console.log(idUser);
    const listBoard = await Board.find({
      owner: idUser
    });
    return listBoard;
  } catch (exception) {
    console.log("Error get all by idUSer", exception.message);
    return null;
  }
};

const getCoopBoardByIdUser = async function (idUser) {
  try {
    // const ownerId = mongoose.Types.ObjectId(idUser);
    const user = await User.findById({ _id: idUser });

    const listBoard = await Board.find({
      members: { $in: [user.email] }
    });
    return listBoard;
  } catch (exception) {
    console.log("Error get all by idUSer", exception.message);
    return null;
  }
};

const create = function ({ name, description, members, quantity, owner }) {
  try {
    const newBoard = new Board({
      name,
      description,
      quantity,
      owner,
      members
    });
    newBoard.save();
    return newBoard;
  } catch (exception) {
    return null;
  }
};

const addMembers = async function (id, members) {
  try {
    const exists = await User.findOne({ email: members });
    if (!exists) {
      throw new Error("Không thấy người dùng có mail trong hệ thống!");
    }
    console.log(members);

    await Board.updateOne(
      { _id: id },
      {
        $addToSet: { members: members }, // Use $addToSet to avoid duplicates
        $inc: { quantity: 1 } // Increment quantity by 1
      }
    );
    const board = await Board.findById({
      _id: id
    });
    await Noti.create({
      userId: exists._id,
      title: "Thêm vào bảng mới",
      description: `Bạn đã được thêm vào bảng ${board.name}`
    });

    return board;
  } catch (exception) {
    console.log(exception.message);
    return null;
  }
};

const removeMembers = async function (id, members) {
  try {
    const update = await Board.updateOne(
      { _id: id },
      {
        $pullAll: {
          members: members
        }
      }
    ).exec();
    const Board = await Board.findById({
      _id: id
    });
    return Board;
  } catch (exception) {
    console.log(exception.message);
    return null;
  }
};

const updateById = async function (id, { name, description, quantity }) {
  try {
    console.log({ name, description, quantity });
    console.log(id);

    // Update the board with the new name, description, and quantity
    await Board.updateOne({ _id: id }, { name, description, quantity });

    // Find the updated board by its ID
    const updatedBoard = await Board.findById(id);
    console.log(updatedBoard);

    return updatedBoard;
  } catch (exception) {
    console.error("Error updating board:", exception);
    return null;
  }
};

const deleteById = async function (id) {
  try {
    const result = await Board.deleteOne({
      _id: id
    });
    console.log(result);
    return result;
  } catch (exception) {
    console.log(exception.message);
    return false;
  }
};
const getAll = async function () {
  try {
    // Truy vấn tất cả các board từ cơ sở dữ liệu
    const listBoard = await Board.find({});
    return listBoard;
  } catch (exception) {
    console.log("Error get all boards:", exception.message);
    return null;
  }
};
// router.get("/:id/members", async (req, res) => {
//   try {
//     const members = await boardServices.getMembersByBoardId(req.params.id);
//     if (!members) {
//       return res.status(404).json({
//         message: "Board không tồn tại hoặc không có thành viên.",
//         data: {}
//       });
//     }

//     res.status(200).json({
//       message: "Lấy danh sách thành viên thành công.",
//       data: { members }
//     });
//   } catch (exception) {
//     res.status(400).json({
//       message: "Không thể lấy danh sách thành viên.",
//       error: exception.message,
//       data: {}
//     });
//   }
// });

const getMembersByBoardId = async (boardId) => {
  // if (!mongoose.Types.ObjectId.isValid(boardId)) {
  //   throw new Error('Invalid boardId format');
  // }

  // try {
  const members = await Member.find({ boardId });
  if (!members) {
    // throw new Error('No members found for this board');
  }
  console.log("members:", members);
  return members;
  // } catch (error) {
  //   throw new Error(`Error fetching members: ${error.message}`);
  // }
};

export default {
  getById,
  getAllByIdUser,
  getCoopBoardByIdUser,
  addMembers,
  removeMembers,
  create,
  updateById,
  deleteById,
  getAll,
  getMembersByBoardId
};
