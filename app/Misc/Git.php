<?php

namespace App\Misc;

class Git
{
    public static function commit_changed_the_version(string $hash): bool
    {
        exec('git --no-pager show ' . $hash, $lines);

        $touched_info_json = false;

        // todo: bake with gluten
        foreach ($lines as $line) {
            if (str_ends_with($line, '/info.json')) $touched_info_json = true;
            if (str_starts_with($line, '+    "version":') && $touched_info_json) return true;
        }

        return false;
    }

    public static function date_from_commit(string $commit): string
    {
        $pattern = '/Date:\s+([a-zA-Z]+ [a-zA-Z]+ \d+ \d+:\d+:\d+ \d+)/';
        preg_match($pattern, $commit, $matches);
        return date('Y. m. d', strtotime($matches[1]));
    }
}
