# splitters="splitter fast-splitter express-splitter tungsten-splitter"

# for splitter in $splitters
# do
#   magick $splitter.png -crop 64x64+0+0 $splitter-64x64.png

#   magick $splitter-64x64.png -crop 64x12+0+0 $splitter-top.png
#   magick $splitter-64x64.png -gravity South -crop 64x24+0+0 $splitter-bottom.png

#   magick $splitter-top.png $splitter-bottom.png -alpha on -append $splitter-1x1.jpg
#   magick $splitter-1x1.png -gravity center -background none -extent 64x64 $splitter-balancer.png
# done

# find . -type f -name "*-1x1.jpg" -delete
# find . -type f -name "*-balancer.png" -delete

tiers="emptystring fast- express- tungsten-"

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
  magick ${tier}lane-splitter-1x1.png -gravity center -background none -extent 64x64 ${tier}lane-splitter.png
done

find . -type f -name "*-64x64.png" -delete
find . -type f -name "*-top.png" -delete
find . -type f -name "*-bottom.png" -delete
find . -type f -name "*-1x1.png" -delete
