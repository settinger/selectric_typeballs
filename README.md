# How to make your own Selectric Typeballs
## March 31, 2023

# this may get pretty complex fast, and i won't have time to improve the documentation for a while sorry everyone

The [IBM Selectric typewriter](https://www.ibm.com/ibm/history/ibm100/us/en/icons/selectric/) uses an instantly-recognizable "ball" of type instead of a fanned-out array of arms like a conventional typewriter. These typeballs could be swapped out, meaning you could easily write documents with different fonts, font sizes, special characters, or different writing systems altogether.

IBM and some other vendors made lots of different typeballs, but most of them are 40-50 years old and no one has been making new typeballs for a long time. 3D printing is a natural fit for making new typeballs, but most printers still don't have the ability to produce the sharp details necessary on a sufficiently-resilient material. So it's understandable that no one tried to make a really polished 3D-printable typeball. Until now, that is!

## TODO: EXPLAIN HOW THE GEOMETRY WORKS, BECAUSE I'M REALLY QUITE PROUD OF IT

## How to use the code
Things you need before getting started:
* OpenSCAD (This will possibly be replaced with CadQuery in a later revision, please be aware! Until then I only know how to run this program on Windows.)
* A Python installation with the [pymeshlab](https://pypi.org/project/pymeshlab/) package

1. Open `oneletter.scad` and change lines 10 and 11, the ones that specify the font height (in millimeters) and the font name/style for OpenSCAD to use.
1. Open `selectric_generator.py` and change line 5, the one that says `PATH TO OPENSCAD = r"{something}"` so that it points to your installation of `openscad.com` (not `openscad.exe`! They are in the same folder probably, but the `.com` is meant to be run from command line, which is what we'll be doing.
1. If you want to change the keyboard layout, edit `uppercase.txt` and `lowercase.txt`. Right now the way they are set up is a little...strange. I need to adjust that, I have some ideas!
1. Run `selectric_generator.py`. On my machine, each character takes between 1 and 30 seconds to generate, depending on their complexity. So 88 characters will take a while, be patient!

## Some extra things

The blank typeball is based on [1944GPW's typeball on Thingiverse](https://www.thingiverse.com/thing:4126040), which is released under a Creative Commons-Attribution license. I suspect that my project wouldn't exist if it weren't for this one. I had to change most of their typeball dimensions, and there are major issues with the way their characters are generated, but I sure as heck would have made those same errors myself, so I'm infinitely grateful for the people before me who documented their processes!

To make a typeball that sticks close-ish to the standard Cherokee keyboard layout:
```
uppercase.txt
ᎱᏧᏡᎺᎰᏃᏇᎹᏝᏤᎶ
ᏭᎭᏐᏟᎮᏘᎻᏣᎧᎲᏰ
ᎷᏞᏏᏌᏬᏑᎴᏀᏱᏎᏫ
ᏥᏈᏠᏢᏉᎫᎽᏆᏪᏲᎼ
```

```
lowercase.txt
ᏊᏩᏋᏖᏙᎬᏮᏦᏜᏄᏒ
ᏴᎤᏗᏓᎵᏔᎾᎡᎸᎯᎨ
ᏅᎥᏛᎠᎣᏕ.'ᎢᏍᎳ
ᎦᎩᏨ,ᏂᏚᏳᎪᏁᏯᎿ
```