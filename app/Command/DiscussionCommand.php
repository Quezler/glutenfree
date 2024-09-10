<?php

namespace App\Command;

use App\Misc\ModPortal;
use GuzzleHttp\Client;
use GuzzleHttp\Cookie\CookieJar;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\ProgressBar;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\DomCrawler\Crawler;

class DiscussionCommand extends Command
{
    protected static $defaultName = 'discussion';

    private Client $guzzle;
    private string $discussion_md;

    protected function configure(): void
    {
        $this->guzzle = new Client([
            'cookies' => CookieJar::fromArray([
                'wube_remember_token' => $_ENV['WUBE_REMEMBER_TOKEN'],
            ], 'mods.factorio.com'),
        ]);

        $this->discussion_md = file_get_contents(__DIR__ . '../../../discussion.md');

        if (! $_ENV['WUBE_REMEMBER_TOKEN']) throw new \LogicException();
        if (! $this->discussion_md) throw new \LogicException();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mods = ModPortal::get_my_mods_full()['results'];
        $pb = new ProgressBar($output, count($mods));

        foreach ($mods as $mod) {
            $pb->advance();
            $this->handle($mod['name']);
        }

        $pb->finish();

        return Command::SUCCESS;
    }

    protected function handle(string $mod_name)
    {
        $response = $this->guzzle->get("https://mods.factorio.com/mod/{$mod_name}/discussion/edit");
        $body = $response->getBody()->getContents();
        $csrf = (new Crawler($body))->filter('#csrf_token')->attr('value');
        if(! $csrf) throw new \LogicException();

        $this->guzzle->post("https://mods.factorio.com/mod/{$mod_name}/discussion/edit", [
            'form_params' => [
                'csrf_token' => $csrf,
                'discussion_notice' => $this->discussion_md,
            ]
        ]);
    }
}
