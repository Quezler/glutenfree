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
        $this->addOption('all');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        if ($input->getOption('all') !== true) throw new \LogicException("Currently its all or nothing");

        foreach (ExpansionMods::list() as $expansionMod) {
            if ($expansionMod->majorVersionIsZero()) continue;

            $output->writeln($expansionMod->name);
            $response = $expansionMod->editDetails();
            $output->writeln($response->getBody()->getContents());
        }

        return Command::SUCCESS;
    }
}
