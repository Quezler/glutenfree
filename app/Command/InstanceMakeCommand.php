<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class InstanceMakeCommand extends Command
{
    protected static $defaultName = 'make:instance';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $instances_directory = __GLUTENFREE__ . '/instances';
        if (!file_exists($instances_directory))
            mkdir($instances_directory);

        $instance_directory = "{$instances_directory}/{$input->getArgument('name')}";

        if (!file_exists($instance_directory))
            mkdir($instance_directory);

        passthru("(cd {$instance_directory} && /Applications/factorio.app/Contents/MacOS/factorio --config ../../config.ini)");

        return Command::SUCCESS;
    }
}
