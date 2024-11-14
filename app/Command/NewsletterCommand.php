<?php

namespace App\Command;

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
        foreach ($results as $mod) {
//            dump($mod);
        }

        $database_prefix = __GLUTENFREE__ . '/mods_2.0/032_newsletter-for-mods-made-by-quezler/database';
        $json1 = json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        file_put_contents("$database_prefix.json", $json1);

        $json2 = json_encode($results, JSON_UNESCAPED_SLASHES);
        $json2 = str_replace("\\", "\\\\", $json2);
        $json2 = str_replace("'", "\'", $json2);
        file_put_contents("$database_prefix.lua", "return helpers.json_to_table('". $json2 ."')");

        return Command::SUCCESS;
    }

    private function strip_undesired_information_from_mods(&$results)
    {
        foreach ($results as &$mod) {
            unset($mod["changelog"]); // big

            foreach ($mod["releases"] as &$release) {
                unset($release["download_url"]);
                unset($release["file_name"]);
                unset($release["sha1"]);
            }
            $mod["latest_release"] = end($mod["releases"]);
            unset($mod["releases"]); // bloated
            unset($mod["score"]); // outdated
            unset($mod["downloads"]); // outdated

            unset($mod["homepage"]);
            unset($mod["source_url"]);
        }
    }
}
