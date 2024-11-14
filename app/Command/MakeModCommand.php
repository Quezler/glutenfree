<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use App\Misc\ModPortal;
use GuzzleHttp\Client;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Finder\Finder;

class MakeModCommand extends Command
{
    protected static $defaultName = 'make:mod';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $prefix = ExpansionMods::get_next_prefix();

        $mod_name = $input->getArgument('name');
        if (strlen($mod_name) > 49) throw new \LogicException();

        $mod_directory = __GLUTENFREE__ . '/mods_2.0/' . $prefix . $mod_name;
        mkdir($mod_directory);

        file_put_contents("{$mod_directory}/changelog.txt", implode(PHP_EOL, [
            '---------------------------------------------------------------------------------------------------',
            'Version: 0.0.1',
            'Date: ' . date('Y. m. d'),
            '  Info:',
            '    - Initial commit',
            '',
        ]));

        $mod_title = ucfirst(str_replace('-', ' ', $mod_name));
        $info = <<<EOF
{
    "name": "{$mod_name}",
    "title": "{$mod_title}",
    "description": "It probably has something to do with the title.",

    "version": "0.0.1",
    "author": "Quezler",
    "factorio_version": "2.0",

    "quality_required": false,
    "rail_bridges_required": false,
    "space_travel_required": false,
    "spoiling_required": false,
    "freezing_required": false,
    "segmented_units_required": false,
    "expansion_shaders_required": false,

    "dependencies": [
        "~ newsletter-for-mods-made-by-quezler",

        "? base",
        "? space-age"
    ]
}
EOF;

        $output->writeln($info);

        file_put_contents("{$mod_directory}/info.json", $info);
        file_put_contents("{$mod_directory}/README.md", '');
        
        return Command::SUCCESS;
    }
}
