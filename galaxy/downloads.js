(async function() {
  let breadcrumbs = window.location.pathname.split('/');
  let mod_name = breadcrumbs[breadcrumbs.length-2];
  // console.log(mod_name);

  let table = document.getElementsByClassName("mod-page-downloads-table")[0];
  table.children[0].children[0].children[1].textContent = 'Base version';
  let tbody = table.children[1];
  let map = new Map; // version string to game version column
  for (tr of tbody.children) {
    map.set(tr.children[0].textContent, tr.children[1]);
  }
  // console.log(map);

  // not up to spec with the exact dependency regex format, simple rushed version.
  function guess_min_base_version(dependency)
  {
    let parts = dependency.split(' ');
    if (!parts.includes("base")) return;

    if (3 > parts.length) return;

    return parts.at(-2) + " " + parts.at(-1);
  }

  let response = await fetch(`https://mods.factorio.com/api/mods/${mod_name}/full`);
  let json = await response.json();
  json.releases.forEach(release => {
    release.info_json.dependencies.forEach(dependency => { // probably needs an optional check
      let min_base_version = guess_min_base_version(dependency);
      if (min_base_version) {
        map.get(release.version).textContent = min_base_version;
      }
    });
  });
})();
