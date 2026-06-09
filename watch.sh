#!/usr/bin/env bash
# Auto-compile when source files change. Wokwi auto-restarts when .hex/.elf changes.
set -u

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SKETCH_FILE="$PROJECT_DIR/unor4_u8g2_test.ino"
FQBN="${FQBN:-arduino:avr:uno}"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-2}"
ONCE="${ONCE:-0}"

compile_sketch() {
  local build_key
  local build_path
  build_key="$(printf '%s' "$FQBN" | tr ':,/' '_')"
  build_path="$PROJECT_DIR/.arduino-build/$build_key"
  mkdir -p "$BUILD_DIR" "$build_path"

  echo "=== Compiling ($FQBN)... ==="
  if arduino-cli compile \
    --fqbn "$FQBN" \
    --build-path "$build_path" \
    --output-dir "$BUILD_DIR" \
    "$PROJECT_DIR"; then
    echo "=== OK ==="
  else
    echo "=== FAIL ==="
  fi
  echo ""
}

snapshot_sources() {
  if stat --help >/dev/null 2>&1; then
    # GNU stat (Linux, Git Bash, MSYS2)
    stat -c '%n:%Y' "$SKETCH_FILE"
  else
    # BSD stat (macOS)
    stat -f '%N:%m' "$SKETCH_FILE"
  fi
}

if ! command -v arduino-cli >/dev/null 2>&1; then
  echo "arduino-cli is required but not found in PATH"
  exit 1
fi

echo "Watching $PROJECT_DIR for source changes..."
echo "FQBN=$FQBN (override with: FQBN=arduino:renesas_uno:minima ./watch.sh)"
echo "Press Ctrl+C to stop"
echo ""

compile_sketch

if [[ "$ONCE" == "1" ]]; then
  exit 0
fi

if command -v fswatch >/dev/null 2>&1; then
  LAST=0
  PREV_STATE="$(snapshot_sources)"
  fswatch -0 "$PROJECT_DIR" | while IFS= read -r -d '' file; do
    [[ "$file" == "$SKETCH_FILE" ]] || continue

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
    echo "=== Changed: $(basename "$file") ==="
    compile_sketch
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
      compile_sketch
    fi
  done
fi
