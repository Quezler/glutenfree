<?php

namespace App\Command;

use App\Misc\Mod;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Finder\Finder;
use vierbergenlars\SemVer\version;
use function vierbergenlars\SemVer\Application\SemVer\increment;

class CiCommand extends Command
{
    protected static $defaultName = 'ci';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        if (!is_dir(__GLUTENFREE__ . '/build/')) mkdir(__GLUTENFREE__ . '/build/');

        $mods = Finder::create()->in(__GLUTENFREE__ . '/mods/')->directories()->depth(0);

        dump($_ENV);

        foreach ($mods as $mod) {
            $mod = new Mod($mod->getRelativePathname());
            $mod->build();

            $short = json_decode(file_get_contents('https://mods.factorio.com/api/mods/' . $mod->name), true);
            $sha1 = end($short['releases'])['sha1'];

            if ($mod->sha1() != $sha1) {
                dump($mod->zip_name_without_extension() . ' does not match the sha1 on the mod portal.');

                $mod->setVersion((new version(end($short['releases'])['version']))->inc('patch')->getVersion());
                $mod->build();

                $command = $this->getApplication()->find('update');
                $command->run(new ArrayInput(['name' => $mod->name]), $output);
            }
        }

        return Command::SUCCESS;
    }
}
