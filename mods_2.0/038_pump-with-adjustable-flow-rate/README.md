Reused some [old tech](https://github.com/Quezler/glutenfree/blob/ab6f2083dd01b53b4c4a27bf94b359425fed5826/mods/se-core-miner-drilling-mud/data.lua#L76) to make a pump with an adjustable flow rate.

These pumps require the the virtual signal F to function at all, and as long as you do not change the signal it'll use 0 ups. (save for every hour)

Try not to spam lots of changing signals tho, a selector combinator on random input mode with a high interval is recommended.

Quality pumps are not supported, signal 0 maps to 0% and 1200 maps to 100%, therefore for higher quality pumps you will see different speeds.

Note that in some instances the flow rate can be 1 above or below what the actual signal is, you'll just have to learn to live with it.

(some minor technical details: ignore the brown fluid level, temperature reflects speed, pump use no electric power, ignore consumption)
