<?php

namespace App\Command;

use App\Misc\ExpansionMods;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class PublishModCommand extends Command
{
    protected static $defaultName = 'publish:mod';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::REQUIRED);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $mod = ExpansionMods::findOrFail($input->getArgument('name'));
        if ($mod->mostRecentChangelogEntryHasNoDate()) throw new \LogicException('Date: ????');
        $mod->build();

        $success = $mod->publish(); // "{"success":true,"url":"/api/mods/decider-combinator-output-constant-editor/full"}"
        $output->writeln($success);
        exec("open https://mods.factorio.com/mod/{$mod->name}/edit");

        $command = $this->getApplication()->find('discussion:notice');
        $command->run(new ArrayInput(['name' => $mod->name]), $output);

        return Command::SUCCESS;
    }
}
