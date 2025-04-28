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
//'0005' => null,
  '0006' => 'pipe-pillar-elevated-vertical-top',
  '0007' => 'pipe-pillar-elevated-vertical-center',
  '0008' => 'pipe-pillar-elevated-vertical-bottom',
  '0009' => 'pipe-pillar-elevated-vertical-single',
  '0010' => 'pipe-pillar-elevated-horizontal-left',
  '0011' => 'pipe-pillar-elevated-horizontal-center',
  '0012' => 'pipe-pillar-elevated-horizontal-right',
  '0013' => 'pipe-pillar-elevated-horizontal-single',
  '0014' => 'pipe-pillar-back-left-leg',
//'0015' => null,
  '0016' => 'pipe-pillar-pipe-connection-cover-south',
];

foreach($mapping as $numbered => $named)
{
    copy("{$Object}/{$numbered}.png", "{$pipe_pillar}/{$named}.png");
    copy("{$Shadow}/{$numbered}.png", "{$pipe_pillar}/{$named}-shadow.png");
}
