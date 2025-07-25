#!/bin/bash
# Script to deploy using direct imports version (no path aliases)

echo "Cleaning Deno and Supabase caches..."
rm -f supabase/functions/users-api/deno.lock
rm -rf ~/.cache/deno
rm -rf ~/.cache/supabase
rm -rf .supabase

echo "Using direct imports version (no path aliases)..."

# First, backup the original index.ts
cp supabase/functions/users-api/index.ts supabase/functions/users-api/index.ts.bak

# Copy our direct imports version to index.ts
cp supabase/functions/users-api/index-direct-imports.ts supabase/functions/users-api/index.ts

echo "Deploying edge function without import map dependency..."
cd supabase/functions/users-api

# Check if we're running in CI/CD
if [ -n "$GITHUB_ACTIONS" ]; then
  # In GitHub Actions
  supabase functions deploy users-api --project-ref "$SUPABASE_PROJECT_REF" --no-verify-jwt --debug
else
  # Local development
  npx supabase functions deploy users-api --no-verify-jwt --debug
fi

# Restore the original index.ts
echo "Restoring original index.ts..."
cp supabase/functions/users-api/index.ts.bak supabase/functions/users-api/index.ts
rm supabase/functions/users-api/index.ts.bak

echo "Deployment complete!"
