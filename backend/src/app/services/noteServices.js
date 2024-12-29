import Notes from "../entity/Note.js";
const getById = async function (id) {
  try {
    const existsNotes = await Notes.findOne({ _id: id });
    return existsNotes;
  } catch (exception) {
    console.error("Error fetching note by ID:", exception);
    return null;
  }
};
// Lấy tất cả list có idBoard trùng với id Board truyền vào
const getAllByIdBoard = async function (idBoard) {
  try {
    console.log(idBoard);

    const notes = await Notes.find({
      board: idBoard
    });
    return notes;
  } catch (exception) {
    console.log("Error get all Note by Board", exception.message);
    return null;
  }
};
const getAllByIdUser = async function (idUser) {
  try {
    const notes = await Notes.find({ createdBy: idUser });
    return notes;
  } catch (exception) {
    console.error("Error fetching notes by user ID:", exception);
    return [];
  }
};

const getAll = async function () {
  try {
    const notes = await Notes.find();
    return notes;
  } catch (exception) {
    console.error("Error fetching all notes:", exception);
    return [];
  }
};
// Tạo note trong database
const create = function ({
  name,
  description,
  type,
  createdAt,
  updatedAt,
  createdBy,
  boardId
}) {
  try {
    const newNote = new Notes({
      name,
      description,
      type,
      isPinned: false,
      createdAt,
      updatedAt,
      createdBy,
      board: boardId
    });
    newNote.save();
    return newNote;
  } catch (exception) {
    console.log(exception);

    return null;
  }
};

// update status
const updateStatus = async function (id) {
  try {
    // Tìm note hiện tại dựa trên ID
    const note = await Notes.findById(id);
    if (!note) {
      return res.status(404).json({ message: "Note not found" });
    }

    // Đảo ngược trạng thái `isPinned`
    note.isPinned = !note.isPinned;

    // Lưu thay đổi vào database
    const updatedNote = await note.save();

    return updatedNote;
  } catch (exception) {
    console.error("Error updating status:", exception);
    return null;
  }
};
const updateById = async function (
  id,
  { name, description, type, isPinned, createdAt, updatedAt, userId, boardId }
) {
  try {
    const update = await Notes.updateOne(
      { _id: id },
      {
        name,
        description,
        type,
        isPinned,
        createdAt,
        updatedAt,
        userId,
        boardId
      }
    );
    if (update.matchedCount === 0) {
      console.log("No Note found with the provided ID.");
      return null;
    }
    const updateNote = await Notes.findById({
      _id: id
    });

    return updateNote;
  } catch (exception) {
    console.error("Error updating Notes:", exception);
    return null;
  }
};

const deleteById = async function (id) {
  try {
    const result = await Notes.deleteOne({
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
  getById,
  getAllByIdBoard,
  getAllByIdUser,
  getAll,
  create,
  updateStatus,
  updateById,
  deleteById
};
