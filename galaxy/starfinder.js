(async function(starfinder) {
  const star_label = document.getElementsByClassName("star-label")[0];
  if (star_label == undefined) return console.log("hover a star first.");

  const response = await fetch('https://factorio.com/galaxy', {method: 'GET', headers: {'Accept': 'application/json'}});
  const json = await response.json();
  console.log(json);

  const name_to_index = new Map();
  json.stars.users.forEach((name, index) => {
    name_to_index.set(name, index);
  });
  const my_index = name_to_index.get(starfinder);
  console.log(my_index);

  function index_to_coords(index) {
    return {x: json.stars.coordinates[index * 2], y: json.stars.coordinates[index * 2 + 1]}
  }

  const my_coords = index_to_coords(my_index);

  let current_star = star_label.textContent;
  function new_star_hovered() {
    const their_index = name_to_index.get(current_star);
    const their_coords = index_to_coords(their_index);
    // console.log(`#${their_index} ${current_star} @`, their_coords);
    console.log([my_coords.x - their_coords.x, my_coords.y - their_coords.y]);
  }

  // cursor events don't seem to fire for the star label, so lets bodge it a bit.
  setInterval(() => {
    if (current_star != star_label.textContent) {
      current_star = star_label.textContent;
      new_star_hovered();
    }
  }, 100);
})("Quezler");
