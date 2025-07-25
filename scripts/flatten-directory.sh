#!/bin/bash
# Script to flatten directory structure and deploy to Supabase Edge Functions

set -e # Exit on error

FUNCTION_NAME="users-api"
ORIGINAL_DIR="supabase/functions/${FUNCTION_NAME}"
TEMP_DIR="/tmp/flattened-${FUNCTION_NAME}"

echo "🔧 Flattening directory structure for ${FUNCTION_NAME}..."

# Create clean temp directory
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"

# Copy main file
cp "${ORIGINAL_DIR}/index.ts" "${TEMP_DIR}/"

# Find all typescript files in subdirectories
echo "📁 Finding all TypeScript files in subdirectories..."
TYPESCRIPT_FILES=$(find "${ORIGINAL_DIR}" -name "*.ts" -not -path "${ORIGINAL_DIR}/index.ts")

for file in ${TYPESCRIPT_FILES}; do
  filename=$(basename "$file")
  dirname=$(dirname "$file")
  parent_dir=$(basename "$dirname")
  
  # Create a unique filename based on the directory structure
  flat_filename="${parent_dir}_${filename}"
  
  echo "📄 Processing: $file -> ${TEMP_DIR}/${flat_filename}"
  
  # Copy the file with the new flattened name
  cp "$file" "${TEMP_DIR}/${flat_filename}"
done

# Update imports in all files
echo "🔄 Updating imports in all files..."

# First, update the main index.ts
sed -i.bak "s|from \"@/config/env\"|from \"./config_env\"|g" "${TEMP_DIR}/index.ts"
sed -i.bak "s|from \"@/routes/user\"|from \"./routes_user.routes\"|g" "${TEMP_DIR}/index.ts"
sed -i.bak "s|from \"@/controllers/user\"|from \"./controllers_user.controller\"|g" "${TEMP_DIR}/index.ts"

# Then update all other files
for file in ${TEMP_DIR}/*.ts; do
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
cat > "${TEMP_DIR}/deno.json" << EOF
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

# Clean up backup files
rm -f "${TEMP_DIR}"/*.bak

echo "📋 Flattened files:"
ls -la "${TEMP_DIR}"

echo "🚀 Ready to deploy from ${TEMP_DIR}"
echo "Run the following command to deploy:"
echo "cd ${TEMP_DIR} && npx supabase functions deploy ${FUNCTION_NAME} --no-verify-jwt"
