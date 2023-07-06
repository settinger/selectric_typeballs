// This is a reduced-complexity version of the original typeball .scad file by 1944GPW on Thingiverse
// Several constants were changed to fit my printer, your own needs may vary!


// f) sloppiness fit on spigot

UPPER_BALL_SOCKET_TOLERANCE = 0; // [ -0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4]

SLOT = true;

CLIP_SCREW_DIA = 1.8;        // [1.5,1.6,1.7,1.8,1.9,2.0,2.1,2.2,2.3]


//----------------------------------------------------------------------------------------------------------
module customizer_stopper() {}  // Stop Customiser looking at variables beyond this 

// Rendering granularity for F5 preview and F6 render. Rendering takes a LOT of time.
PREVIEW_FACETS = 40;
RENDER_FACETS = 135;

FACETS = $preview ? PREVIEW_FACETS : RENDER_FACETS;
FONT_FACETS = FACETS;
$fn = FACETS;

// Selectric II typeball sphere parameters
TYPEBALL_RAD = 0.6625*25.4;
TYPEBALL_WALL_THICKNESS = 2;
// Top face parameters
TYPEBALL_TOP_ABOVE_CENTRE = 11.4; // Flat top is this far above the sphere centre
DEL_BASE_FROM_CENTRE = 8.2;
DEL_DEPTH = 1.7;

// Detent teeth skirt parameters
TYPEBALL_SKIRT_TOP_BELOW_CENTRE = -5.33;  // Where the lower latitude of the sphere meets the top of the skirt
SKIRT_HEIGHT = 4.57;
TOOTH_PEAK_OFFSET_FROM_CENTRE = 6.1; // Lateral offset of the tilt ring detent pawl

// Parameters for the centre boss that goes onto tilt ring spigot (upper ball socket)
BOSS_INNER_RAD = 4.30 + UPPER_BALL_SOCKET_TOLERANCE;   //20190903  4.45;    // d=8.5
BOSS_OUTER_RAD = 5.3; //20190903    5.5;
BOSS_HEIGHT = 8.32; //20190914    8.69;
SLOT_ANGLE = -45;        //APPROXIMATION. TODO CHECK
SLOT_WIDTH = 1.9; //20190904    2;         //APPROXIMATION. TODO CHECK
SLOT_DEPTH = 0.3;         //APPROXIMATION. TODO CHECK
NOTCH_ANGLE = SLOT_ANGLE + 180;        //APPROXIMATION. TODO CHECK
NOTCH_WIDTH = 1.1;  // 20190904     1.5;         //APPROXIMATION. TODO CHECK
NOTCH_DEPTH = 3;//1.5;         //APPROXIMATION. TODO CHECK
NOTCH_HEIGHT = 2.2;        //APPROXIMATION. TODO CHECK  FOR NOTCH INSTEAD

// Inside reinforcement ribs
RIBS = 11;
RIB_LENGTH = 8.9;
RIB_WIDTH = 2;
RIB_HEIGHT = 3;

// Rabbit ears wire retaining clip screw hole parameters
RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE = 11.6;
RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT = 6.8;
SCREW_BOSS_RAD = CLIP_SCREW_DIA + 0.8;   // Inside, between ribs
// Character layout
CHARACTERS_PER_LATITUDE = 22;   // For Selectric I and II. 4 x 22 = 88 characters total.

