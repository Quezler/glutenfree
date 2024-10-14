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
        $mod_name = $input->getArgument('name');
        $mod_directory = ExpansionMods::get_directory($mod_name);

        $this->clear_build_directory();

        $source = __GLUTENFREE__ . '/mods_2.0/' . $mod_directory;
        $zip_name_without_extension = $mod_name . '_' . (new ExpansionMod($mod_directory, $mod_name))->info()['version'];
        $dest = __GLUTENFREE__ . '/build/' . $zip_name_without_extension;

        passthru(sprintf("rsync -avr --delete %s/ %s", $source, $dest));
        passthru(sprintf("(cd %s && zip -FSr %s %s)", __GLUTENFREE__ . '/build/', "{$dest}.zip", $zip_name_without_extension));

        return Command::SUCCESS;
    }

    private function clear_build_directory(): void
    {
        $filesystem = new Filesystem();
        $filesystem->remove(__GLUTENFREE__ . '/build');
        $filesystem->mkdir(__GLUTENFREE__ . '/build');
    }
}
