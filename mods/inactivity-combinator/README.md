When you place this combinator the mod adds some hidden combinators to a hidden surface that do the actual math,
if you wish this surface can be visited with `/c game.player.teleport({0, 0}, "inactivity-combinator")` if you want to see how it works.

This combinator only expects red signals as an input, good luck trying to connect a green wire to the input side btw,
also you should avoid sending the virtual T signal as that is currently used internally to keep track of the ticks passed.

My main usecase is to detect when a conveyor stops moving, to do so just connect this combinator to a belt on read pulse mode,
alternatively you can also ignore full conveyors by checking for read hold since this mod only outputs when all red signals are 0.
