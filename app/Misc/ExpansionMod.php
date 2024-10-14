<?php

namespace App\Misc;

use GuzzleHttp\Client;
use GuzzleHttp\Psr7\Utils;

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

    public function build(): void
    {
        $source = __GLUTENFREE__ . '/mods_2.0/' . $this->directory;
        $zip_name_without_extension = $this->name . '_' . $this->info()['version'];
        $dest = __GLUTENFREE__ . '/build/' . $zip_name_without_extension;

        passthru(sprintf("rsync -avr --delete %s/ %s", $source, $dest));
        passthru(sprintf("(cd %s && zip -FSr %s %s)", __GLUTENFREE__ . '/build/', "{$dest}.zip", $zip_name_without_extension));
    }

    public function publish(): void
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

        dump($response->getBody()->getContents());
        exec("open https://mods.factorio.com/mod/{$this->name}/edit");
    }
}
