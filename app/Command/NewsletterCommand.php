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
        foreach ($results as $mod) {
            dump($mod);
        }

        $database_pathname = __GLUTENFREE__ . '/mods_2.0/032_newsletter-for-mods-made-by-quezler/database.json';
        $json = json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
//        $json = preg_replace('/^ {4}/m', '  ', $json);
        $json = $this->adjustIndentation($json);
        file_put_contents($database_pathname, $json);
        
        return Command::SUCCESS;
    }

    private function adjustIndentation($input) {
        // Keep replacing four leading spaces with two until no more can be replaced
        return preg_replace_callback('/^( {4})+/m', function($matches) {
            // Count the total number of spaces matched
            $totalSpaces = strlen($matches[0]);
            // Calculate the new indentation with 2 spaces for each "block" of 4 spaces
            $newIndentation = str_repeat('  ', $totalSpaces / 4);
            return $newIndentation;
        }, $input);
    }
}
