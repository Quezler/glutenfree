# (cd ./mods_2.0/090_circuit-connector-placement-helper && sh generate_icons.sh)

# https://chatgpt.com/share/6811bb8e-ebbc-8007-bf64-68387350efd2

# Input spritesheets
IMG1="/Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/entity/circuit-connector/ccm-universal-04a-base-sequence.png"
IMG2="/Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/entity/circuit-connector/ccm-universal-04c-wire-sequence.png"

# Output directory
OUTDIR="graphics/icons"
mkdir -p "$OUTDIR"

# Temp directories
TMP1=$(mktemp -d)
TMP2=$(mktemp -d)

# Constants
COLUMNS=8
ROWS=5
FINAL_SIZE=64x64

# --- Step 1: Slice both spritesheets ---

# IMG1 tile size
WIDTH1=$(identify -format "%w" "$IMG1")
HEIGHT1=$(identify -format "%h" "$IMG1")
TILE_W1=$((WIDTH1 / COLUMNS))
TILE_H1=$((HEIGHT1 / ROWS))
magick "$IMG1" -crop ${TILE_W1}x${TILE_H1} +repage +adjoin "$TMP1/sprite_%02d.png"

# IMG2 tile size
WIDTH2=$(identify -format "%w" "$IMG2")
HEIGHT2=$(identify -format "%h" "$IMG2")
TILE_W2=$((WIDTH2 / COLUMNS))
TILE_H2=$((HEIGHT2 / ROWS))
magick "$IMG2" -crop ${TILE_W2}x${TILE_H2} +repage +adjoin "$TMP2/sprite_%02d.png"

# --- Step 2: Composite and output with transparent background ---

for i in $(seq -w 0 39); do
  BG="$TMP1/sprite_${i}.png"
  FG="$TMP2/sprite_${i}.png"
  OUT="$OUTDIR/variation-${i}.png"

  magick -background none -size ${TILE_W2}x${TILE_H2} canvas:none \
    "$BG" -gravity center -composite \
    "$FG" -gravity center -composite \
    -gravity center -background none -extent $FINAL_SIZE \
    "$OUT"
done

# --- Clean up ---
rm -r "$TMP1" "$TMP2"
