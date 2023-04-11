// TODO: Put a preamble here

// Define some values we'll use throughout this
// Letters extend out 0.6875" from the center of the typeball
// The ball itself has a radius of around 0.6625"
// According to John Savard, the platen has a radius around 0.717" or so (http://www.quadibloc.com/comp/pro04.htm)
letterRadius = 0.6875*25.4;
ballRadius = 0.6625*25.4;
platenRadius = 0.717*25.4;

fontSize = 2.3;
myFont = "Comic Sans MS:style=Regular";

$fn=24;

codepoints=[98,99];
case = 0;
row = 0;
column = 0;
glyph = chr(codepoints);

rotate([0, 0, -180/11*column + 180*case + 5/11*180])
rotate([0, -32 + 16*row, 0])
translate([letterRadius, 0, 0])
rotate([0, 0, -90])
minkowski() {
  difference() {
    translate([0, 0.5, 0]) rotate([90, 0, 0]) linear_extrude(.55) translate([0, -fontSize/2, 0]) text(glyph, size=fontSize, halign="center", font=myFont);
    translate([0, platenRadius, 0]) rotate([0, 90, 0]) cylinder(h=20, r=platenRadius, $fn=360, center=true);
  }
  rotate([90, 0, 0]) cylinder(h=1, r1=0, r2=.6);
}