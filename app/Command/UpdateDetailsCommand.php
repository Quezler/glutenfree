<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class UpdateDetailsCommand extends Command
{
    protected static $defaultName = 'update:details';

    protected function configure(): void
    {
        // --all
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        foreach (ExpansionMods::list() as $expansionMod) {
            $response = $expansionMod->editDetails();
            $output->writeln($response->getBody()->getContents());
        }

        return Command::SUCCESS;
    }
}
