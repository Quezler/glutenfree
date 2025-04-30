# (cd ./mods_2.0/090_circuit-connector-placement-helper && sh generate_icons.sh)

# Variables for input images
IMG1="/Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/entity/circuit-connector/ccm-universal-04a-base-sequence.png"
IMG2="/Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/entity/circuit-connector/ccm-universal-04c-wire-sequence.png"
COMBINED="combined.png"

# Resize IMG2 to match IMG1 (optional, only if needed)
magick "$IMG2" -resize "$(identify -format '%wx%h' "$IMG1")!" tmp_resized.png

# Overlay images (IMG2 on top of IMG1)
magick "$IMG1" tmp_resized.png -gravity northwest -composite "$COMBINED"

# Get dimensions of combined image
WIDTH=$(identify -format "%w" "$COMBINED")
HEIGHT=$(identify -format "%h" "$COMBINED")

# Calculate dimensions of each sprite
TILE_WIDTH=$((WIDTH / 8))
TILE_HEIGHT=$((HEIGHT / 5))

# Split into 40 tiles (8 columns x 5 rows)
magick "$COMBINED" -crop ${TILE_WIDTH}x${TILE_HEIGHT} +repage +adjoin "graphics/icons/variation-%02d.png"

# Clean up
rm tmp_resized.png
rm combined.png
