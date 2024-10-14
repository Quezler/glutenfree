<?php

namespace App\Misc;

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
}
