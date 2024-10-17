<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class TestModCommand extends Command
{
    protected static $defaultName = 'test:mod';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
        $this->addOption('watch');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mod = ExpansionMods::findOrFail($input->getArgument('name'));

        do {
            $mod->test();
        } while ($input->getOption('watch') && sleep(2) == 0);

        return Command::SUCCESS;
    }
}
