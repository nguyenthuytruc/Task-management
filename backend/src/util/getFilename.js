// getFilename.js

// Hàm lấy phần mở rộng file từ mimeType
const getFileExtFromMimeType = (mimeType) => {
  switch (mimeType) {
    case "image/jpeg":
      return ".jpeg";
    case "image/png":
      return ".png";
    case "text/plain":
      return ".txt";
    case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
      return ".docx";
    default:
      return "";
  }
};

// Hàm tạo tên file dựa trên mimeType
export const getFilename = (fileName) => {
  return Date.now() + "_" + fileExt;
};
