#!/bin/bash
# Script to clean cache and force deploy edge function

echo "Cleaning Deno and Supabase caches..."
rm -f supabase/functions/users-api/deno.lock
rm -rf ~/.cache/deno
rm -rf ~/.cache/supabase
rm -rf .supabase

echo "Verifying deno.json exists and is valid..."
ls -la supabase/functions/users-api/deno.json
cat supabase/functions/users-api/deno.json

echo "Deploying edge function with import map..."
# First, make sure we're in the project root
cd "$(dirname "$0")/.."

# Copy deno.json to ensure it's included in deployment
cp supabase/functions/users-api/deno.json .

# Deploy with explicit import map
cd supabase/functions/users-api
npx supabase functions deploy users-api --no-verify-jwt --import-map=deno.json --debug

echo "Deployment complete!"
