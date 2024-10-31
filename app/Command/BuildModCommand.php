<?php

namespace App\Command;

use App\Misc\ExpansionMod;
use App\Misc\ExpansionMods;
use GuzzleHttp\Client;
use GuzzleHttp\Psr7\Utils;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Dotenv\Dotenv;
use Symfony\Component\Filesystem\Filesystem;

class BuildModCommand extends Command
{
    protected static $defaultName = 'build:mod';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
        $this->addOption('update');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mod = ExpansionMods::findOrFail($input->getArgument('name'));

        $this->clear_build_directory();
        $zip_pathname = $mod->build();
        $this->remove_test_build_from_game($mod);

        if ($input->getOption('update')) {
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

            $response = $guzzle->post($upload_url, [
                'headers' => [
                    'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY']
                ],
                'multipart' => [
                    [
                        'name' => 'file',
                        'contents' => Utils::tryFopen($zip_pathname, 'r'),
                    ],
                ]
            ]);

            dump($response->getBody()->getContents());
        }

        return Command::SUCCESS;
    }

    private function clear_build_directory(): void
    {
        $filesystem = new Filesystem();
        $filesystem->remove(__GLUTENFREE__ . '/build');
        $filesystem->mkdir(__GLUTENFREE__ . '/build');
    }

    private function remove_test_build_from_game(ExpansionMod $mod): void
    {
        $unversioned_mod_directory = '/Users/quezler/Library/Application\ Support/factorio/mods/' . $mod->name;
//        dump($unversioned_mod_directory);
//        dump(file_exists($unversioned_mod_directory));
//        if (file_exists($unversioned_mod_directory)) passthru(sprintf("rm -r %s", $unversioned_mod_directory));
        passthru(sprintf("rm -r %s", $unversioned_mod_directory));
    }
}
