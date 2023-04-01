import pymeshlab as ml
import os
import subprocess

PATH_TO_OPENSCAD = r"C:\Program Files\OpenSCAD\nightly\openscad.com"

if __name__ == "__main__":
    
    # First, process the glyph tables (uppercase.txt and lowercase.txt)
    glyphs = []
    
    with open("uppercase.txt", "r", encoding="utf-8") as uppercaseText:
        rows = uppercaseText.readlines()[0:4]
        rows = [x.strip("\r\n") for x in rows]
        if len(rows[0]) != 12:
            print("First keyboard row should have 12 characters!")
            raise
        elif len(rows[1]) != 11:
            print("Second keyboard row should have 11 characters!")
            raise
        elif len(rows[2]) != 11:
            print("Third keyboard row should have 11 characters!")
            raise
        elif len(rows[3]) != 10:
            print("Fourth keyboard row should have 10 characters!")

        a = rows[0]
        b = rows[1]
        c = rows[2]
        d = rows[3]
        
        ballOrder = [a[0]+a[2]+a[6]+a[7]+a[3]+d[0]+a[1]+a[4]+a[5]+a[9]+a[8],
                     d[1]+b[6]+c[2]+d[2]+c[8]+b[4]+d[5]+b[2]+c[7]+c[5]+d[4],
                     d[6]+d[3]+b[3]+c[0]+b[8]+b[10]+d[8]+c[10]+b[7]+c[1]+b[1],
                     c[4]+c[3]+c[9]+d[7]+d[9]+c[6]+a[11]+b[0]+b[9]+b[5]+a[10]]
        
        for row, line in enumerate(ballOrder):
            for column, glyph in enumerate(line):
                glyphs += [(row, column, 1, glyph)]
    
    with open("lowercase.txt", "r", encoding="utf-8") as lowercaseText:
        rows = lowercaseText.readlines()[0:4]
        rows = [x.strip("\r\n") for x in rows]
        if len(rows[0]) != 12:
            print("First keyboard row should have 12 characters!")
            raise
        elif len(rows[1]) != 11:
            print("Second keyboard row should have 11 characters!")
            raise
        elif len(rows[2]) != 11:
            print("Third keyboard row should have 11 characters!")
            raise
        elif len(rows[3]) != 10:
            print("Fourth keyboard row should have 10 characters!")

        a = rows[0]
        b = rows[1]
        c = rows[2]
        d = rows[3]
        
        ballOrder = [a[0]+a[2]+a[6]+a[7]+a[3]+d[0]+a[1]+a[4]+a[5]+a[9]+a[8],
                     d[1]+b[6]+c[2]+d[2]+c[8]+b[4]+d[5]+b[2]+c[7]+c[5]+d[4],
                     d[6]+d[3]+b[3]+c[0]+b[8]+b[10]+d[8]+c[10]+b[7]+c[1]+b[1],
                     c[4]+c[3]+c[9]+d[7]+d[9]+c[6]+a[11]+b[0]+b[9]+b[5]+a[10]]
        
        for row, line in enumerate(ballOrder):
            for column, glyph in enumerate(line):
                glyphs += [(row, column, 0, glyph)]
                
    # Define some values we'll use throughout this
    # Letters extend out 0.6875" from the center of the typeball
    # The ball itself has a radius of around 0.6625"
    # According to John Savard, the platen has a radius around 0.717" or so (http://www.quadibloc.com/comp/pro04.htm)
    letterRadius = 0.6875*25.4
    ballRadius = 0.6625*25.4
    platenRadius = 0.717*25.4

    # Other constants: the draft scale, which is somehow related to the angle of the sloping sides of each glyph; normscale, a string to fix a bug in Meshlab
    draftscale = 1.25
    normscale = "sqrt(nx^2+ny^2+nz^2)"

    # Create the main mesh set that will contain the final ball
    mainMeshSet = ml.MeshSet()

    # Make a /ballparts folder to hold each individual glyph shape
    if not os.path.exists("ballparts"):
        os.mkdir("ballparts")

    # Process each glyph in sequence
    for datum in glyphs:
        (row, column, case, glyph) = datum
        filename = f"ballparts/{row}-{column}-{case}.STL"
        # Generate an extruded letter using OpenSCAD (N.B. I could do this in Cadquery for a pure-python solution, someday)
        cmd = f"\"{PATH_TO_OPENSCAD}\" -o \"{filename}\" -D glyphnum={ord(glyph)} oneletter.scad"
        subprocess.run(cmd)
        # Sweet! Now load that letter into Meshlab, splay out the lower vertices, then subtract the platen cylinder and clean up the mesh
        ms = ml.MeshSet()
        ms.load_new_mesh(filename) # This is mesh ID 0
        # Duplicate that mesh and scoot it forward so the platen-cutting step cuts into a manifold shape, instead of a weird monster shape
        ms.generate_copy_of_current_mesh() # Mesh ID 1
        ms.compute_matrix_from_translation(traslmethod="XYZ translation", axisx=0.5)
        ms.generate_by_merging_visible_meshes() # Mesh ID 2
        ms.compute_selection_by_condition_per_vertex(condselect="x<-0.5") # shouldn't hard-code that dimension but whatever
        ms.compute_coord_by_function(x=f"x+.33*{draftscale}*nx/{normscale}", y=f"y+{draftscale}*ny/{normscale}", z=f"z+{draftscale}*nz/{normscale}", onselected = True)
        print(f"Glyph {glyph} drafted, subtracting platen shape")
        ms.create_cone(r0=platenRadius, r1=platenRadius, h=20, subdiv=360) # Mesh ID 3
        ms.compute_matrix_from_translation(traslmethod="XYZ translation", axisx=platenRadius)
        ms.generate_boolean_difference(first_mesh=2, second_mesh=3)
        print(f"Glyph {glyph} shaped, putting in place on typeball")
        ms.compute_matrix_from_translation(traslmethod="XYZ translation", axisx=letterRadius)
        ms.compute_matrix_from_rotation(rotaxis = 'Y axis', rotcenter = 'origin', angle = -32 + 16*row)
        ms.compute_matrix_from_rotation(rotaxis = 'Z axis', rotcenter = 'origin', angle = -180/11*column + 180*case + 5/11*180)
        ms.save_current_mesh(filename)
        mainMeshSet.load_new_mesh(filename)
        mainMeshSet.generate_by_merging_visible_meshes()
        mainMeshSet.save_current_mesh("ballparts/textForTypeball.STL")

    # Once all glyphs are processed, put them onto the typeball body
    print("Attaching glyphs to typeball body...")
    mainMeshSet = ml.MeshSet() # Just reset the meshset, it's easier this way
    mainMeshSet.load_new_mesh("ballparts/textForTypeball.STL")
    mainMeshSet.load_new_mesh("typeball_blank.STL")
    mainMeshSet.generate_boolean_union(first_mesh=0, second_mesh=1)
    mainMeshSet.save_current_mesh("typeball_finished.STL")
    print("Typeball finished!")
