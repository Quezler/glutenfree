<?php

// (cd mods_2.0/070_hurricane-sandbox && composer install)
// (cd mods_2.0/070_hurricane-sandbox && php factorio-sprites.php)
//require __DIR__ . '/vendor/autoload.php';

// todo: imagecreatefrompng() & imagecolorat()
const figma = [
    "_convector"            => [ "5x5" ,  80],
    "_oxidizer"             => [ "4x4" ,  60],
    "_train-loader"         => [ "4x4" ,  40],

    "alloy-forge"           => [ "8x8" , 120],
    "arc-furnace"           => [ "5x5" ,  50],
    "atom-forge"            => [ "6x6" ,  80],
    "chemical-stager"       => [ "5x5" ,  60],
    "conduit"               => [ "3x3" ,  60],
    "core-extractor"        => ["11x11", 120],
    "electricity-extractor" => [ "8x8" ,   1],
    "fluid-extractor"       => [ "8x8" ,   1],
    "fusion-reactor"        => [ "6x6" ,  60],
    "glass-furnace"         => [ "4x4" ,  80],
    "gravity-assembler"     => [ "5x5" , 100],
    "greenhouse"            => [ "5x5" , 128],
    "item-extractor"        => [ "8x8" ,   1],
    "lumber-mill"           => [ "8x8" ,  80],
    "manufacturer"          => [ "4x4" , 128],
    "oxidizer"              => [ "4x4" ,  60],
    "pathogen-lab"          => [ "7x7" ,  60],
    "photometric-lab"       => [ "5x5" ,  80],
    "quantum-stabilizer"    => [ "6x6" , 100],
    "radio-station"         => [ "2x2" ,  20],
    "research-center"       => [ "9x9" ,  80],
    "scrubber"              => [ "3x3" ,  60],
    "thermal-plant"         => [ "6x6" ,  80],
];

function create_lua_file($directory, $filename): void
{
    $pathname = $directory . '/' . $filename;
    $subdirectory = $pathname . '/sprites';
    if (file_exists($subdirectory))
        $pathname = $subdirectory;

    { // the conduit and the deprecated oxidizer have no numbers here yet, for the convenience of the mod we update them:
        if (file_exists($pathname . '/' . $filename . '-hr-emission.png'))
            rename($pathname . '/' . $filename . '-hr-emission.png', $pathname . '/' . $filename . '-hr-emission-1.png');
        if (file_exists($pathname . '/' . $filename . '-hr-animation.png'))
            rename($pathname . '/' . $filename . '-hr-animation.png', $pathname . '/' . $filename . '-hr-animation-1.png');
    }

    $lua = ["return {"];

    $figma = figma[$filename] ?? figma['_' . $filename];

    $lua[] = sprintf('  name = "%s",', $filename);
    $lua[] = sprintf('  localised_name = "%s",', ucwords(str_replace('-', ' ', $filename)));
    $lua[] = sprintf('  size = "%s",', $figma[0]);
    $lua[] = sprintf('  frames = %s,', $figma[1]);
    $lua[] = '';

    $icon_pathname = $pathname . '/' . $filename . '-icon.png';
    if (! file_exists($icon_pathname))
        $lua[] = '  icon_missing = true,';

    {
        $emissions = 1;

        $emission_pathname = $pathname . '/' . $filename . '-hr-emission-1.png';
        if (! file_exists($emission_pathname))
            $emissions = 0;

        $emission1_pathname = $pathname . '/' . $filename . '-hr-emission1-1.png';
        if (file_exists($emission1_pathname))
            $emissions = 2;

        $lua[] = sprintf('  emissions = %d,', $emissions);
    }

    $lua[] = sprintf('  directory_suffix = "%s",', file_exists($subdirectory) ? '/sprites' : '');
    $lua[] = '';

    list($width1, $height1) = getimagesize($pathname . '/' . $filename . '-hr-animation-1.png');
    $lua[] = sprintf('  animation = {width = %d, height = %d},', $width1, $height1);

    list($width2, $height2) = getimagesize($pathname . '/' . $filename . '-hr-shadow.png');
    $lua[] = sprintf('  shadow = {width = %d, height = %d},', $width2, $height2);

    $lua[] = "}";
    $lua_pathname = $pathname . '/' . $filename . '.lua';
    file_put_contents($lua_pathname, implode("\n", $lua) . "\n");
}

function check_directory($directory): void
{
    foreach (scandir($directory) as $folder) {
        if (!str_starts_with($folder, '.') && !str_starts_with($folder, '_')) {
            echo $folder . "\n";
            create_lua_file($directory, $folder);
        }
    }
}

//check_directory(__DIR__ . '/factorio-sprites/_deprecated');
check_directory(__DIR__ . '/factorio-sprites');
