It appears the reason destruction markers for tiles get removed when hand mining on land is due to collision layers,
more specifically it looks as though the set_tile stuff removes colliding entities,
and the deconstruction marker by default collides with `ground-tile` so any change makes it commit self delete.

This mod adds Space Exploration's space layer to it too, causing it to behave (seemingly) properly in space.
Ideally after this has proven to cause no side effects should it be added directly into said mod.

The rubber ducking for this can be found here:

[Earendel -> bugs-forum -> Mined scaffold leaving deconstruction marker](https://discord.com/channels/419526714721566720/1279509631886032896)
