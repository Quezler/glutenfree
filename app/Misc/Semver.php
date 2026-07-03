<?php

namespace App\Misc;

class Semver
{
    public string $major;
    public string $minor;
    public string $patch;

    public function __construct(string $version)
    {
        list($major, $minor, $patch) = explode('.', $version);

        $this->major = $major;
        $this->minor = $minor;
        $this->patch = $patch;
    }

    public function __toString(): string
    {
        return $this->major . '.' . $this->minor . '.' . $this->patch;
    }
}
