import jwt from "jsonwebtoken";
export default function checkToken(req, res, next) {
  if (
    req.url.toLowerCase() == "/api/auth/login" ||
    req.url.toLowerCase() == "/api/auth/register"
  ) {
    next();
    return;
  }

  try {
    const token = req.headers?.authorization.split(" ")[1];
    const jwtObject = jwt.verify(token, process.env.JWT_SECRET);

    const isExpired = Date.now() >= jwtObject.exp * 1000;

    if (isExpired) {
      res.status(400).json({
        message: "Token is expired"
      });
    } else {
      next();
    }
  } catch (exception) {
    res.status(401).json({
      message: "Error authentication"
    });
  }
}
