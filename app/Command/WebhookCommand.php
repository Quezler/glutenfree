<?php

namespace App\Command;

use App\Misc\ModPortal;
use GuzzleHttp\Client;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class WebhookCommand extends Command
{
    protected static $defaultName = 'webhook';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $guzzle = new Client();

        $links_to_post = [];
        foreach (ModPortal::get_my_mods_full()['results'] as $mod) {
            $links_to_post[] = 'https://mods.factorio.com/mod/' . $mod['name'];
        }

        $posted_links = json_decode(file_get_contents('https://proxmox.nydus.app/glutenfree/webhook.php?password=' . $_ENV['LOCK_PASSWORD']), true);

        foreach ($links_to_post as $link_to_post) {
            if (in_array($link_to_post, $posted_links)) {
                dump('0 ' . $link_to_post);
                continue;
            } else {
                dump('1 ' . $link_to_post);
            }
            
            $guzzle->post($_ENV['DISCORD_WEBHOOK'], [
                'form_params' => [
                    'content' => $link_to_post,
                ],
            ]);

            sleep(5); // to please the discord api rate limit

            file_get_contents('https://proxmox.nydus.app/glutenfree/webhook.php?password=' . $_ENV['LOCK_PASSWORD'] . '&add=' . urlencode($link_to_post));
        }

        return Command::SUCCESS;
    }
}
