#!/usr/bin/env sh
# Membuat paket SCORM 1.2 siap unggah ke LMS: dist/simulasi-pr-po-robot-scorm12.zip
# Jalankan dari root repo:  sh scorm/build-scorm.sh
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
cp "$ROOT/simulasi-pr-po-robot.html" "$TMP/index.html"
cp "$ROOT/scorm/imsmanifest.xml" "$TMP/imsmanifest.xml"
mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/simulasi-pr-po-robot-scorm12.zip"
rm -f "$OUT"
# imsmanifest.xml harus berada di root ZIP (bukan di dalam folder)
(cd "$TMP" && zip -q -X "$OUT" imsmanifest.xml index.html)
rm -rf "$TMP"
echo "Paket dibuat: $OUT"
