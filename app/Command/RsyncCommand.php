<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class RsyncCommand extends Command
{
    protected static $defaultName = 'rsync';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED, 'Name');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        if (!is_dir(__GLUTENFREE__ . '/build/')) mkdir(__GLUTENFREE__ . '/build/');

        $source = __GLUTENFREE__ . '/mods/' . $input->getArgument('name');
        $dest = __GLUTENFREE__ . '/build/' . $input->getArgument('name') .'_'. $this->current_version($input->getArgument('name'));

        if (!is_dir($source)) throw new \Exception($source);

        passthru(sprintf("rsync -avr --delete %s/ %s", $source, $dest));
        passthru(sprintf("(cd %s && zip -FSr %s %s)", __GLUTENFREE__ . '/build/', "{$dest}.zip", $input->getArgument('name') .'_'. $this->current_version($input->getArgument('name'))));

        $live = '/Users/quezler/Library/Application\ Support/factorio/mods/' . $input->getArgument('name') .'_'. $this->current_version($input->getArgument('name'));
        passthru(sprintf("rsync -avr --delete %s/ %s", $dest, $live));

        return Command::SUCCESS;
    }

    private function current_version(string $name) {
        $path = __GLUTENFREE__ . "/mods/{$name}/info.json";

        return json_decode(file_get_contents($path), true)['version'];
    }
}
