<?php

// php mods_2.0/089_pipe-pillars/import_render.php "/Users/quezler/Downloads/Render"

$Render = $argv[1];
$Object = "{$Render}/Object";
$Shadow = "{$Render}/Shadow";

$pipe_pillar = __DIR__ . '/graphics/entity/pipe-pillar';

$mapping = [
  '0000' => 'pipe-pillar-pipe-connection',
  '0001' => 'pipe-pillar',
  '0002' => 'pipe-pillar-occluder-bottom',
  '0003' => 'pipe-pillar-occluder-top',
  '0004' => 'pipe-pillar-pipe-covers',
  // '0004' => 'pipe-pillar-elevated-vertical-bottom',
  '0005' => 'pipe-pillar-elevated-horizontal-left',
  '0006' => 'pipe-pillar-elevated-vertical-top',
  '0007' => 'pipe-pillar-elevated-horizontal-right',
  '0008' => 'pipe-pillar-elevated-vertical-center',
  '0009' => 'pipe-pillar-elevated-horizontal-center',
  '0010' => 'pipe-pillar-pipe-connection-only',
  // '0011' => 'pipe-pillar-occluder-tip',
  '0012' => 'pipe-pillar-elevated-horizontal-single',
  '0013' => 'pipe-pillar-elevated-vertical-single',
];

foreach($mapping as $numbered => $named)
{
    copy("{$Object}/{$numbered}.png", "{$pipe_pillar}/{$named}.png");
    copy("{$Shadow}/{$numbered}.png", "{$pipe_pillar}/{$named}-shadow.png");
}

// magick composite pipe-pillar.png pipe-pillar-pipe-connection.png -compose Difference difference.png

// magick \
//   pipe-pillar-pipe-connection.png -alpha extract pipe-connection-alpha.png

// magick \
//   pipe-pillar.png -alpha extract pipe-pillar-alpha.png

// magick \
//   pipe-connection-alpha.png pipe-pillar-alpha.png \
//   -compose Difference -composite \
//   -threshold 0 \
//   alpha-difference-mask.png

// magick \
//   pipe-pillar-pipe-connection.png \
//   alpha-difference-mask.png -compose CopyOpacity -composite \
//   new-layer-only.png

// magick \
//   pipe-pillar-pipe-connection.png -alpha extract mpr:alpha1 \
//   pipe-pillar.png -alpha extract mpr:alpha2 \
//   mpr:alpha1 mpr:alpha2 -compose Difference -composite -threshold 0 mpr:mask \
//   pipe-pillar-pipe-connection.png mpr:mask -compose CopyOpacity -composite \
//   new-layer-only.png

// magick \
//   pipe-pillar-pipe-connection.png pipe-pillar.png \
//   -compose DstOut -composite \
//   new-added-layer.png

// magick \
//   ( pipe-pillar-pipe-connection.png pipe-pillar.png -compose Difference -composite ) \
//   -colorspace Gray -threshold 5% diffmask.png

// magick \
//   pipe-pillar-pipe-connection.png diffmask.png -compose CopyOpacity -composite \
//   true-added-pipe.png
