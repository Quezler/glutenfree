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
        $modified_mod_directories = $this->getModifiedDirectories();
//        dump($modified_mod_directories);

        exec('git log -1 HEAD --pretty=format:%s', $commit_message);
        $commit_message = $commit_message[0];
        $output->writeln("<comment>$commit_message</comment>");

        foreach (ExpansionMods::list() as $expansionMod) {
            if ($modified_mod_directories[$expansionMod->directory] ?? false) {
                $expansionMod->addInfoToChangelog($commit_message);
            }
        }

        return Command::SUCCESS;
    }

    private function getModifiedDirectories(): array
    {
        exec('git log -1 HEAD --raw', $lines);

        $modified_mod_directories = [];

        foreach ($lines as $line) {
            if (str_starts_with($line, ':')) {
                preg_match('/mods_2\.0\/(.*)\//', $line, $matches);
                if (count($matches) > 0) {
                    $modified_mod_directories[$matches[1]] = true;
                }
            }
        }

        return $modified_mod_directories;
    }
}
