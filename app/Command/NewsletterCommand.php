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

//        $changelog = json_decode(file_get_contents('https://mods.factorio.com/api/mods/newsletter-for-mods-made-by-quezler/full'), true)['changelog'];
        $mod = ExpansionMods::findOrFail("newsletter-for-mods-made-by-quezler");

        $next_version = date('1Y.1md.1Hi');
        $mod->setInfoJsonVersion($next_version);

        $checksum = md5_file("{$mod->get_pathname()}/control.lua") . '.' . md5_file("$database_prefix.lua");

        $changelog_lines = array_merge([
            '---------------------------------------------------------------------------------------------------',
            "Version: {$next_version}",
            'Date: ' . date('Y. m. d'),
            '  Info:',
            '    - Checksum: ' . $checksum,
        ], explode(PHP_EOL, file_get_contents($mod->get_changelog_txt_pathname())));
        file_put_contents($mod->get_changelog_txt_pathname(), implode(PHP_EOL, $changelog_lines));

        return Command::SUCCESS;
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
                unset($release["released_at"]);
                unset($release["version"]);
            }
            $mod["latest_release"] = end($mod["releases"]);
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
