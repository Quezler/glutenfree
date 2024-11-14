<?php

namespace App\Command;

use App\Misc\Mod;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\InvalidArgumentException;
use GuzzleHttp\Exception\RequestException;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\Finder\Finder;
use vierbergenlars\SemVer\version;
use function vierbergenlars\SemVer\Application\SemVer\increment;

class CiCommand extends Command
{
    protected static $defaultName = 'ci';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        if (!is_dir(__GLUTENFREE__ . '/build/')) mkdir(__GLUTENFREE__ . '/build/');

        $mods = Finder::create()
            ->in(__GLUTENFREE__ . '/mods/')
            ->exclude('glutenfree-train-stop-events')
            ->exclude('glutenfree-se-pyramid-peeker')
            ->directories()
            ->depth(0)
        ;

        // try to update zip
        foreach ($mods as $mod) {
            continue; // block updating pre 2.0 mods
            $io->info($mod->getRelativePathname());
            $mod = new Mod($mod->getRelativePathname());
            $mod->build();

            try {
                $short = \GuzzleHttp\json_decode(file_get_contents('https://mods.factorio.com/api/mods/' . $mod->name), true);
            } catch (InvalidArgumentException $exception) {
                $io->warning('^');
                continue;
            }

            $version = end($short['releases'])['version'];

            if ($mod->version() != $version) {
                $io->comment("{$mod->version()} != {$version}");
                $command = $this->getApplication()->find('update');
                $command->run(new ArrayInput(['name' => $mod->name]), $output);
            }
        }

        // try to update text

        $notice_for_all_1_x_mods = file_get_contents(__GLUTENFREE__ . '/mods/readme_prefix.txt');
        foreach ($mods as $mod) {
            $io->info($mod->getRelativePathname());
            $mod = new Mod($mod->getRelativePathname());

            try {
                $response = (new Client)->post('https://mods.factorio.com/api/v2/mods/edit_details', [
                    'headers' => [
                        'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY']
                    ],
                    'form_params' => [
                        'mod' => $mod->name,
                        'title' => $mod->info()['title'],
                        'summary' => $mod->info()['description'],
                        'description' => $mod->getReadmePrefix() . $notice_for_all_1_x_mods . $mod->readme(),
                        'homepage' => 'https://discord.gg/ktZNgJcaVA',
                    ]
                ]);

                dump($response->getBody()->getContents());
            } catch (RequestException $exception) {
                dump($exception->getMessage());

                // todo: make github actions fail on `{"error":"UnknownMod","message":"Unknown Mod"}` (for unpublished mods)
            }
        }

        return Command::SUCCESS;
    }
}
