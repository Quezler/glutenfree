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

// 1.1
$application->add(new \App\Command\InitCommand());
$application->add(new \App\Command\RsyncCommand());
$application->add(new \App\Command\PublishCommand());
$application->add(new \App\Command\UpdateCommand());
$application->add(new \App\Command\CiCommand());
$application->add(new \App\Command\ChangelogCommand());
$application->add(new \App\Command\WebhookCommand());

// 2.0
$application->add(new \App\Command\MakeModCommand());
$application->add(new \App\Command\BuildModCommand());
$application->add(new \App\Command\PublishModCommand());
$application->add(new \App\Command\UpdateDetailsCommand());
$application->add(new \App\Command\TestModCommand());
$application->add(new \App\Command\GitPostCommitCommand());
$application->add(new \App\Command\PortModCommand());
$application->add(new \App\Command\LeaderboardModsCommand());
$application->add(new \App\Command\OnceNewsletterCommand());

// all
$application->add(new \App\Command\DiscussionNoticeCommand());
$application->add(new \App\Command\SendNewsletterCommand());
$application->add(new \App\Command\InstanceMakeCommand());

$application->run();
