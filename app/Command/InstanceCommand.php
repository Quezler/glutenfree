<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class InstanceCommand extends Command
{
    protected static $defaultName = 'instance';

    protected function configure(): void
    {
        $this->addArgument('name', InputArgument::OPTIONAL);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $instances_directory = __GLUTENFREE__ . '/instances';
        if (!file_exists($instances_directory))
            mkdir($instances_directory);

        $name = $input->getArgument('name');
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

        $this->syncAuthentication($instance_directory);
        $config_ini_pathname = __DIR__ . '/../../config.ini';
        passthru("(cd {$instance_directory} && /Applications/factorio.app/Contents/MacOS/factorio --config {$config_ini_pathname})");

        return Command::SUCCESS;
    }

    private function syncAuthentication($instance_directory): void
    {
        $source = "/Users/quezler/Library/Application Support/factorio/player-data.json";
        $dest = "{$instance_directory}/player-data.json";

        $source_json = json_decode(file_get_contents($source), true);
        $dest_json = file_exists($dest) ? json_decode(file_get_contents($dest), true) : [];

        $dest_json["service-username"] = $source_json["service-username"];
        $dest_json["service-token"] = $source_json["service-token"];

        file_put_contents($dest, json_encode($dest_json, JSON_PRETTY_PRINT));
    }
}
