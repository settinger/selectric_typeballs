import pymeshlab as ml
import os
import subprocess
import concurrent.futures

from glyph_tables import typeball

PATH_TO_OPENSCAD = r"C:\Program Files\OpenSCAD\nightly\openscad.com"

if __name__ == "__main__":

    # Define some values we'll use throughout this
    # Letters extend out 0.6875" from the center of the typeball
    # The ball itself has a radius of around 0.6625"
    # According to John Savard, the platen has a radius around 0.717" or so (http://www.quadibloc.com/comp/pro04.htm)
    letterRadius = 0.6875*25.4
    ballRadius = 0.6625*25.4
    platenRadius = 0.717*25.4

    # Create the main mesh set that will contain the final ball
    mainMeshSet = ml.MeshSet()

    # Make a /ballparts folder to hold each individual glyph shape
    if not os.path.exists("ballparts"):
        os.mkdir("ballparts")

    glyphs = []
    # Process each glyph in sequence
    with concurrent.futures.ThreadPoolExecutor() as executor:
        for case, hemisphere in enumerate(typeball):
            for row, line in enumerate(hemisphere):
                for column, glyph in enumerate(line):
                    # Skip this entry if no glyph is provided; otherwise, make an STL with OpenSCAD
                    if glyph=="": continue
                    filename = f"ballparts/{row}-{column}-{case}.STL"
                    # Generate an extruded letter using OpenSCAD
                    # Pass the glyph's unicode codepoint(s) instead of the glyph itself, which I hope makes this more cross-compatible
                    codepoints = [ord(x) for x in glyph]
                    codepoints = str(codepoints).replace(" ","")
                    cmd = f"\"{PATH_TO_OPENSCAD}\" -o \"{filename}\" -D codepoints={codepoints} -D row={row} -D column={column} -D case={case} oneletter.scad"
                    print(f"Generating glyph {glyph}...")
                    future = executor.submit(subprocess.run, cmd, shell=True)
                    glyphs.append({
                        "filename": filename,
                        "task": future,
                        "glyph": glyph
                    })


    for glyph in glyphs:
        while not glyph["task"].done():
            print("waiting...")

        mainMeshSet.load_new_mesh(glyph["filename"])
        mainMeshSet.generate_by_merging_visible_meshes()
        mainMeshSet.save_current_mesh("ballparts/textForTypeball.STL")
        symbol = glyph["glyph"]
        print(f"Glyph {symbol} complete.")
    
    # Once all glyphs are processed, put them onto the typeball body
    print("Attaching glyphs to typeball body...")
    mainMeshSet = ml.MeshSet() # Just reset the meshset, it's easier this way
    mainMeshSet.load_new_mesh("ballparts/textForTypeball.STL")
    mainMeshSet.load_new_mesh("typeball_blank.STL")
    mainMeshSet.generate_boolean_union(first_mesh=0, second_mesh=1)
    mainMeshSet.save_current_mesh("typeball_finished.STL")
    print("Typeball finished!")
