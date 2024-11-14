<?php

namespace App\Command;

use App\Misc\ModPortal;
use GuzzleHttp\Client;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class NewsletterCommand extends Command
{
    protected static $defaultName = 'newsletter';

    protected function configure(): void
    {
        //
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $results = ModPortal::get_my_mods_full()['results'];
        foreach ($results as $mod) {
            dump($mod);
        }

        $database_pathname = __GLUTENFREE__ . '/mods_2.0/032_newsletter-for-mods-made-by-quezler/database.lua';
//        $json = json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
//        $json = preg_replace('/^ {4}/m', '  ', $json);
//        $json = $this->adjustIndentation($json);
        file_put_contents($database_pathname, 'return ' . $this->arrayToLua($results));
        
        return Command::SUCCESS;
    }

    private function adjustIndentation($input) {
        // Keep replacing four leading spaces with two until no more can be replaced
        return preg_replace_callback('/^( {4})+/m', function($matches) {
            // Count the total number of spaces matched
            $totalSpaces = strlen($matches[0]);
            // Calculate the new indentation with 2 spaces for each "block" of 4 spaces
            $newIndentation = str_repeat('  ', $totalSpaces / 4);
            return $newIndentation;
        }, $input);
    }

    private function arrayToLua($array, $indentLevel = 0) {
        $lua = "{\n";
        $indent = str_repeat("  ", $indentLevel + 1); // 2-space indent

        foreach ($array as $key => $value) {
            // Prepare key format for Lua table with double quotes
            $luaKey = '"' . addslashes($key) . '"';

            if (is_array($value)) {
                // Recursive call for nested arrays
                $lua .= "{$indent}{$luaKey} = " . $this->arrayToLua($value, $indentLevel + 1) . ",\n";
            } elseif (is_string($value)) {
                // Add quotes around string values
                $lua .= "{$indent}{$luaKey} = \"" . addslashes($value) . "\",\n";
            } elseif (is_bool($value)) {
                // Convert boolean to Lua boolean
                $lua .= "{$indent}{$luaKey} = " . ($value ? 'true' : 'false') . ",\n";
            } elseif (is_null($value)) {
                // Convert null to Lua's 'nil'
                $lua .= "{$indent}{$luaKey} = nil,\n";
            } else {
                // Numeric values (integer or float)
                $lua .= "{$indent}{$luaKey} = {$value},\n";
            }
        }

        $lua .= str_repeat("  ", $indentLevel) . "}"; // Close the Lua table with correct indent
        return $lua;
    }
}
