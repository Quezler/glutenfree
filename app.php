#!/usr/bin/env php
<?php

define('__GLUTENFREE__', __DIR__);
require __DIR__.'/vendor/autoload.php';

use Symfony\Component\Console\Application;
use Symfony\Component\Dotenv\Dotenv;

$application = new Application();

$dotenv = new Dotenv();
$dotenv->load(__GLUTENFREE__ . '/.env');

ini_set('user_agent', 'https://github.com/Quezler/glutenfree');

$application->add(new \App\Command\InitCommand());
$application->add(new \App\Command\RsyncCommand());
$application->add(new \App\Command\PublishCommand());
$application->add(new \App\Command\UpdateCommand());
$application->add(new \App\Command\CiCommand());
$application->add(new \App\Command\ChangelogCommand());
$application->add(new \App\Command\WebhookCommand());
$application->add(new \App\Command\DiscussionCommand());

$application->run();
