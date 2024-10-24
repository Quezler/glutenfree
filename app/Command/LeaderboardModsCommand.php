<?php

namespace App\Command;

use GuzzleHttp\Client;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class LeaderboardModsCommand extends Command
{
    protected static $defaultName = 'leaderboard:mods';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $guzzle = new Client();

        $response1 = $guzzle->get('https://mods.factorio.com/api/mods?page_size=max');
        $json1 = json_decode($response1->getBody()->getContents(), true);

        $mods_for_author = [];
        foreach ($json1['results'] as $mod) {
            $mods_for_author[$mod['owner']] = ($mods_for_author[$mod['owner']] ?? 0) + 1;
        }

        arsort($mods_for_author);
        dump($mods_for_author);

        return Command::SUCCESS;
    }
}
