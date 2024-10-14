<?php

declare(strict_types=1);

namespace App\Misc;

use Symfony\Component\Finder\Finder;

class ExpansionMods
{
    // [001__disposable-construction-robots => disposable-construction-robots]
    public static function list(): \Generator
    {
        $directories = Finder::create()->in(__GLUTENFREE__ . '/mods_2.0')->directories();
        foreach ($directories as $directory) {
            preg_match('/\d{3}_(.*)/', $directory->getFilename(), $matches);
            if (count($matches) > 0) {
                yield $matches[0] => $matches[1];
            }
        }
    }

    public static function get_directory(string $mod_name): ?string
    {
        $result = array_search($mod_name, iterator_to_array(self::list()));
        if ($result === false) throw new \LogicException("no mod found called {$mod_name}.");

        return $result;
    }
}
