GAMEBOY / GBDK C EXPORTER FOR ASEPRITE

DISCLAIMER

This code can probably be optimized, but i'm a novice programmer at best, so feel free to mess with it
Everything is comented as best as I could manage.

INSTALLATION

Copy the gb-export.lua file (and rename if you want) to your Aseprite scripts directory.

TILESET CONSTRAINTS / THINGS TO KEEP IN MIND

This script makes use of the tileset/tilemap system, so you need a Tileset layer (It also, only works with one tileset layer on the file and don't support animations)
The script will run on the currently active file
Tiles must be 8x8 px, or GBDK won't read it properly
The Canvas must also be a multiple of 8 
Color mode must be indexed and only have 4 colors. (And will take the left most color as brightest, and last color as darkest)

You may have to add a random filename when picking a folder, it's the only way i managed to make it work. HOWEVER it will only take the folder of the file, and will export as a .C file with the name you set.

also, you may have to set the initial index of the tileset to 0 (I haven't tested this one yet)



