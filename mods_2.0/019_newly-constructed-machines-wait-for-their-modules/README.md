You woudln't believe how many draft names there were until i hit one that is exactly the mod name length limit:

assembling-machines-from-ghosts-wait-for-modules
blueprinted-assembling-machines-wait-for-modules
copy-pasted-assembling-machines-wait-for-modules
assemblers-machines-wait-till-modules-are-delivered
crafting-machines-waiting-on-modules-remain-idle
assembling-machine-waiting-on-modules-remain-idle
machines-wait-for-their-modules-to-be-delivered
new-crafters-wait-for-their-modules-to-be-delivered
machines-remain-inactive-as-they-wait-for-modules
newly-constructed-machines-wait-for-their-modules

Anyways: consumption, speed & pollution are ignored, its not exactly bad if a machine goes a while without any of those right? (low power perhaps)

How this mod functions:

When you or a bot builds an entity, if at that moment the entity is requesting either productivity or quality modules (aka it was a ghost with modules) the machine will wait till it is no longer waiting on any of those 2 module types, once it stops waiting it'll never wait again.

You can edit the requested modules just fine, but if at any point the machine is no longer requesting modules with quality or productivity effects it'll unfreeze, it currently also does not care if the slot its trying to insert into already has a module of that type installed.

If the machine requested non productivity/quality modules initially and you change those deliveries to productivity/quality modules it'll not wait,
what matters is the module requests the ghost has at the time a player/bot comes to build the entity, you can quickly add prod/qual to the ghost tho.

TLDR: this stops a machine from starting with crafting until it has received all its initial modules that have a positive effect on the output item.

# 1.1.0 update

Now supports pausing existing entities if you're requesting productivity/quality modules for empty slots, or swapping out speed/efficiency modules.
