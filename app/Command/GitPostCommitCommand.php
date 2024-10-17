<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class GitPostCommitCommand extends Command
{
    protected static $defaultName = 'git:post-commit';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        foreach (ExpansionMods::list() as $expansionMod) {
            $expansionMod->tryAddNewSectionToChangelog();
        }

        return Command::SUCCESS;
    }
}
