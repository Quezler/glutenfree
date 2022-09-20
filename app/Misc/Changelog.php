<?php

namespace App\Misc;

class Changelog
{
    private Mod $mod;

    public function __construct(Mod $mod)
    {
        $this->mod = $mod;
    }

    public function generate(string $in)
    {
        exec('git --no-pager log -- mods/' . $this->mod->name, $lines);

        $commits = [];
        $commit = [];

        foreach ($lines as $line) {
            if(str_starts_with($line, 'commit ')) {
                $commits[] = implode(PHP_EOL, $commit);
                $commit = [];
            }

            $commit[] = $line;
        }

        array_shift($commits);
//        dump($commits);

        //

        $changelog_lines = [];
        $changelog_lines[] = str_repeat('-', 99);
        $changelog_lines[] = 'Version: ' . $this->mod->version();
        $changelog_lines[] = 'Date: ' . (new \DateTime("now"))->format("d. m. Y");

        $changelog_lines[] = '  Commits:';

        foreach ($commits as $commit) {
            $changelog_lines[] = '    - ' . trim(explode(PHP_EOL, $commit)[4]);
        }

        $changelog_lines[] = '';
        $changelog_content = implode(PHP_EOL, $changelog_lines);

        dump($changelog_content);
        file_put_contents("{$in}/changelog.txt", $changelog_content);
    }
}
