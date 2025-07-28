By default the "Read logistic network contents" also includes buffer, passive & active chests.

This is not very ideal when you have circuits/logic in place to keep your storage chests topped off,
since if buffers request items they still report as available even though they are rather inaccessible.
(well there is the checkbox on requester chests but that is a whole can of worms with priority and stuff)

This mod contains a roboport reskin that outputs just the contents of storage chests on any wire you connect.

The current update rate is once every 2.5 seconds, this should be plenty for pretty much all restocking usecases.

Note to self, the contending names:

roboport-read-logistic-network-contents-storage-only
roboport-that-only-reads-logistic-storage-contents
roboport-that-only-reads-what-is-in-storage-chests
roboport-contents-circuit-only-reads-storage-chests
roboport-that-only-cares-about-logistic-chests
roboport-that-only-sums-logistic-chest-content
yellow-roboport-that-only-sums-storage-contents
yellow-roboport-that-only-counts-storage-contents
