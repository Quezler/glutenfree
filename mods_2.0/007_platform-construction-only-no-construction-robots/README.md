The vanilla construction robots become invisible and teleport to their build/deconstruct/cliff/pickup/module/etc task,
when they try to fulfill an entity ghost the platform build animation will play to give the instant construction some flair.

The animation might not entirely match the platform speed in terms of how quick their neighbours start, how long they stay up, etc,
there is a lot going on on the c++ side in terms of the building animations so i took some creative liberty when porting it to lua.

**warning!** in versions below 2.0.16 your game can freeze/crash when deconstructing stuff, but constructing new stuff to see the animation is safe.
