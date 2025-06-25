<?php

namespace App\Command;

use App\Misc\ExpansionMod;
use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class PortModCommand extends Command
{
    protected static $defaultName = 'port:mod';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mod_name = $input->getArgument('name');
        $prefix = ExpansionMods::get_next_prefix();

        $from = __GLUTENFREE__ . '/mods/' . $mod_name;
        $to = __GLUTENFREE__ . '/mods_2.0/' . $prefix . $mod_name;

        if (! file_exists($from)) throw new \LogicException("unknown 1.x mod name.");

        passthru(sprintf("rsync -avr --delete %s/ %s", $from, $to));

        $full = json_decode(file_get_contents("https://mods.factorio.com/api/mods/{$mod_name}/full"), true);
        $changelog = $full['changelog'];

        // my 1.x changelog generator left an empty line above each divider
        $changelog = str_replace(
            "\n---------------------------------------------------------------------------------------------------",
            "---------------------------------------------------------------------------------------------------",
            $changelog
        );

        // commits was not an official changelog category
        $changelog = str_replace("  Commits:", "  Info:", $changelog);

        file_put_contents($changelog_pathname = "$to/changelog.txt", $changelog);

        $expansionMod = new ExpansionMod($prefix . $mod_name, $mod_name);
        $next_version = $expansionMod->getNextMajorVersion() . '.0.0';
        $expansionMod->setInfoJsonVersion($next_version);
        $expansionMod->setInfoJsonFactorioVersion("2.0");
        $expansionMod->addNewsletterDependency();

        $lines = array_merge([
            '---------------------------------------------------------------------------------------------------',
            "Version: {$next_version}",
            'Date: ' . date('Y. m. d'),
            '  Info:',
            '    - Ported to 2.0',
        ], explode(PHP_EOL, file_get_contents($changelog_pathname)));
        file_put_contents($changelog_pathname, implode(PHP_EOL, $lines));

        return Command::SUCCESS;
    }
}
