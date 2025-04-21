<?php

// php mods_2.0/089_pipe-pillars/import_render.php "/Users/quezler/Downloads/Render"

$Render = $argv[1];
$Object = "{$Render}/Object";
$Shadow = "{$Render}/Shadow";

$pipe_pillar = __DIR__ . '/graphics/entity/pipe-pillar';

$mapping = [
  '0000' => 'pipe-pillar',
  '0001' => 'pipe-pillar-pipe-connection',
  '0002' => 'pipe-pillar-bottom-pipe-left',
  '0003' => 'pipe-pillar-bottom-pipe-right',
  '0004' => 'pipe-pillar-elevated-vertical-bottom',
  '0005' => 'pipe-pillar-elevated-horizontal-left',
  '0006' => 'pipe-pillar-elevated-vertical-top',
  '0007' => 'pipe-pillar-elevated-horizontal-right',
  '0008' => 'pipe-pillar-elevated-vertical-center',
  '0009' => 'pipe-pillar-elevated-horizontal-center',
  // '0010' => 'pipe-pillar-elevated-pipe-cover-down',
  '0011' => 'pipe-pillar-elevated-pipe',
  '0012' => 'pipe-pillar-occluder-tip',
];

foreach($mapping as $numbered => $named)
{
    copy("{$Object}/{$numbered}.png", "{$pipe_pillar}/{$named}.png");
    copy("{$Shadow}/{$numbered}.png", "{$pipe_pillar}/{$named}-shadow.png");
}
