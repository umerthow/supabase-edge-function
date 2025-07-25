#!/bin/bash
# Script to flatten directory structure for Supabase Edge Functions deployment

set -e # Exit on error

FUNCTION_NAME="users-api"
ORIGINAL_DIR="supabase/functions/${FUNCTION_NAME}"
BACKUP_DIR="/tmp/backup-${FUNCTION_NAME}"

echo "🔧 Creating backup of original function..."

# Create backup directory
rm -rf "${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

# Backup all files
cp -r "${ORIGINAL_DIR}"/* "${BACKUP_DIR}/"

echo "📁 Finding all TypeScript files in subdirectories..."
TYPESCRIPT_FILES=$(find "${ORIGINAL_DIR}" -name "*.ts" -not -path "${ORIGINAL_DIR}/index.ts")

for file in ${TYPESCRIPT_FILES}; do
  filename=$(basename "$file")
  dirname=$(dirname "$file")
  parent_dir=$(basename "$dirname")
  
  # Create a unique filename based on the directory structure
  flat_filename="${parent_dir}_${filename}"
  
  echo "📄 Processing: $file -> ${ORIGINAL_DIR}/${flat_filename}"
  
  # Copy the file with the new flattened name to original directory
  cp "$file" "${ORIGINAL_DIR}/${flat_filename}"
done

# Update imports in all files
echo "🔄 Updating imports in all files..."

# First, update the main index.ts
sed -i.bak "s|from \"@/config/env\"|from \"./config_env\"|g" "${ORIGINAL_DIR}/index.ts"
sed -i.bak "s|from \"@/routes/user\"|from \"./routes_user.routes\"|g" "${ORIGINAL_DIR}/index.ts"
sed -i.bak "s|from \"@/controllers/user\"|from \"./controllers_user.controller\"|g" "${ORIGINAL_DIR}/index.ts"

# Then update all other files
for file in ${ORIGINAL_DIR}/*.ts; do
  echo "Updating imports in $file"
  
  # Replace path alias imports with flat imports
  sed -i.bak "s|from \"@/config/env\"|from \"./config_env\"|g" "$file"
  sed -i.bak "s|from \"@/routes/user\"|from \"./routes_user.routes\"|g" "$file"
  sed -i.bak "s|from \"@/controllers/user\"|from \"./controllers_user.controller\"|g" "$file"
  sed -i.bak "s|from \"@/middleware/auth\"|from \"./middleware_auth.middleware\"|g" "$file"
  sed -i.bak "s|from \"@/services/user\"|from \"./services_user.service\"|g" "$file"
  sed -i.bak "s|from \"@/lib/client\"|from \"./lib_client\"|g" "$file"
  
  # Replace relative imports
  sed -i.bak "s|from \"\\.\\.\/lib/client\"|from \"./lib_client\"|g" "$file"
  sed -i.bak "s|from \"\\.\\./config/env\"|from \"./config_env\"|g" "$file"
  sed -i.bak "s|from \"\\.\\./middleware/auth\"|from \"./middleware_auth.middleware\"|g" "$file"
  sed -i.bak "s|from \"\\.\\./controllers/user\"|from \"./controllers_user.controller\"|g" "$file"
  sed -i.bak "s|from \"\\.\\./services/user\"|from \"./services_user.service\"|g" "$file"
done

# Copy deno.json without import mappings
echo "📝 Creating simplified deno.json..."
cat > "${ORIGINAL_DIR}/deno.json" << EOF
{
  "imports": {
    "@std/assert": "jsr:@std/assert@1",
    "@std/dotenv": "jsr:@std/dotenv@^0.225.0",
    "hono": "jsr:@hono/hono@^4.6.11",
    "hono/logger": "jsr:@hono/hono@^4.6.11/logger",
    "hono/cors": "jsr:@hono/hono@^4.6.11/cors",
    "hono/body-limit": "jsr:@hono/hono@^4.6.11/body-limit",
    "hono/jwt": "jsr:@hono/hono@^4.6.11/jwt",
    "@supabase/supabase-js": "https://esm.sh/@supabase/supabase-js@2.1.0"
  },
  "compilerOptions": {
    "lib": ["deno.window"],
    "strict": true
  }
}
EOF

# Remove subdirectories (after copying their contents)
echo "🗑️ Removing subdirectories as they're no longer needed..."
find "${ORIGINAL_DIR}" -mindepth 1 -type d -exec rm -rf {} +

# Clean up backup files
rm -f "${ORIGINAL_DIR}"/*.bak

echo "📋 Flattened files in original directory:"
ls -la "${ORIGINAL_DIR}"

echo "🚀 Ready to deploy from ${ORIGINAL_DIR}"
echo "Run the following command to deploy:"
echo "cd ${ORIGINAL_DIR} && npx supabase functions deploy ${FUNCTION_NAME} --no-verify-jwt"
echo ""
echo "To restore the original structure, run:"
echo "rm -rf ${ORIGINAL_DIR}/* && cp -r ${BACKUP_DIR}/* ${ORIGINAL_DIR}/"
