<?php

namespace App\Misc;

use GuzzleHttp\Client;
use GuzzleHttp\Psr7\Utils;
use Psr\Http\Message\ResponseInterface;

class ExpansionMod
{
    public string $directory;
    public string $name;

    public function __construct(string $directory, string $name)
    {
        $this->directory = $directory;
        $this->name = $name;
    }

    public function get_pathname()
    {
        return __GLUTENFREE__ . '/mods_2.0/' . $this->directory;
    }

    public function info(): array
    {
        return json_decode(file_get_contents("{$this->get_pathname()}/info.json"), true);
    }

    // creates a versioned folder and a zip
    public function build(): string
    {
        $source = __GLUTENFREE__ . '/mods_2.0/' . $this->directory;
        $zip_name_without_extension = $this->name . '_' . $this->info()['version'];
        $dest = __GLUTENFREE__ . '/build/' . $zip_name_without_extension;

        passthru(sprintf("rsync -avr --delete %s/ %s", $source, $dest));
        passthru(sprintf("(cd %s && zip -FSr %s %s)", __GLUTENFREE__ . '/build/', $pathname = "{$dest}.zip", $zip_name_without_extension));

        return $pathname;
    }

    // creates an unversioned folder
    public function test(): void
    {
        $source = __GLUTENFREE__ . '/mods_2.0/' . $this->directory;
        $dest = '/Users/quezler/Library/Application\ Support/factorio/mods/' . $this->name;

        passthru(sprintf("rsync -avr --delete %s/ %s", $source, $dest));
    }

    public function publish(): string
    {
        $zip_filename = $this->name . '_' . $this->info()['version'] . '.zip';
        $zip_pathname = __GLUTENFREE__ . '/build/' . $zip_filename;
        if (!file_exists($zip_pathname)) throw new \LogicException("{$zip_filename} not built yet.");

        $guzzle = new Client();
        $response = $guzzle->post('https://mods.factorio.com/api/v2/mods/init_publish', [
            'headers' => [
                'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY']
            ],
            'form_params' => [
                'mod' => $this->name,
            ]
        ]);

        $upload_url = json_decode($response->getBody()->getContents(), true)['upload_url'];

        $response = $guzzle->post($upload_url, [
            'headers' => [
                'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY']
            ],
            'multipart' => [
                [
                    'name' => 'file',
                    'contents' => Utils::tryFopen($zip_pathname, 'r'),
                ],
                [
                    'name' => 'license',
                    'contents' => 'default_mit',
                ],
                [
                    'name' => 'source_url',
                    'contents' => 'https://github.com/Quezler/glutenfree',
                ],
                [
                    'name' => 'description',
                    'contents' => file_get_contents(str_replace('.zip', '/README.md', $zip_pathname)),
                ]
            ]
        ]);

        return $response->getBody()->getContents();
    }

    public function editDetails(): ResponseInterface
    {
        return $response = (new Client)->post('https://mods.factorio.com/api/v2/mods/edit_details', [
            'headers' => [
                'Authorization' => 'Bearer ' . $_ENV['FACTORIO_API_KEY'],
            ],
            'form_params' => [
                'mod' => $this->name,
                'title' => $this->info()['title'],
                'summary' => $this->info()['description'],
                'description' => file_get_contents("{$this->get_pathname()}/README.md"),
                // category
                // tags
                // license
                'homepage' => 'https://discord.gg/ktZNgJcaVA',
                // deprecated
                // source_url
                // faq
            ]
        ]);
    }

    public function getLastVersionFromChangelog(): string
    {
        $changelog = file_get_contents($changelog_pathname = "{$this->get_pathname()}/changelog.txt");
        $lines = explode(PHP_EOL, $changelog);

        return explode('Version: ', $lines[1])[1];
    }

    public function tryAddNewSectionToChangelog()
    {
        $changelog = file_get_contents($changelog_pathname = "{$this->get_pathname()}/changelog.txt");

        $lines = explode(PHP_EOL, $changelog);
        if ($lines[2] == 'Date: ????') return;

        $next_version = $this->info()['version'];

        if ($next_version == $this->getLastVersionFromChangelog()) {
            preg_match('/^Version: (\d+)\.(\d+)\.(\d+)$/', $lines[1], $matches);
            if (count($matches) == 0) throw new \LogicException();

            list(, $major, $minor, $patch) = $matches;
            $patch = intval($patch) + 1;

            $next_version = "{$major}.{$minor}.{$patch}";
        }

        $lines = array_merge([
            '---------------------------------------------------------------------------------------------------',
            "Version: {$next_version}",
            'Date: ????',
            '  Info:',
        ], $lines);

        file_put_contents($changelog_pathname, implode(PHP_EOL, $lines));
    }

    public function addInfoToChangelog(string $info): void
    {
        $this->tryAddNewSectionToChangelog();

        $changelog = file_get_contents($changelog_pathname = "{$this->get_pathname()}/changelog.txt");
        $lines = explode(PHP_EOL, $changelog);

        $line_to_add = '    - ' . $info;

        $info_found = false;
        foreach ($lines as $i => $line) {
            if ($info_found && str_starts_with($line, '    - ') === false) {
                array_splice( $lines, $i, 0, $line_to_add);
                file_put_contents($changelog_pathname, implode(PHP_EOL, $lines));

                passthru("git add {$changelog_pathname}");
                passthru('git commit --amend --no-edit');

                return;
            }

            if (str_starts_with($line, '  Info:')) $info_found = true;
        }

        throw new \LogicException();
    }

    public function majorVersionIsZero(): bool
    {
        $version = explode('.', $this->info()['version']);
        return $version[0] == "0";
    }

    public function getNextMajorVersion(): int
    {
        list($major, $minor, $patch) = explode('.', $this->info()['version']);
        return intval($major) + 1;
    }

    public function setInfoJsonVersion(string $version): void
    {
        $search = $this->info()['version'];
        $replace = $version;

        // not done via json decode/encode to preserve whitespaces
        $info_json_text = file_get_contents($info_json_path = "{$this->get_pathname()}/info.json");
        $info_json_text = str_replace($search, $replace, $info_json_text);
        file_put_contents($info_json_path, $info_json_text);
    }

    public function setInfoJsonFactorioVersion(string $version): void
    {
        $search = '    "factorio_version": "'. $this->info()['factorio_version'] .'",';
        $replace = '    "factorio_version": "'. $version .'",';

        // not done via json decode/encode to preserve whitespaces
        $info_json_text = file_get_contents($info_json_path = "{$this->get_pathname()}/info.json");
        $info_json_text = str_replace($search, $replace, $info_json_text);
        file_put_contents($info_json_path, $info_json_text);
    }
}
