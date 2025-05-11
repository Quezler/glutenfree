<?php

// php mods_2.0/089_elevated-pipes/import_render.php "/Users/quezler/Downloads/Render"

$Render = $argv[1];
$Object = "{$Render}/Object";
$Shadow = "{$Render}/Shadow";

$pipe_pillar = __DIR__ . '/graphics/entity/elevated-pipe';

$mapping = [
  '0000' => 'elevated-pipe-pipe-connection',
  '0001' => 'elevated-pipe',
  '0002' => 'elevated-pipe-occluder-bottom',
  '0003' => 'elevated-pipe-occluder-top',
  '0004' => 'elevated-pipe-pipe-covers',
//'0005' => null,
  '0006' => 'elevated-pipe-vertical-top',
  '0007' => 'elevated-pipe-vertical-center',
  '0008' => 'elevated-pipe-vertical-bottom',
  '0009' => 'elevated-pipe-vertical-single',
  '0010' => 'elevated-pipe-horizontal-left',
  '0011' => 'elevated-pipe-horizontal-center',
  '0012' => 'elevated-pipe-horizontal-right',
  '0013' => 'elevated-pipe-horizontal-single',
  '0014' => 'elevated-pipe-back-left-leg',
//'0015' => null,
//'0016' => null,
  '0017' => 'elevated-pipe-remnant',
];

foreach($mapping as $numbered => $named)
{
  copy("{$Object}/{$numbered}.png", "{$pipe_pillar}/{$named}.png");
  copy("{$Shadow}/{$numbered}.png", "{$pipe_pillar}/{$named}-shadow.png");
}

copy("{$Render}/Object Icon/icon.png", __DIR__ . '/graphics/icons/elevated-pipe.png');
copy("{$Render}/Object Icon/tech.png", __DIR__ . '/graphics/technology/elevated-piper.png');