// Generate the model.
TypeBall();
// The entire typeball model proper.
module TypeBall()
{
    CorrespondenceTypeBall();
}
module CorrespondenceTypeBall()
{
    difference()
    {
        HollowBall();
        if (SLOT)
            Slot();
        Notch();
        ScrewHoles();
        Del();
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
// position child (a typeface letter) at global latitude and longitude on sphere of given radius
module GlobalPosition(r, latitude, longitude)
{
    x = r * cos(latitude);
    y = 0;
    z = r * sin(latitude);    
    rotate([ITALIC_BIAS, 0, longitude])
        translate([x, y, z])
            rotate([0, 90 - latitude - NORTHWARDS_ZENITH_OFFSET, 0])
                children();
}

// The unadorned ball shell with internal ribs and screw bosses
module HollowBall()
{
    //difference()
    {
        Ball();
        offset(-3)
            Ball();
    }
    Ribs();
    ScrewBosses();
}

module Ball()
{
    arbitraryRemovalBlockHeight = 20;
    // Basic ball, trimmed flat top and bottom
    difference()
    {
        sphere(r=TYPEBALL_RAD);
        translate([-50,-50, TYPEBALL_TOP_ABOVE_CENTRE])
            cube([100,100,arbitraryRemovalBlockHeight]);
        //translate([-50,-50, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - arbitraryRemovalBlockHeight - 0.1])   // ball/skirt fudge factor
        translate([-50,-50, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - arbitraryRemovalBlockHeight])   // ball/skirt fudge factor
            cube([100,100,arbitraryRemovalBlockHeight]);
        sphere(r=TYPEBALL_RAD - TYPEBALL_WALL_THICKNESS);
    }
    // Fill top back in
    TopFace();
    // Detent teeth skirt
    //translate([0,0,0.05]) // fudge factor overlap ball/detent teeth
        DetentTeethSkirt();
    CentreBoss();
}

//////////////////////////////////////////////////////////////////////////
//// Detent teeth around bottom of ball
module DetentTeethSkirt()
{
    foo = .48;
    SKIRT_OUTSIDE_UPPER_RAD = 16.38-foo;
    SKIRT_OUTSIDE_LOWER_RAD = 15.45-foo;
    TOOTH_TIP_THICK = 1.2; //1.5;
    // Detent teeth skirt
    difference()
    {
        translate([0,0, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - SKIRT_HEIGHT])
            cylinder(r2=SKIRT_OUTSIDE_UPPER_RAD, r1=SKIRT_OUTSIDE_LOWER_RAD, h=SKIRT_HEIGHT);
        translate([0,0, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - SKIRT_HEIGHT])
            cylinder(r2=SKIRT_OUTSIDE_UPPER_RAD - TYPEBALL_WALL_THICKNESS, r1=SKIRT_OUTSIDE_LOWER_RAD + TOOTH_TIP_THICK - TYPEBALL_WALL_THICKNESS, h=SKIRT_HEIGHT);        
        translate([0,0, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - SKIRT_HEIGHT])
            DetentTeeth();
    }
}

// Ring of detent teeth in skirt
module DetentTeeth()
{
    segment = 360 / CHARACTERS_PER_LATITUDE;
    half_tooth = 0;     //segment / 2;
    for (i=[0:CHARACTERS_PER_LATITUDE - 1])
        rotate([0, 0, segment * i + half_tooth])
            Tooth();
}

module Tooth()
{
    translate([0, TOOTH_PEAK_OFFSET_FROM_CENTRE, 0])
        rotate([180, -90, 0])
        {
            linear_extrude(30)
            {
                polygon(points=[[3,0], [0,1.9], [-1,1.9], [-1,-1.9], [0,-1.9]]);
                translate([0, -.15, 0])
                    square([3.1, .3]);
            }
        }
}

//////////////////////////////////////////////////////////////////////////
//// Flat top of typeball, punch tilt ring spigot hole through and subtract del triangle
module TopFace()
{
    // Fill top back in, after the inside sphere was subtracted before this fn was called
    difference()
    {
        translate([0, 0, TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS])
            cylinder(r=11.8, h=TYPEBALL_WALL_THICKNESS);
        translate([0, 0, TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS])
            cylinder(r=BOSS_INNER_RAD,h=TYPEBALL_WALL_THICKNESS*2);
        Del();
    }   
}

// Alignment marker triangle on top face
module Del()
{
    translate([DEL_BASE_FROM_CENTRE, 0, TYPEBALL_TOP_ABOVE_CENTRE - DEL_DEPTH])
        color("white")  // TODO red triangle for Composer typeball
        linear_extrude(DEL_DEPTH)
            polygon(points=[[3.4,0],[0,1.5],[0,-1.5]]);
}

// Emboss the font name (truncated) onto top face, and also an estimate of font pitch

// Clean up any base girth bits of T0-ring characters projecting above top face
module TrimTop()
{
    translate([-50,-50, TYPEBALL_TOP_ABOVE_CENTRE])
        cube([100,100,20]);
}

//////////////////////////////////////////////////////////////////////////
// Tilt ring boss assembly
module CentreBoss()
{
    translate([0,0, TYPEBALL_TOP_ABOVE_CENTRE - BOSS_HEIGHT])
        difference()
        {
            cylinder(r=BOSS_OUTER_RAD, h=BOSS_HEIGHT);
            cylinder(r=BOSS_INNER_RAD, h=BOSS_HEIGHT);
        }    
}

// The full-length slot in the tilt ring boss at the half past one o'clock position
module Slot()
{
    rotate([0, 0, SLOT_ANGLE])
        translate([0, -SLOT_WIDTH/2, 0])
            cube([SLOT_DEPTH + BOSS_INNER_RAD, SLOT_WIDTH, 40]);
}

// The partial-length slot in the tilt ring boss at the half past seven o'clock position
module Notch()
{
    rotate([0, 0, NOTCH_ANGLE])
        translate([0, -NOTCH_WIDTH/2, TYPEBALL_TOP_ABOVE_CENTRE - BOSS_HEIGHT])
            cube([NOTCH_DEPTH + BOSS_INNER_RAD, NOTCH_WIDTH, NOTCH_HEIGHT]);
}

// The reinforcement spokes on the underside of the top face, from the tilt ring boss 
// to the inner sphere wall
module Ribs()
{
    segment = 360 / RIBS;
    for (i=[0:RIBS - 1])
        rotate([0, 0, segment * i])
            translate([BOSS_OUTER_RAD - 0.7, -RIB_WIDTH/2, TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS - RIB_HEIGHT])
                cube([RIB_LENGTH, RIB_WIDTH, RIB_HEIGHT]);
    
}

// The two self-tapping screw holes in the top face
module ScrewHoles()
{
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2, 0])
        cylinder(d=CLIP_SCREW_DIA, h=50);
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, -RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2, 0])
        cylinder(d=CLIP_SCREW_DIA, h=50);
}

// The underside of the screw holes
module ScrewBosses()
{
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2,TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS - RIB_HEIGHT])
        cylinder(r=SCREW_BOSS_RAD, h=RIB_HEIGHT);
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, -RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2,TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS - RIB_HEIGHT])
        cylinder(r=SCREW_BOSS_RAD, h=RIB_HEIGHT);
}

