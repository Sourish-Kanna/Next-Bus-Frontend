#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# 1. Setup Flutter
# We use --depth 1 to make the clone fast (shallow clone).
if [ -d "flutter" ]; then
    echo "Flutter directory found. Updating..."
    cd flutter
    git fetch && git checkout stable && git pull
    cd ..
else
    echo "Cloning Flutter (Stable)..."
    # OPTIMIZATION: --depth 1 saves significant time and bandwidth
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 --single-branch
fi

# 2. Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Diagnostic Info (Optional, helps debug logs)
echo "Flutter version:"
flutter --version

# 4. Run the Build
echo "Building Flutter Web..."

# Note: Ensure $API_LINK is set in your Netlify Environment Variables
flutter build web --release \
  --web-renderer auto \
  --wasm \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=API_LINK="$API_LINK"

echo "Build successful!"