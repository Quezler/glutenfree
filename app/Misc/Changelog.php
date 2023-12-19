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
        $commits = array_reverse($commits);
//        dump($commits);

        //

        $versions = [];
        $orphans = [];

        foreach ($commits as $commit) {
            unset($info_json); // why? 0,o
            $hash = explode(' ', explode(PHP_EOL, $commit)[0])[1];

            if (!Git::commit_changed_the_version($hash)) {
                $orphans[] = $commit;
                continue;
            }

            // get the version from the info.json's history by the hash
            exec($git_show = sprintf('git show %s:mods/%s/info.json', $hash, $this->mod->name), $info_json);
            $info = json_decode(implode(PHP_EOL, $info_json), true);

//            dump([$git_show, $info_json]);
            if (!array_key_exists($info['version'], $versions)) {
                $versions[$info['version']] = [];

//                dump([$info['version'], $orphans]);

                foreach ($orphans as $orphan) $versions[$info['version']][] = $orphan;
                $orphans = [];
            }

            $versions[$info['version']][] = $commit;
        }

        //

        $changelog_lines = [];
        $versions = array_reverse($versions);

        foreach ($versions as $version => $commits) {
            $changelog_lines[] = str_repeat('-', 99);
            $changelog_lines[] = 'Version: ' . $version;
            $changelog_lines[] = 'Date: ' . Git::date_from_commit($commits[0]);

            $changelog_lines[] = '  Commits:';

            foreach ($commits as $commit) {
                $changelog_lines[] = '    - ' . trim(explode(PHP_EOL, $commit)[4]);
            }

            $changelog_lines[] = '';
        }

        $changelog_content = implode(PHP_EOL, $changelog_lines);

        dump($changelog_content);

        if ($in != "")
          file_put_contents("{$in}/changelog.txt", $changelog_content);
    }
}
