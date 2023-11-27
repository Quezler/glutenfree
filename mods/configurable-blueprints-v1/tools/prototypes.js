const prototypes_in = Bun.file("./tools/prototypes.lua");
const prototypes_out = Bun.file("./scripts/prototypes.lua");

let lines = (await prototypes_in.text()).split('\n');
lines.pop();

lines.forEach((line, i) => {
  const parts = line.split(' - ');
  parts[0] = parts[0].padEnd(40, ' ');
  parts[1] = parts[1].padEnd(27, ' ');
  lines[i] = `  ` + parts.reverse().join(', -- ');
  lines[i] = lines[i].replace('  abstract', '--abstract');
});

lines.unshift('return {');
lines.push('}');

await Bun.write(prototypes_out, lines.join('\n'));
