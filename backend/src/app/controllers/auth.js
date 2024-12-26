import { body, validationResult } from "express-validator";
import userServices from "../services/userServices.js";
import Result from "../common/Result.js";

const login = async (req, res) => {
  const { email, password } = req.body;

  console.log(email, password);

  const userExists = await userServices.login({ email, password });

  if (userExists != null) {
    res
      .status(200)
      .json(new Result({ user: userExists }, "Login success", true));
  } else {
    res
      .status(400)
      .json(
        new Result(null, "Sai mật khẩu hoặc email, Vui lòng nhập lại!", false)
      );
  }
};
const register = async (req, res) => {
  const err = validationResult(req);
  if (!err.isEmpty()) {
    return res.status(400).json({
      message: `Has error`
    });
  }
  const { email, username, password } = req.body;
  console.log({ email, username, password });
  const userExists = await userServices.getByEmail(email);
  if (userExists) {
    return res.status(400).json(new Result(null, "Mail đã tồn tại!", false));
  }
  const register = await userServices.register({
    email,
    username,
    password
  });

  if (register) {
    return res
      .status(200)
      .json(
        new Result({ token: register.token }, "Register successful !", true)
      );
  } else {
    return res.status(500).json(new Result(null, "Register failed", false));
  }
};

export default { login, register };
