A proof of concept helper for the filter helper mod.

Ideally the filter helper maintainers think this is neat and worth implementing into the main mod.

(Why i didn't create a pull request to begin with? Well i wanted to test it out to see if it felt right)

# feature 1

Cloning the inserter/loader and opening that for 1 tick instead of setting it to nil for one tick.

This prevents the gui from flashing (though the status light at the top would show `disabled by script` for a tick)

# feature 2

When you remove a filter it moves the remaning filters to the left in order to fill the gap.
