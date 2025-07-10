import { Context } from "hono";
import {
  UserLoginData,
  UserRegistrationData,
  UserService,
} from "../services/user.service.ts";

export class UserController {
  static async register(c: Context) {
    try {
      const body = await c.req.json() as UserRegistrationData;

      // Validate required fields
      if (!body.email || !body.password) {
        return c.json(
          {
            success: false,
            error: "Email and password are required",
          },
          400,
        );
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(body.email)) {
        return c.json(
          {
            success: false,
            error: "Invalid email format",
          },
          400,
        );
      }

      // Validate password length
      if (body.password.length < 6) {
        return c.json(
          {
            success: false,
            error: "Password must be at least 6 characters long",
          },
          400,
        );
      }

      const result = await UserService.register(body);

      if (!result.success) {
        return c.json(result, 400);
      }

      return c.json(result, 201);
    } catch (_error) {
      return c.json(
        {
          success: false,
          error: "Invalid request body",
        },
        400,
      );
    }
  }

  static async login(c: Context) {
    try {
      const body = await c.req.json() as UserLoginData;

      // Validate required fields
      if (!body.email || !body.password) {
        return c.json(
          {
            success: false,
            error: "Email and password are required",
          },
          400,
        );
      }

      const result = await UserService.login(body);

      if (!result.success) {
        return c.json(result, 401);
      }

      return c.json(result, 200);
    } catch (_error) {
      return c.json(
        {
          success: false,
          error: "Invalid request body",
        },
        400,
      );
    }
  }

  static async logout(c: Context) {
    try {
      const authHeader = c.req.header("Authorization");
      const accessToken = authHeader?.replace("Bearer ", "") || "";

      const result = await UserService.logout(accessToken);

      if (!result.success) {
        return c.json(result, 400);
      }

      return c.json(result, 200);
    } catch (_error) {
      return c.json(
        {
          success: false,
          error: "Logout failed",
        },
        500,
      );
    }
  }

  static async getProfile(c: Context) {
    try {
      const user = c.get("user");

      if (!user) {
        return c.json(
          {
            success: false,
            error: "User not found",
          },
          404,
        );
      }

      const result = await UserService.getProfile(user.id);

      if (!result.success) {
        return c.json(result, 404);
      }

      return c.json(result, 200);
    } catch (_error) {
      return c.json(
        {
          success: false,
          error: "Failed to get profile",
        },
        500,
      );
    }
  }

  static async getAllUsers(c: Context) {
    try {
      const result = await UserService.getAllUsers();

      if (!result.success) {
        return c.json(result, 500);
      }

      return c.json(result, 200);
    } catch (_error) {
      return c.json(
        {
          success: false,
          error: "Failed to get users",
        },
        500,
      );
    }
  }
}
