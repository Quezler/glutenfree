#!/usr/bin/env php
<?php

define('__GLUTENFREE__', __DIR__);
require __DIR__.'/vendor/autoload.php';

use Symfony\Component\Console\Application;

$application = new Application();

$application->add(new \App\Command\InitCommand());
$application->add(new \App\Command\RsyncCommand());
$application->add(new \App\Command\PublishCommand());

$application->run();
