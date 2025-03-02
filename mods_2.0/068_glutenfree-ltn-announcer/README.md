This mod adds a programmable speaker to every LTN train stop.

Said programmable speaker is actually just a power pole that outputs two colors of signals:

red) a positive number for all the items/fluids currently scheduled for pickup there
green) a positive number for all the items/fluids currently scheduled for delivery there

When you first place a station (or when it hasn't received an update yet) it defaults to a red & green virtual signal of 1 respectively.

The signals update when the schedule of a train changes, which under normal curcumstances happens when:
- a train in the LTN depo gets dispatched, this updates the train's schedule, causing the speaker to update.
- a train arrives at a temporary track/station, this removes it from the schedule list, also causing an update.

When you manually start messing with the train's schedule (by removing/re-ordering stops) the station will keep outputing the signal until updated.

===

That was the how, now for the why:

In my current se+k2+ltn playthrough we have the logistic storage hooked up to provide its contents to the train network,
since during rocket crashes & setup maintenance a lot of the materials can end up in storage, and we want it out.

The problem we were facing is that sometimes bots might be slow to fully fill the requester chests (in time), causing other trains to wait.

It would be neat if you could see at the stop which pickups (or deliveries) were about to happen, so you can gather/prepare/buffer accordingly.

This is my most complicated mod to date, and i'm fairly sure there are situations where something might innevetably break, so beware when installing.
However, failures/crashes of this mod are unlikely to break ltn, you'll at most have to wait for a patch from this mod, or you could even safely remove it.

I'd say this mod is currently in beta, its past its mvp/alpha stage but it'll still need some work before considered finished/stable.

===

Lastly, are you Optera/Yousei9 and do you feel like this prototype/feature has a home within ltn itself? hit me up ^-^
