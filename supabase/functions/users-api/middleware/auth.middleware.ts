import { type Context, type Next } from "hono";
import { supabase } from "../lib/client.ts";

export async function authMiddleware(c: Context, next: Next) {
  try {
    const authHeader = c.req.header("Authorization");
    
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return c.json(
        { 
          success: false, 
          error: "Authorization header required" 
        }, 
        401
      );
    }

    const token = authHeader.replace("Bearer ", "");

    // Verify the token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return c.json(
        { 
          success: false, 
          error: "Invalid or expired token" 
        }, 
        401
      );
    }

    // Set the user in the context for use in handlers
    c.set("user", user);
    c.set("token", token);

    await next();
  } catch (_error) {
    return c.json(
      { 
        success: false, 
        error: "Authentication failed" 
      }, 
      401
    );
  }
}
