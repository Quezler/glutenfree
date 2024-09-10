<?php

namespace App\Misc;

use Carbon\Carbon;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;

class ModPortal
{
//    private \GuzzleHttp\Client $guzzle;
//
//    private array $mods;
//    private array $my_mods_full;
//
//    public function __construct()
//    {
//        $this->guzzle = new \GuzzleHttp\Client();
//    }
//
//    public function get_mods(): array
//    {
//        if (! $this->mods)
//        {
//            $response = $this->guzzle->get('https://mods.factorio.com/api/mods?page_size=max');
//            $this->mods = json_decode($response->getBody()->getContents(), true)['results'];
//        }
//
//        return $this->mods;
//    }
//
//    public function get_my_mods()
//    {
//        return array_filter($this->get_mods(), function (array $mod) {
//            return $mod['owner'] == 'Quezler';
//        });
//    }
//
//    public function get_my_mods_full()
//    {
//
//    }

    public static function get_my_mods_full(): array
    {
        $guzzle = new Client();

        $response1 = $guzzle->get('https://mods.factorio.com/api/mods?page_size=max');
        $json1 = json_decode($response1->getBody()->getContents(), true);

        $my_mods = [];
        foreach ($json1['results'] as $mod) {
            if ($mod['owner'] == 'Quezler') $my_mods[] = $mod['name'];
        }

        $response2 = $guzzle->post('https://mods.factorio.com/api/mods?page_size=max&full=true', [
            'form_params' => ['namelist' => implode(',', $my_mods)],
        ]);
        $json2 = json_decode($response2->getBody()->getContents(), true);

        foreach ($json2['results'] as $i => $mod) {
            $json2['results'][$i]['carbon'] = Carbon::parse($mod['created_at']);
        }

        usort($json2['results'], fn($a, $b) => $a['carbon'] <=> $b['carbon']);

        return $json2;
    }
}
