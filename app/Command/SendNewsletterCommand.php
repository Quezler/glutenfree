<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use App\Misc\ModPortal;
use GuzzleHttp\Client;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class SendNewsletterCommand extends Command
{
    protected static $defaultName = 'send:newsletter';

    protected function configure(): void
    {
        $this->addOption('ci');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $results = ModPortal::get_my_mods_full()['results'];
        $this->update_faq($results);
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

        if ($input->getOption('ci')) {
            $command = $this->getApplication()->find('build:mod');
            $command->run(new ArrayInput(['name' => $mod->name, '--update' => true]), $output);
        }

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
                unset($release["info_json"]["dependencies"]);
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

            if ($mod["name"] == "newsletter-for-mods-made-by-quezler") {
                $mod["updated_at"] = $mod["created_at"];
            }

            // to avoid a new newsletter for every update,
            // maybe for when we check dependencies someday,
            // but that'd just be in latest release.
            unset($mod["updated_at"]);
        }
    }

    private function update_faq($results)
    {
        $lines = [];

        foreach (array_reverse($results) as $result) {
            $lines[] = "";
            $lines[] = $result["summary"];
            $lines[] = "[![](https://mods.factorio.com/opengraph/mod/{$result["name"]}.png)](https://mods.factorio.com/mod/{$result["name"]})";
        }

        return $response = (new Client)->post('https://mods.factorio.com/api/v2/mods/edit_details', [
            'headers' => [
                'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY'],
            ],
            'form_params' => [
                'mod' => 'newsletter-for-mods-made-by-quezler',
                'faq' => implode(PHP_EOL, $lines),
            ]
        ]);
    }
}
