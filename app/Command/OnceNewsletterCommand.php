<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * @deprecated
 */
class OnceNewsletterCommand extends Command
{
    protected static $defaultName = 'once:newsletter';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        foreach (ExpansionMods::list() as $mod) {
            $info_json = file_get_contents($mod->get_info_json_pathname());
            $info_json = str_replace('    "dependencies": [', "    \"dependencies\": [\n        \"~ newsletter-for-mods-made-by-quezler\",\n", $info_json);
            file_put_contents($mod->get_info_json_pathname(), $info_json);
        }

        return Command::SUCCESS;
    }
}
