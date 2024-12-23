import Board from "../entity/Board.js";
import User from "../entity/User.js";

const getById = async function (id) {
  try {
    const existsBoard = await Board.findOne({ _id: id });
    return existsBoard;
  } catch (exception) {
    console.log(exception);

    return null;
  }
};

const getAllByIdUser = async function (idUser) {
  try {
    // const ownerId = mongoose.Types.ObjectId(idUser);
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

const getAll = async function () {
  try {
    const listBoard = await Board.find({});
    return listBoard;
  } catch (exception) {
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
    const update = await Board.updateOne(
      { _id: id },
      {
        members,
        quantity: members.length + 1
      }
    );
    const board = await Board.findById({
      _id: id
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

    const update = await Board.updateOne(
      { _id: id },
      { name, description, quantity }
    );

    const Board = await Board.findById({
      _id: id
    });

    return Board;
  } catch (exception) {
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

export default {
  getAll,
  getById,
  getAllByIdUser,
  getCoopBoardByIdUser,
  addMembers,
  removeMembers,
  create,
  updateById,
  deleteById
};
