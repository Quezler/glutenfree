# (cd ./mods_2.0/002_lane-balancers/graphics/icons && sh imagemagick.sh)

tiers="emptystring fast- express- turbo- kr-advanced- kr-superior-"

for tier in $tiers
do
  if [ "$tier" = "emptystring" ]; then
      tier=""
  fi

  echo $tier
  magick ${tier}splitter.png -crop 64x64+0+0 ${tier}splitter-64x64.png

  magick ${tier}splitter-64x64.png -crop 64x12+0+0 ${tier}lane-splitter-top.png
  magick ${tier}splitter-64x64.png -gravity South -crop 64x24+0+0 ${tier}lane-splitter-bottom.png

  magick ${tier}lane-splitter-top.png ${tier}lane-splitter-bottom.png -alpha on -append ${tier}lane-splitter-1x1.png
  magick ${tier}lane-splitter-1x1.png -gravity center -background none -extent 64x64 -strip ${tier}lane-splitter.png
done

find . -type f -name "*-64x64.png" -delete
find . -type f -name "*-top.png" -delete
find . -type f -name "*-bottom.png" -delete
find . -type f -name "*-1x1.png" -delete
