import { Hono } from "hono";
import { UserController } from "../controllers/user.controller.ts";
import { authMiddleware } from "../middleware/auth.middleware.ts";

const userRoutes = new Hono();

// Public routes (no authentication required)
userRoutes.post("/register", UserController.register);
userRoutes.post("/login", UserController.login);

// Protected routes (authentication required)
userRoutes.use("/profile", authMiddleware);
userRoutes.get("/profile", UserController.getProfile);

userRoutes.use("/logout", authMiddleware);
userRoutes.post("/logout", UserController.logout);

// Admin route (protected)
userRoutes.use("/", authMiddleware);
userRoutes.get("/", UserController.getAllUsers);

export default userRoutes;
