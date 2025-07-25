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

echo "Deploying edge function with force flag and including deno.json..."
cd supabase/functions/users-api
npx supabase functions deploy users-api --force --include-file deno.json

echo "Deployment complete!"
