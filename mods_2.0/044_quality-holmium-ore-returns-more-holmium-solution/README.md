This mod adds a new chemical plant to which the holmium solution recipe has moved.

Using some trickery to make it both user friendly and stable this mod gives you bonus holmium solution based on the ore's quality.

Normal gives you nothing extra, uncommon × 2, rare × 4, epic × 8, and legendary × 32 `(1 * 2 ^ level)`  

Quality modules can be used inside this machine just fine, it'll count towards the output as usual.

What's that yellow arrow and the white selection box? Well my friend that is the price you have to pay for this mod feeling so smooth.

# new since 1.1.0

You can provide your own formula via settings, some examples: (you have access to both a quality object and the math helper)
- `1 * math.pow(2, quality.level)`, scales 1 2 4 8 32
- `1 + quality.level`, scales 1 2 3 4 6
Note that you can shoot yourself in the foot with this without any effort, the math is not validated, it works or it crashes.
(oh and try to avoid decimals, it'll probably not crash but they will be rounded down silently, desyncing from the tooltip)

Oh and if you find a formula that feels nice/fair/balanced/enjoyable you are encouraged to reach out and let me know yours.
