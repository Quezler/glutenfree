# (cd ./mods_2.0/013_quality-upgrade-planner/graphics/icons && sh generate.sh)
mkdir ./quality-category
magick /Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/icons/transport-belt.png       -colorspace Gray quality-category/entities.png
magick /Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/icons/inserter.png             -colorspace Gray quality-category/inserters.png
magick /Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/icons/assembling-machine-2.png -colorspace Gray quality-category/recipes.png
magick /Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/icons/efficiency-module-3.png  -colorspace Gray quality-category/modules.png
magick /Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/icons/logistic-robot.png       -colorspace Gray quality-category/requests.png
magick /Users/quezler/Documents/Tower/github/wube/Factorio/data/base/graphics/icons/power-switch.png         -colorspace Gray quality-category/conditions.png
