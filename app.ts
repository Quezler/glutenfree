import { debounce } from "https://deno.land/std@0.109.0/async/debounce.ts";

const inotify = debounce(
    (event: Deno.FsEvent) => {
        console.log(event);
        const [, name] = /\/mods\/([a-z-]+)\//.exec(event.paths[0]);

        console.log(name);

        Deno.run({ cmd: ["php", "app.php", "rsync", name] });
    },
    10,
);


const watcher = Deno.watchFs(`${Deno.cwd()}/mods/`);
for await (const event of watcher) inotify(event);


