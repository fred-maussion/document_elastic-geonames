#!/usr/bin/env bash
# Step 3 - Download GeoNames cities500 and bulk-load it into geonames-city-lookup.
#
#   export ES_URL="https://<your-es-endpoint>"
#   export ES_API_KEY="<base64 api key with write on geonames-city-lookup>"
#   ./03-load-geonames.sh
#
# Rows are sorted by ascending population and loaded sequentially, so for duplicate
# (city, country) keys the most populated one is written last and wins (_id = ascii key).
# Requires: curl, unzip, jq.
set -euo pipefail

: "${ES_URL:?set ES_URL}"
: "${ES_API_KEY:?set ES_API_KEY}"
DATASET="${DATASET:-cities500}"   # cities500 | cities1000 | cities5000 | cities15000
CHUNK_LINES="${CHUNK_LINES:-5000}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "Downloading $DATASET ..."
curl -kfsSL "https://download.geonames.org/export/dump/${DATASET}.zip" -o "$WORK/${DATASET}.zip"
unzip -q "$WORK/${DATASET}.zip" -d "$WORK"

echo "Sorting by population (column 15) ascending ..."
LC_ALL=C sort -t $'\t' -k15,15n "$WORK/${DATASET}.txt" > "$WORK/sorted.txt"

mkdir "$WORK/chunks"
split -l "$CHUNK_LINES" "$WORK/sorted.txt" "$WORK/chunks/part_"

for f in "$WORK"/chunks/part_*; do
  jq -c -R '({"index":{}}, {message: .})' "$f" > "$f.ndjson"
  resp="$(curl -kfsS -X POST "$ES_URL/geonames-city-lookup/_bulk?pipeline=geonames-city-lookup-parse" \
    -H "Authorization: ApiKey $ES_API_KEY" \
    -H "Content-Type: application/x-ndjson" \
    --data-binary "@$f.ndjson")"
  if [ "$(jq -r '.errors' <<<"$resp")" = "true" ]; then
    echo "Errors in $(basename "$f"):" >&2
    jq -c '[.items[] | select(.index.error)] | .[0:3]' <<<"$resp" >&2
    exit 1
  fi
  echo "Loaded $(basename "$f")"
done

curl -kfsS -X POST "$ES_URL/geonames-city-lookup/_refresh" -H "Authorization: ApiKey $ES_API_KEY" >/dev/null
echo "Done. Documents:"
curl -kfsS "$ES_URL/geonames-city-lookup/_count" -H "Authorization: ApiKey $ES_API_KEY"
echo
