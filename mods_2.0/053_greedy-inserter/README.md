Don't you wish inserters could grab some items ahead of time? (like when fetching from sushi belts, they don't exactly buffer)

Due to optimizations reasons the "read hand contents" MUST be on "hold", and you MUST NOT send it signals on the red wire, green is fine.
(reading from the red wires is fine, beware that if you read from several greedy inserters at the time that you do not daisy chain wires)
(why the red wire? eh just personal preference, i tend to use red for inventory/read signals and green for control/filter signals myself)
