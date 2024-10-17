<?php

declare(strict_types=1);

namespace App\Misc;

use Symfony\Component\Finder\Finder;

class ExpansionMods
{
    public static function list(): \Generator
    {
        $directories = Finder::create()->in(__GLUTENFREE__ . '/mods_2.0')->directories();
        foreach ($directories as $directory) {
            preg_match('/\d{3}_(.*)/', $directory->getFilename(), $matches);
            if (count($matches) > 0) {
                yield new ExpansionMod($matches[0], $matches[1]);
            }
        }
    }

    public static function findOrFail(string $mod_name): ExpansionMod
    {
        foreach (self::list() as $mod)
            if ($mod->name == $mod_name)
                return $mod;

        throw new \LogicException("no mod found called {$mod_name}.");
    }
}
