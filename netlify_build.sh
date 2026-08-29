#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.5}"
FLUTTER_DIR="${PWD}/.netlify/flutter"

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  mkdir -p "$(dirname "${FLUTTER_DIR}")"
  git clone \
    --depth 1 \
    --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git \
    "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter config --enable-web
flutter pub get

flutter build web \
  --release \
  --dart-define="SUPABASE_URL=${SUPABASE_URL}" \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY}" \
  --dart-define="SENTRY_DSN=${SENTRY_DSN:-}"

# Flutter owns the application output. These serverless-hosted static pages
# are copied explicitly so legal URLs remain available outside the SPA router.
mkdir -p build/web/legal
cp -R web/legal/. build/web/legal/
for static_directory in privacy terms delete-account cs; do
  mkdir -p "build/web/${static_directory}"
  cp -R "web/${static_directory}/." "build/web/${static_directory}/"
done

if [[ -n "${SENTRY_AUTH_TOKEN:-}" ]]; then
  dart run sentry_dart_plugin
fi
