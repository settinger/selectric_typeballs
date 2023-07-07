# How to make your own Selectric Typeballs

## March 31, 2023

![A 3D printed typeball for the IBM Selectric. The font is Comic Sans. There is ink on most of the letters.](img/typeball.jpg)
![A sheet of lined paper in a typewriter with several lines of Cherokee text; the 3d printed typeball that made the text is visible in the lower left.](img/cherokee.jpg)

The [IBM Selectric typewriter](https://www.ibm.com/ibm/history/ibm100/us/en/icons/selectric/) uses an instantly-recognizable "ball" of type instead of a fanned-out array of arms like a conventional typewriter. These typeballs could be swapped out, meaning you could easily write documents with different fonts, font sizes, special characters, or different writing systems altogether.

IBM and some other vendors made lots of different typeballs, but most of them are 40-50 years old and no one has been making new typeballs for a long time. 3D printing is a natural fit for making new typeballs, but most printers still don't have the ability to produce the sharp details necessary on a sufficiently-resilient material. So it's understandable that no one made a really functional 3D-printable typeball. Until now, that is!

## Warning
Please keep in mind that the spindle that the typeball sits on is fragile. Do not force a typeball onto the spindle if it does not fit, and do not attempt to salvage a print by shaving it down. The typeball can become stuck on the delicate spindle, damaging your vintage typewriter. Similarly, do not use a typeball if it is too loose and cannot be attached securely. It could fly off and damage its surroundings.

You may wish to use a small amount of sewing machine oil on the inside of your print, to help it as it spins, and to catch any resin dust that is created by the printed ball rubbing against the spindle mount.

Any damage incurred through the use of this software and its resulting typeballs are not our liability.

## How to use the code
Things you need before getting started:
* OpenSCAD
* A Python installation with the [pymeshlab](https://pypi.org/project/pymeshlab/) package

1. Open `oneletter.scad` and change lines 11 and 12, the ones that specify the font height (in millimeters) and the font name/style for OpenSCAD to use.
1. Open `selectric_generator.py` and change line 5, the one that says `PATH TO OPENSCAD = r"{something}"` so that it points to your installation of `openscad.com` (not `openscad.exe`! They are in the same folder probably, but the `.com` is meant to be run from command line, which is what we'll be doing.
1. If you want to change the characters on the balls, edit `glyph_tables.py`. This contains a multi-dimensional array of the characters as they are arrayed on the typeball, *not as they are laid out on the keyboard*. If you want to use a different character set than the standard Latin, you'll have to find a correspondence between the new set and your preexisting keyboard layout. Sorry this part may be extra-confusing.
1. Run `selectric_generator.py`. On my machine, each character takes between 1 and 30 seconds to generate, depending on their complexity. So 88 characters will take a while, be patient!

## Acknowledgements

The blank typeball is based on [1944GPW's typeball on Thingiverse](https://www.thingiverse.com/thing:4126040), which is released under a Creative Commons-Attribution license. I suspect that my project wouldn't exist if it weren't for this one. I had to change most of their typeball dimensions, and there are major issues with the way their characters are generated, but I sure as heck would have made those same errors myself, so I'm infinitely grateful for the people before me who documented their processes!

Another project that deserves a lot of credit is [The Sincerity Machine by Jesse England](jesseengland.net/project/sincerity-machine-the-comic-sans-typewriter/). Jesse is a delight and a constant source of creative inspiration for me, and it brings me great joy to watch this project evolve with him.

## EXPLAINING HOW THE GEOMETRY WORKS, BECAUSE I'M REALLY QUITE PROUD OF IT (BUT YOU CAN SKIP THIS SECTION, IT WON'T HURT MY FEELINGS)

![A Meshlab render of the octothorpe symbol with lofted edges](img/loft.png)

Getting those nice lofted edges on each glyph was not easy! I came up with a rather elaborate way that worked pretty well, but then got an excellent suggestion from Kris Slyka that works so, so much better. This is truly a community effort. I'd be very curious to hear how you would have approached it!!

The [OpenSCAD Typeball by 1944GPW](https://www.thingiverse.com/thing:4126040) attempts to loft the shapes by scaling the letterform. This was my first thought, as well, but since the letters scale around a specific point, it means the lofted sides won't all spread out evenly. Instead you get unhelpful overhangs:

![An OpenSCAD render of the letter "N" with steeply slanted edges that would not print well](img/badloft.png)

Instead of a scaled extrusion, we need the base to be a puffed-out offset version of the original letterform. It's not trivial to do that in an automated fashion, especially if there are small holes that will close up (like in the middle of the # character). The method I came up with uses a command-line script to extrude the letter in OpenSCAD and then displace one layer of vertices by their normal vectors. This means the vertex will always be pushed *out* away from the body of the STL.

![](img/pvgm1.png)
![](img/pvgm2.png)

If you look at the underside of each letter, you'll see a that this method leaves a lot of topological scars from attempts to re-mesh this self-intersecting shape. But it turned out to be pretty printable, so I released the project with this approach.

![](img/loft_nonmani.png)

After seeing the discussion about typeballs on Mastodon, Kris Slyka approached me to suggest using OpenSCAD's `minkowski()` function. It has a reputation for being agonizingly slow, and trying to generate all the glyphs at once would exhaust my PC's memory, but with the batch-script, one-letter-at-a-time method, it can work! I highly recommend getting a recent build of OpenSCAD nightly; the fast-csg setting makes `minkowski()` operations so, so much faster.

# Extra thoughts

[I put some typeballs on Printables!](https://www.printables.com/search/models?q=tag:typeball%20@settinger_263029) They are also available on Shapeways (links in the Printables descriptions) if you don't want to print them yourself.

To affix the typeball to the typewriter, you will need a bent wire or a small clip [such as this one from Dave Hayden](https://www.printables.com/model/416841-selectric-ball-clip). Thank you Dave for encouraging me to pick up the Selectric project again!

I had been testing on a not-fully-functional Selectric I, which I think was set to 12 characters per inch. Knowing characters per inch is important for joined/cursive scripts like Mongolian. It would really help if I knew how to change the writing direction, I know some Selectrics had an RTL/LTR switch...

Other right-to-left scripts to try: Thaana, N'ko

Other typeballs to try: Osage, Tifinagh, various runes, emoji, Avoiuli, um......what else?
