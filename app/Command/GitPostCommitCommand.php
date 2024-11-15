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
        $touched_mods = $this->getTouchedMods();
//        dump($touched_mods);

        exec('git log -1 HEAD --pretty=format:%s', $commit_message);
        $commit_message = $commit_message[0];
        $output->writeln("<comment>$commit_message</comment>");
        if ($commit_message == "Bump version") return Command::SUCCESS;

        foreach (ExpansionMods::list() as $expansionMod) {
            if (array_key_exists($expansionMod->directory, $touched_mods)) {
                $touched_mod_files = $touched_mods[$expansionMod->directory];
                if (! in_array('changelog.txt', $touched_mod_files)) $expansionMod->addInfoToChangelog($commit_message);
            }
        }

        passthru('git commit --amend --no-edit');

        return Command::SUCCESS;
    }

    private function getTouchedMods(): array
    {
        exec('git log -1 HEAD --raw', $lines);

        $modified_mod_directories = [];

        foreach ($lines as $line) {
            if (str_starts_with($line, ':')) {
                $relative_path = explode("\t", $line)[1];
                $relative_path_bits = explode('/', $relative_path);
                if ($relative_path_bits[0] == "mods_2.0") {
                    $mod_directory = $relative_path_bits[1];
                    preg_match('/\d{3}_/U', $mod_directory, $matches);
                    if (count($matches) > 0) {
                        $modified_mod_directories[$mod_directory] = $modified_mod_directories[$mod_directory] ?? [];
                        $modified_mod_directories[$mod_directory][] = implode('/', array_slice($relative_path_bits, 2));
                    }
                }
            }
        }

        return $modified_mod_directories;
    }
}
