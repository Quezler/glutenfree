(async function() {
  let breadcrumbs = window.location.pathname.split('/');
  let mod_name = breadcrumbs[breadcrumbs.length-2];

  let table = document.getElementsByClassName("mod-page-downloads-table")[0];
  table.children[0].children[0].children[1].textContent = "Base version";
  let tbody = table.children[1];

  let map = new Map; // version string to game version column
  for (tr of tbody.children) 
    map.set(tr.children[0].textContent, tr.children[1]);
  
  // not up to the regex spec like at all, but it is good enough for now.
  // note that we are only checking base and not any of the dlc mods.
  function guess_base_version(dependency)
  {
    if (dependency.includes("base "))
      return dependency.split("base ")[1];
  }

  let response = await fetch(`https://mods.factorio.com/api/mods/${mod_name}/full`);
  let json = await response.json();
  json.releases.forEach(release => {
    release.info_json.dependencies.forEach(dependency => { // probably needs an optional check
      let base_version = guess_base_version(dependency);
      if (base_version)
        map.get(release.version).textContent = base_version;
    });
  });
})();
