<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Completion\CompletionInput;
use Symfony\Component\Console\Completion\CompletionSuggestions;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Finder\Finder;

class InstanceCommand extends Command
{
    protected static $defaultName = 'instance';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::OPTIONAL);
        $this->addOption('client');
    }

    public function complete(CompletionInput $input, CompletionSuggestions $suggestions): void
    {
        if ($input->mustSuggestArgumentValuesFor('name')) {
            $instances = [];
            foreach (Finder::create()->in(__GLUTENFREE__ . '/instances')->depth(0)->directories() as $instance)
                $instances[] = $instance->getFilename();
            $suggestions->suggestValues($instances);
        }
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $instances_directory = __GLUTENFREE__ . '/instances';
        if (!file_exists($instances_directory))
            mkdir($instances_directory);

        $name = $input->getArgument('name');
        file_put_contents(__GLUTENFREE__ . '/instance.lock', $name);
        $instance_directory = "{$instances_directory}/{$name}";

        if ($name == null) {
            $instance_directory = "/Volumes/Factorio";
            if (!file_exists($instance_directory)) {
                exec('open -a /Applications/TmpDisk.app --args -name=Factorio -size=' . (1024 * 16), $lines);
                while(!file_exists($instance_directory))
                    sleep(1);
            }
        }

        if (!file_exists($instance_directory))
            mkdir($instance_directory);

        $saves_directory = "{$instance_directory}/saves";
        if (!file_exists($saves_directory))
            mkdir($saves_directory);

        $freeplay_please = "{$instance_directory}/saves/freeplay_please.txt";
        if (!file_exists($freeplay_please))
            touch($freeplay_please);

        $mods_directory = "{$instance_directory}/mods";
        if (!file_exists($mods_directory))
            mkdir($mods_directory);

        $this->syncAuthentication($instance_directory, $input->getOption('client'));
        $config_ini_pathname = __DIR__ . '/../../config.ini';

        if ($input->getOption('client')) {
            unlink("{$instance_directory}/.lock");
        }

        $factorio_binary = "/Applications/factorio.app/Contents/MacOS/factorio";
//        $factorio_binary = "/Users/quezler/Documents/Tower/github/wube/Factorio/bin/Releasearm64Clang/factorio-run";
        passthru("(cd {$instance_directory} && {$factorio_binary} --config {$config_ini_pathname})");

        return Command::SUCCESS;
    }

    private function syncAuthentication($instance_directory, bool $client): void
    {
        $source = "/Users/quezler/Library/Application Support/factorio/player-data.json";
        $dest = "{$instance_directory}/player-data.json";

        $source_json = json_decode(file_get_contents($source), true);
        $dest_json = file_exists($dest) ? json_decode(file_get_contents($dest), true) : [];

        $dest_json["service-username"] = $client ? "Compilatron" : $source_json["service-username"];
        $dest_json["service-token"] = $client ? "" : $source_json["service-token"];

        file_put_contents($dest, json_encode($dest_json, JSON_PRETTY_PRINT));
    }
}
