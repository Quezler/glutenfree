<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class InitCommand extends Command
{
    protected static $defaultName = 'init';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED, 'Name');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        mkdir($directory = __GLUTENFREE__ . '/mods/' . $input->getArgument('name'));

        $info = [
            "name" => $input->getArgument('name'),
            "title" => ucfirst(str_replace('-', ' ', $input->getArgument('name'))),
            "description" => "Nobody expects the spanish inquisition.",
            "version" => "1.0.0",
            "author" => "Quezler",
            "factorio_version" => "1.1",
            "dependencies" => [
                "? base",
            ]
        ];

        var_dump($info);

        file_put_contents("{$directory}/info.json", json_encode($info, JSON_PRETTY_PRINT) . PHP_EOL);

        return Command::SUCCESS;
    }
}
