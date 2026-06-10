#!/usr/bin/env bash
# Auto-compile when source files change. Wokwi auto-restarts when PlatformIO firmware changes.
set -u

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_NAME="${ENV_NAME:-esp32dev}"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-2}"
ONCE="${ONCE:-0}"

compile_project() {
  echo "=== Compiling PlatformIO env: $ENV_NAME ==="
  if pio run -e "$ENV_NAME"; then
    echo "=== OK ==="
  else
    echo "=== FAIL ==="
  fi
  echo ""
}

snapshot_sources() {
  local files=(
    "$PROJECT_DIR/platformio.ini"
    "$PROJECT_DIR/src/main.cpp"
    "$PROJECT_DIR/unor4_u8g2_test.ino"
    "$PROJECT_DIR/_50_percent_48_48_14f.h"
    "$PROJECT_DIR/flow_32_32_7f.h"
  )

  if stat --help >/dev/null 2>&1; then
    # GNU stat (Linux, Git Bash, MSYS2)
    stat -c '%n:%Y' "${files[@]}" 2>/dev/null
  else
    # BSD stat (macOS)
    stat -f '%N:%m' "${files[@]}" 2>/dev/null
  fi
}

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI is required but pio was not found in PATH"
  exit 1
fi

echo "Watching $PROJECT_DIR for source changes..."
echo "ENV_NAME=$ENV_NAME (override with: ENV_NAME=esp32dev ./watch.sh)"
echo "Press Ctrl+C to stop"
echo ""

compile_project

if [[ "$ONCE" == "1" ]]; then
  exit 0
fi

if command -v fswatch >/dev/null 2>&1; then
  LAST=0
  PREV_STATE="$(snapshot_sources)"
  fswatch -0 "$PROJECT_DIR" | while IFS= read -r -d '' file; do
    case "$file" in
      "$PROJECT_DIR/src/"*|"$PROJECT_DIR/platformio.ini"|"$PROJECT_DIR/unor4_u8g2_test.ino"|"$PROJECT_DIR/"*.h) ;;
      *) continue ;;
    esac

    CUR_STATE="$(snapshot_sources)"
    if [[ "$CUR_STATE" == "$PREV_STATE" ]]; then
      continue
    fi
    NOW=$(date +%s)
    if (( NOW - LAST < DEBOUNCE_SECONDS )); then
      sleep $((DEBOUNCE_SECONDS - (NOW - LAST)))
      CUR_STATE="$(snapshot_sources)"
      if [[ "$CUR_STATE" == "$PREV_STATE" ]]; then
        continue
      fi
    fi
    PREV_STATE="$CUR_STATE"
    LAST=$(date +%s)
    echo "=== Changed: ${file#$PROJECT_DIR/} ==="
    compile_project
    PREV_STATE="$(snapshot_sources)"
  done
else
  echo "fswatch not found, using polling fallback (1s interval)"
  PREV_STATE="$(snapshot_sources)"
  while true; do
    sleep 1
    CUR_STATE="$(snapshot_sources)"
    if [[ "$CUR_STATE" != "$PREV_STATE" ]]; then
      PREV_STATE="$CUR_STATE"
      echo "=== Changed: source file(s) ==="
      compile_project
    fi
  done
fi
