import { load } from "@std/dotenv";

// Load environment variables from .env file
export async function loadEnv() {
  try {
    const env = await load();
    // Set environment variables for the process
    for (const [key, value] of Object.entries(env)) {
      Deno.env.set(key, value);
    }

    console.log("✅ Environment variables loaded successfully");
  } catch (error: unknown) {
    if (error && typeof error === "object" && "message" in error) {
      console.warn(
        "⚠️  Warning: Could not load .env file:",
        (error as { message?: string }).message,
      );
    } else {
      console.warn("⚠️  Warning: Could not load .env file:", error);
    }
    console.log("Make sure you have a .env file in your project root");
  }
}
