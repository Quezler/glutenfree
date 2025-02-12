### Introduction

Those familair with old minecraft modpacks might recognize the energy condenser,
in which you could set a target item and everything inside will slowly convert to that.

The quality condenser is roughly similar, set a target quality (or leave it uncapped),
then all the items inside will slowly combine and upgrade to the next quality tier over time.

### Functionality

It is similar to the recycler, but it returns the item itself instead of their ingredients,
and instead of a 25% output chance each item's upgrade (or void) chance is that machine's quality.

For example 100 items times 12.5% quality (100 * 0.125 = 12.5), those 12 are guaranteed items,
if the item count & quality percentage leave a decimal (.5 in this case) that becomes chance based,
based on how much is left the machine randomly rounds up or down, keeping the average completely fair.

If there is not enough for one guaranteed item the machine will skip that item/quality so you'll always have one.

### Usage

After researching (which is free) craft and place the device,
it consists of two parts, the center entity is the crafter in which you can put modules,
and the outer edge of the selection box will allow access to the container for the items.
(note that you cannot put items in the machine from the crafter gui, use inserters/loaders)

Do not forget to put in quality modules, those are what determine the upgrade chance after all.

Once the machine is full or idle for a few seconds it will start the upgrade cycle process,
you can leave the result items in to upgrade them more, or extract them for use elsewhere.

In order to limit which quality to upgrade too you can chance the quality of the recipe,
it will upgrade up to that quality, save for the normal quality which means uncapped.

Higher qualities of the machine itself are faster and have more upgrade slots,
note that beyond 100% quality there is no bonus, so you could use speed modules then.

### Configurability

In the startup settings you are able to change the module slots, base quality (per quality),
and even set which technologies unlock additional bonus quality ontop of the base quality,
some notable options to explain the format and serve as examples:

Base quality: (has access to lua's math helper)
- `0` (no base quality)
- `10 * (quality.level)` (no base quality, then 10% per quality)
- `10 * (quality.level + 1)` (10% base quality, then 10% per quality)

Technology effects: (flat value ontop of the base quality)
- `""` (no additional base quality)
- `planet-discovery-fulgora=10,planet-discovery-gleba=10,planet-discovery-vulcanus=10,planet-discovery-aquilo=20` (extra quality per known planet)
- `speed-module=-1,speed-module-2=-1.5,speed-module-3=-2.5` (want to punish some technology choices? you can)

### Number 3

This is the third mod in my quality upgrading serries:
1) https://mods.factorio.com/mod/awesome-sink
2) https://mods.factorio.com/mod/upcycler
3) https://mods.factorio.com/mod/quality-condenser

This mod was born due limitations in the first two mods and user requested features,
the most notable changes are in terms of throughput and performance, this mod is just better.

The quality condenser is capable of completely emulating the first two mods:
- for the awesome sink, just set module slots to 4
- for the upcycler, set the module slots to 0 and divide 100 by your "items per next quality" and set that as base quality

For a comparison table check out the previous version of this readme here:
https://github.com/Quezler/glutenfree/blob/main/mods_2.0/050_quality-condenser/README_1.md
(notable mentions: this mod does respect spoil percentages and does not kidnap inserted legendary items)

### Credits

- "Disruptor" (later named) "Research Center" graphics by [Hurricane046](https://mods.factorio.com/user/Hurricane046)
