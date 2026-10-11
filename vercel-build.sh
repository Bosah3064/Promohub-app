#!/bin/bash
set -e

echo "========================================="
echo " PromoHub Flutter Web - Vercel Build Pipeline"
echo "========================================="

# 1. Ensure .env exists to prevent Flutter asset bundling failure
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    echo ">> [1/5] Creating .env from .env.example..."
    cp .env.example .env
  else
    echo ">> [1/5] Creating placeholder .env..."
    touch .env
  fi
else
  echo ">> [1/5] Existing .env file found."
fi

# Populate .env with any environment variables set in Vercel project settings
env_vars=(
  "SUPABASE_URL"
  "SUPABASE_ANON_KEY"
  "MPESA_CONSUMER_KEY"
  "MPESA_CONSUMER_SECRET"
  "MPESA_SHORTCODE"
  "MPESA_PASSKEY"
  "MPESA_ENVIRONMENT"
  "STRIPE_PUBLISHABLE_KEY"
  "STRIPE_SECRET_KEY"
)

for var in "${env_vars[@]}"; do
  val="${!var}"
  if [ -n "$val" ]; then
    echo ">> Injected environment variable: $var"
    # Remove existing key if present, then append new value
    sed -i "/^${var}=/d" .env 2>/dev/null || true
    echo "${var}=${val}" >> .env
  fi
done

# 2. Check or install Flutter SDK
echo ">> [2/5] Setting up Flutter SDK..."
git config --global --add safe.directory "*" 2>/dev/null || true

if command -v flutter &> /dev/null; then
  echo "Flutter is already installed in the system PATH."
else
  FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
  if [ ! -d "flutter" ]; then
    echo "Cloning Flutter SDK (version: $FLUTTER_VERSION)..."
    git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git
  else
    echo "Reusing existing Flutter directory."
  fi
  export PATH="$PWD/flutter/bin:$PATH"
fi

# Print Flutter version info
echo ">> [3/5] Flutter version:"
flutter --version

# 3. Enable Web support and disable analytics to speed up build
echo ">> [4/5] Enabling Flutter Web..."
flutter config --enable-web --no-analytics

# 4. Resolve dependencies
echo ">> [5/5] Fetching Flutter dependencies..."
flutter pub get

# 5. Build Flutter Web release
echo ">> Building Flutter Web release bundle..."
flutter build web --release

# 6. Verify build output
if [ -f "build/web/index.html" ]; then
  echo "========================================="
  echo " Build Succeeded! Web output ready in build/web/"
  echo "========================================="
else
  echo "ERROR: build/web/index.html not found after build!"
  exit 1
fi
