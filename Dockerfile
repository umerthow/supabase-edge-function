FROM denoland/deno:2.4.1

WORKDIR /app

# Copy the application files
COPY supabase/functions/users-api/ .

# Install dependencies
RUN deno cache index.ts

# Expose port
EXPOSE 9000

# Start the application
CMD ["deno", "run", "--allow-net", "--allow-env", "--allow-read", "index.ts"]
