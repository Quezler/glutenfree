const prototypes_in = Bun.file("./tools/prototypes.lua");
const prototypes_out = Bun.file("./scripts/prototypes.lua");

// console.log(import.meta.url);

let lines = (await prototypes_in.text()).split('\n');
lines.pop();

lines.forEach((line, i) => {
  const parts = line.split(' - ');
  parts[1] = parts[1].padEnd(27, ' ');
  lines[i] = `  ` + parts.reverse().join(', - ');
});

lines.unshift('return {');
lines.unshift('local abstract = "abstract" -- eh this just felt easier than coming up with a different name or comment strategy :)');
lines.push('}');

await Bun.write(prototypes_out, lines.join('\n'));
