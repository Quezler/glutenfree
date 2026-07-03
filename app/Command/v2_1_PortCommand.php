<?php

namespace App\Command;

use App\Misc\ExpansionMod;
use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class v2_1_PortCommand extends Command
{
    protected static $defaultName = '2.1:port';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mod_name = $input->getArgument('name');
        $mod = ExpansionMods::findOrFail('mods_2.0', $mod_name);
        $prefix = ExpansionMods::get_next_prefix();

        $from = __GLUTENFREE__ . '/mods_2.0/' . $mod->directory;
        $to = __GLUTENFREE__ . '/mods_2.1/' . $prefix . $mod_name;

        if (! file_exists($from)) throw new \LogicException("unknown 2.0 mod name.");

        passthru(sprintf("rsync -avr --delete %s/ %s", $from, $to));

        $expansionMod = new ExpansionMod('mods_2.1', $prefix . $mod_name, $mod_name);
        $version = $expansionMod->getVersion();
        $version->minor++;
        $version->patch = 0;
        $expansionMod->setInfoJsonVersion($version);
        $expansionMod->setInfoJsonFactorioVersion("2.1");
        $expansionMod->removeNewsletterDependency();
        $expansionMod->removeUnusedFeatureFlags();

        $changelog_txt_pathname = $expansionMod->get_changelog_txt_pathname();
        file_put_contents($changelog_txt_pathname, implode("\n", [
            '---------------------------------------------------------------------------------------------------',
            "Version: {$version}",
            'Date: ' . date('Y. m. d'),
            '  Info:',
            '    - Ported to 2.1',
            '',
        ]) . file_get_contents($changelog_txt_pathname));

        return Command::SUCCESS;
    }
}
