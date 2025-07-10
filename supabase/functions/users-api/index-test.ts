// Simple test version
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => c.json({ 
  message: "Simple test version working", 
  timestamp: new Date().toISOString() 
}));

app.get("/health", (c) => c.json({ 
  status: "ok", 
  timestamp: new Date().toISOString() 
}));

Deno.serve(app.fetch);
