<?php

namespace App\Command;

use App\Misc\Mod;
use App\Misc\Changelog;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ChangelogCommand extends Command
{
    protected static $defaultName = 'changelog';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED, 'Name');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mod = new Mod($input->getArgument('name'));
        (new Changelog($mod))->generate('');
        
        return 0;
    }
}
