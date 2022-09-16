<?php

namespace App\Command;

use GuzzleHttp\Client;
use GuzzleHttp\Psr7\Utils;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Dotenv\Dotenv;

class UpdateCommand extends Command
{
    protected static $defaultName = 'update';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED, 'Name');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $source = __GLUTENFREE__ . '/build/' . $input->getArgument('name') .'_'. $this->current_version($input->getArgument('name')) .'.zip';

        $dotenv = new Dotenv();
        $dotenv->load(__GLUTENFREE__ . '/.env');

        $guzzle = new Client();
        $response = $guzzle->post('https://mods.factorio.com/api/v2/mods/releases/init_upload', [
            'headers' => [
                'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY']
            ],
            'form_params' => [
                'mod' => $input->getArgument('name'),
            ]
        ]);

        $upload_url = json_decode($response->getBody()->getContents(), true)['upload_url'];
        dump($upload_url);

//        $response = $guzzle->post($upload_url, [
//            'headers' => [
//                'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY']
//            ],
//            'multipart' => [
//                [
//                    'name' => 'file',
//                    'contents' => Utils::tryFopen($source, 'r'),
//                ],
//            ]
//        ]);
//
//        dump($response->getBody()->getContents());

        return Command::SUCCESS;
    }

    private function current_version(string $name) {
        $path = __GLUTENFREE__ . "/mods/{$name}/info.json";

        return json_decode(file_get_contents($path), true)['version'];
    }
}
