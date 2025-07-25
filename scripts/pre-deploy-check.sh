#!/bin/bash
# Pre-deployment check for Supabase Edge Functions
# This script verifies that the function directory is properly set up before deployment

cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)
FUNCTION_DIR="$PROJECT_ROOT/supabase/functions/users-api"

echo "🔍 Performing pre-deployment checks for Supabase Edge Function..."

# Check if deno.json exists
if [ ! -f "$FUNCTION_DIR/deno.json" ]; then
  echo "❌ ERROR: deno.json not found at $FUNCTION_DIR/deno.json"
  exit 1
else
  echo "✅ deno.json found"
  echo "Content:"
  cat "$FUNCTION_DIR/deno.json"
  echo ""
fi

# Check for index.ts
if [ ! -f "$FUNCTION_DIR/index.ts" ]; then
  echo "❌ ERROR: index.ts not found at $FUNCTION_DIR/index.ts"
  exit 1
else
  echo "✅ index.ts found"
fi

# Validate deno.json with deno
echo "🔧 Validating deno.json..."
cd "$FUNCTION_DIR"
deno --version
deno check --config=deno.json index.ts

if [ $? -eq 0 ]; then
  echo "✅ Deno validation passed"
else
  echo "❌ Deno validation failed"
  exit 1
fi

echo "🚀 Pre-deployment check complete - Ready to deploy!"
