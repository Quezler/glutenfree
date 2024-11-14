<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use App\Misc\ModPortal;
use GuzzleHttp\Client;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class NewsletterCommand extends Command
{
    protected static $defaultName = 'newsletter';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $results = ModPortal::get_my_mods_full()['results'];
        $this->strip_undesired_information_from_mods($results);
        dump($results);

        $database_prefix = __GLUTENFREE__ . '/mods_2.0/032_newsletter-for-mods-made-by-quezler/scripts/database';
        $json1 = json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        file_put_contents("$database_prefix.json", $json1);

        $json2 = json_encode($results, JSON_UNESCAPED_SLASHES);
        $json2 = str_replace("\\", "\\\\", $json2);
        $json2 = str_replace("'", "\'", $json2);
        file_put_contents("$database_prefix.lua", "return helpers.json_to_table('". $json2 ."')");

        $mod = ExpansionMods::findOrFail("newsletter-for-mods-made-by-quezler");

        $checksum = md5_file("{$mod->get_pathname()}/control.lua") . '.' . md5_file("$database_prefix.lua");
        $changelog = json_decode(file_get_contents('https://mods.factorio.com/api/mods/newsletter-for-mods-made-by-quezler/full'), true)['changelog'];
        dump($changelog);

        $old_checksum_line = explode(PHP_EOL, $changelog)[4];
        $new_checksum_line = '    - Checksum: ' . $checksum;
        dump([$old_checksum_line, $new_checksum_line]);
        if ($new_checksum_line == $old_checksum_line) {
            return Command::SUCCESS;
        }

        $next_version = date('1Y.1md.1Hi');
        $mod->setInfoJsonVersion($next_version);

        $changelog_lines = array_merge([
            '---------------------------------------------------------------------------------------------------',
            "Version: {$next_version}",
            'Date: ' . date('Y. m. d'),
            '  Info:',
            $new_checksum_line,
        ], explode(PHP_EOL, file_get_contents($mod->get_changelog_txt_pathname())));
        file_put_contents($mod->get_changelog_txt_pathname(), implode(PHP_EOL, $changelog_lines));

        return Command::SUCCESS;
    }

    private function get_latest_release($mod)
    {
        if ($mod["name"] == "newsletter-for-mods-made-by-quezler") {
            foreach ($mod["releases"] as $i => $release) {
                if (strlen($release["version"]) == 17) {
                    dd($mod["releases"]);
                    return $mod["releases"][$i - 1];
                }
            }
        }

        return end($mod["releases"]);
    }

    private function strip_undesired_information_from_mods(&$results): void
    {
        foreach ($results as &$mod) {
            unset($mod["changelog"]); // big

            unset($mod["thumbnail"]); // no embedded images
            unset($mod["images"]); // no embedded images

            foreach ($mod["releases"] as &$release) {
                unset($release["download_url"]);
                unset($release["file_name"]);
                unset($release["sha1"]);
            }
            $mod["latest_release"] = $this->get_latest_release($mod);
            unset($mod["latest_release"]["version"]);

            if ($mod["name"] == "newsletter-for-mods-made-by-quezler") {
                $mod["updated_at"] = $mod["latest_release"]["released_at"];
            }
            unset($mod["latest_release"]["released_at"]);
//            unset($mod["latest_release"]["info_json"]["dependencies"]);
            unset($mod["releases"]); // bloated
            unset($mod["score"]); // outdated
            unset($mod["downloads_count"]); // outdated

            unset($mod["homepage"]); // always discord
            unset($mod["source_url"]); // always github
            unset($mod["github_path"]); // always github
            unset($mod["owner"]); // always me

            unset($mod["carbon"]); // added by ModPortal::get_my_mods_full()
        }
    }
}
