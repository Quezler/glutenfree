<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\ArrayInput;
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
//            // stage 1
//            $info_json = file_get_contents($mod->get_info_json_pathname());
//            $info_json = str_replace('    "dependencies": [', "    \"dependencies\": [\n        \"~ newsletter-for-mods-made-by-quezler\",\n", $info_json);
//            file_put_contents($mod->get_info_json_pathname(), $info_json);

//            // stage 2
//            $changelog = file_get_contents($mod->get_changelog_txt_pathname());
//            $lines = explode(PHP_EOL, $changelog);
//            $found = false;
//            foreach ($lines as $i => $line) {
//                if ($line == "    - Require the presence of newsletter-for-mods-made-by-quezler") {
//                    if ($found == false) {
//                        $found = true;
//                    } else {
//                        unset($lines[$i]);
//                    }
//                }
//            }
//            file_put_contents($mod->get_changelog_txt_pathname(), implode(PHP_EOL, $lines));

//            // stage 3
//            $changelog = file_get_contents($mod->get_changelog_txt_pathname());
//            $lines = explode(PHP_EOL, $changelog);
//            $lines[2] = 'Date: 2024. 11. 15';
//            file_put_contents($mod->get_changelog_txt_pathname(), implode(PHP_EOL, $lines));

//            // stage 4
//            $mod->setInfoJsonVersion($mod->getLastVersionFromChangelog());

//            // stage 5
//            if ($mod->name != "newsletter-for-mods-made-by-quezler") {
//                $command = $this->getApplication()->find('build:mod');
//
//                try {
//                    $command->run(new ArrayInput(['name' => $mod->name, '--update' => true]), $output);
//                } catch (\Exception $e) {
//                    dump($e->getMessage());
//                }
//            }
        }

        return Command::SUCCESS;
    }
}
