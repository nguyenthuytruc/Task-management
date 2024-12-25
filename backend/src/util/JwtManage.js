import jwt from "jsonwebtoken";
const JWT_SECRET = "This is a secret key";
const generateToken = function (userExists) {
  return jwt.sign(
    {
      username: userExists.username,
      _id: userExists.id,
      email: userExists.email
    },
    JWT_SECRET,
    {
      //expiresIn: '60', // 1 minutes
      expiresIn: "10 days"
    }
  );
};

export default { generateToken };
