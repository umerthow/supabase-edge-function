// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { type Context, Hono } from "hono";
import { logger } from "hono/logger";
import { cors } from "hono/cors";
import { bodyLimit } from "hono/body-limit";

import { loadEnv } from "./config/env.ts";

// Load environment variables first
await loadEnv();

// Then import modules that depend on environment variables
import userRoutes from "./routes/user.routes.ts";
const app = new Hono();

// Middleware
app.use("*", logger());
app.use(
  "*",
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
  }),
);
app.use(
  "*",
  bodyLimit({
    maxSize: 1024 * 1024, // 1MB
  }),
);

// Routes
app.get("/", (c: Context) =>
  c.json({
    message: "Deno Hono API on Supabase Edge Functions",
    timestamp: new Date().toISOString(),
  }));

app.get("/health", (c: Context) =>
  c.json({
    status: "ok",
    timestamp: new Date().toISOString(),
  }));

// User routes
app.route("/users", userRoutes);

// Handle all requests
Deno.serve({
  port:9000
}, app.fetch);
