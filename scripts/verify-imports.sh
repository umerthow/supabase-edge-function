#!/bin/bash
# Script to verify all imports are using the correct path aliases

cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)
FUNCTION_DIR="$PROJECT_ROOT/supabase/functions/users-api"

echo "Verifying imports in the Edge Function..."

echo "1. Checking deno.json for path mappings..."
if [ ! -f "$FUNCTION_DIR/deno.json" ]; then
  echo "❌ ERROR: deno.json not found at $FUNCTION_DIR/deno.json"
  exit 1
else
  echo "✅ deno.json found"
  echo "Content:"
  cat "$FUNCTION_DIR/deno.json"
  echo ""
fi

echo "2. Checking files for relative imports that should use path aliases..."
FOUND_ISSUES=0

# Find all TypeScript files recursively
find "$FUNCTION_DIR" -name "*.ts" | while read -r FILE; do
  if grep -q "\.\./\|\./" "$FILE"; then
    RELATIVE_IMPORTS=$(grep -n "\.\./\|\./" "$FILE" | grep -v "from \"\." | grep "from ")
    if [ -n "$RELATIVE_IMPORTS" ]; then
      echo "❌ Found relative imports in $(basename "$FILE"):"
      echo "$RELATIVE_IMPORTS"
      FOUND_ISSUES=1
    fi
  fi
done

if [ $FOUND_ISSUES -eq 0 ]; then
  echo "✅ All files are using proper import aliases"
else
  echo "⚠️  Some files have relative imports. Consider updating them to use path aliases from deno.json."
fi

echo "3. Checking that deno.json imports are valid..."
cd "$FUNCTION_DIR"
echo "Running deno check on main file..."
deno check --config=deno.json index.ts || {
  echo "❌ Deno check failed!"
  exit 1
}

echo "✅ All imports check passed!"
echo "You're ready to deploy with proper imports and deno.json configuration."
