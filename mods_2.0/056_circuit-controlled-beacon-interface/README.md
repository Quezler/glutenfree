A beacon interface strictly controlable by circuit signals instead of a gui,
doubles as a demo on how someone could build their own mod that depends on beacon interface.

If you have Editor Extentions installed you should already have it in your inventory,
otherwise use `/cheat all` to receive your complimentary circuit controlled beacon interfaces.

The following virtual signals are supported, keep the values in the -32768 to 32767 range:

S speed
P productivity
C consumption
E pollution (e for exhaust)
Q quality

Todo:

- instead of polling every 60 ticks, add a hidden surface that fires events only if one of those 5 signals change
- not breaking the circuit wires if you upgrade the quality of the beacon
