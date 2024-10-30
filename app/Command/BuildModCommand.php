<?php

namespace App\Command;

use App\Misc\ExpansionMod;
use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;

class BuildModCommand extends Command
{
    protected static $defaultName = 'build:mod';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mod = ExpansionMods::findOrFail($input->getArgument('name'));

        $this->clear_build_directory();
        $mod->build();
        $this->remove_test_build_from_game($mod);

        return Command::SUCCESS;
    }

    private function clear_build_directory(): void
    {
        $filesystem = new Filesystem();
        $filesystem->remove(__GLUTENFREE__ . '/build');
        $filesystem->mkdir(__GLUTENFREE__ . '/build');
    }

    private function remove_test_build_from_game(ExpansionMod $mod): void
    {
        $unversioned_mod_directory = '/Users/quezler/Library/Application\ Support/factorio/mods/' . $mod->name;
//        dump($unversioned_mod_directory);
//        dump(file_exists($unversioned_mod_directory));
//        if (file_exists($unversioned_mod_directory)) passthru(sprintf("rm -r %s", $unversioned_mod_directory));
        passthru(sprintf("rm -r %s", $unversioned_mod_directory));
    }
}
