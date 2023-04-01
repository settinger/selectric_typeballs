case = 0;
row = 0;
column = 0;
glyphnum = 97;

glyph = chr(glyphnum);

$fn=24;

fontSize = 2.3;
myFont = "Comic Sans MS:style=Regular";
//fontSize = 1.8;
//myFont = "Digohweli:style=Regular";

rotate([90, 0, -90]) translate([0, -fontSize/2, 0])  linear_extrude(.6) offset(r=.01) offset(r=-.02) offset(r=.01) text(glyph, size=fontSize, halign="center", font=myFont);