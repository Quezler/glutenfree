# (cd ./mods_2.0/059_spawning-pool && sh ./graphics/generate-artery.sh)

rm -r ./graphics/entity/artery
mkdir ./graphics/entity/artery

magick ./graphics/entity/opticalfiber/opticalfiber-corner-down-left.png         -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-corner-down-left.png         
magick ./graphics/entity/opticalfiber/opticalfiber-corner-down-right.png        -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-corner-down-right.png        
magick ./graphics/entity/opticalfiber/opticalfiber-corner-up-left.png           -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-corner-up-left.png           
magick ./graphics/entity/opticalfiber/opticalfiber-corner-up-right.png          -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-corner-up-right.png          
magick ./graphics/entity/opticalfiber/opticalfiber-cross.png                    -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-cross.png                    
magick ./graphics/entity/opticalfiber/opticalfiber-ending-down.png              -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-ending-down.png              
magick ./graphics/entity/opticalfiber/opticalfiber-ending-left.png              -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-ending-left.png              
magick ./graphics/entity/opticalfiber/opticalfiber-ending-right.png             -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-ending-right.png             
magick ./graphics/entity/opticalfiber/opticalfiber-ending-up.png                -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-ending-up.png                
magick ./graphics/entity/opticalfiber/opticalfiber-straight-horizontal.png      -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-straight-horizontal.png      
magick ./graphics/entity/opticalfiber/opticalfiber-straight-vertical-single.png -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-straight-vertical-single.png 
magick ./graphics/entity/opticalfiber/opticalfiber-straight-vertical.png        -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-straight-vertical.png        
magick ./graphics/entity/opticalfiber/opticalfiber-t-down.png                   -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-t-down.png                   
magick ./graphics/entity/opticalfiber/opticalfiber-t-left.png                   -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-t-left.png                   
magick ./graphics/entity/opticalfiber/opticalfiber-t-right.png                  -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-t-right.png                  
magick ./graphics/entity/opticalfiber/opticalfiber-t-up.png                     -colorspace gray -fill red -tint 25 ./graphics/entity/artery/artery-t-up.png                     

magick ./graphics/icons/optical-fiber.png -colorspace gray -fill red -tint 25 ./graphics/icons/artery.png                     
