// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { type Context, Hono } from "hono";
import { logger } from "hono/logger";
import { cors } from "hono/cors";
import { bodyLimit } from "hono/body-limit";

// Import directly without relying on path aliases
import { loadEnv } from "./config/env.ts";

// Load environment variables first (only in local development)
try {
  await loadEnv();
} catch (error) {
  console.log("Environment loading skipped (likely in production):", error);
}

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
app.get("/users-api", (c: Context) =>
  c.json({
    message: "Deno Hono API on Supabase Edge Functions (Direct Imports)",
    timestamp: new Date().toISOString(),
  }));

app.get("/users-api/health", (c: Context) =>
  c.json({
    status: "ok",
    timestamp: new Date().toISOString(),
  }));

// Handle all requests
Deno.serve(app.fetch);
