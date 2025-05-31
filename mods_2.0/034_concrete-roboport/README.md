Time really flies by, it is time for my 200th mod!
For this special occasion lets dig up a pet project that never really went forgotten: "Concrete Roboports"

Back in March 2023 i lay the groundwork for said mod, the idea was to make it easier to make sub networks within a larger network,
Since roboports connect if their orange zones touch i wanted to keep them small, so what about a network you can shape with tiles?

Over the years it gained some love but there were always some caveats that kept me from wrapping up the mod:
- rendering, 1x1 roboports only draw the dotted lines at certain angles since they aren't drawn in between, but rather from one
- performance, having tons of 1x1 roboports can't be healthy, i learned the term "tiling algorithm" recently but at the time i was lost
- connectivity, some mods add roboports with a connecting range larger than orange which would prevent them from hiding isolated in the green

I have touched up the mod a little since my modding skills did evolve in the two years since, mainly in part to this awesome community!
In the past i struggled understanding concepts such as global/storage but there were always people willing to take the time to explain,
nowadays i can often be found roaming the modding channels and trying to help out where i can, passing on knowledge to new brave souls.

So yeah, thanks Factorio modding community for making me feel at home, i am here to stay and looking forward to see what the future brings!

(between the days of writing this and finishing the mod up from mere prototype to stable-enough mod i had to rewrite quite a lot, who knew)

=====

Concrete roboports placed on player minable tiles (landfill, stone, concrete, foundations, frozen variants, etc) form an orange zone,
this allows you to make small logistic subnetworks as long as no normal roboports are nearby enough to connect.

In vanilla roboports only connect if their orange zones touch (so you can have a concrete network within the green construction zone),
but if mods add roboports with a connection area bigger than the logistic area you might see them connect to your concrete networks.

There can be a small drop in performance when you remove a large concrete roboport network since each tile is a roboport,
using a tiling algorithm in the future would be nice, but for now each tile needs to go through the disconnecting sequence.

Uses public domain textures from [Dr_Pepper](https://mods.factorio.com/user/Dr_Pepper)
