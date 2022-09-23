-- ASEPRITE tileset and tilemap C exporter for use with GBDK  --  version 0.2


--DISCLAIMER--
-- I'm an amateur programer, so the code may not be as optimal as it could be
-- also, some notes may seem over explained, but they are for me to understand and remember what everything does.

-- Big Thanks to Aseprite community, specifically:
-- Jeremy Behreandt, whose tutorial helped get started on the script
-- 
-- boombuler, for his version of the plugin, 
-- that helped a lot during debugging, and figuring out how to output the tiles

-- ONLY WORKS WITH A SINGLE TILEMAP LAYER

--REMAINING THINGS TO DO:
--  RECEIVE USER INPUT FOR:
--   |-> INITAL TILE INDEX (0,1,etc) - (KEEP IN MIND FOR THE GBDK IS HAS TO START AT 0)
--   |-> BOOL FOR ONLY TILES, OR TILES AND MAP -- SETUP BUT NOT IMPLEMENTED
--   |-> FILEPATH TO SAVE -- SETUP BUT NOT IMPLEMENTED
--  SAVE TO FILE
--  FORMAT THE FILE TO A .C FILE (MAYBE) (const unsigned char tileset = *ARRAY GOES HERE*) 
--  CREATE AN ARRAY FOR THE MAP, NOT ONLY THE TILES
--   |-> FIGURE OUT HOW TO SAVE THE TILE INDEX TO AN ARRAY AND EXPORT THAT

local sprt = app.activeSprite
local tile_layers ={}
local n_layer = 0

local filepath = sprt.filename
print(filepath)

local extension = (string.find(filepath,".aseprite")) - 1
filepath = string.sub(filepath,1,extension)

print(filepath)

local file_extension = ""
local 

-- INITIAL CHECKS FOR VALID FILE -- 

if sprt == nil then --CHECKS IF THERE'S AN IMAGE LOADED
    app.alert{
        title = "MAJOR ERROR",
        text = "THERE'S NO FILE OPEN",
        buttons = "Oh crap"
    }
    return
end

for i,current_layer in ipairs(sprt.layers) do
    if current_layer.isTilemap then
        tile_layers[n_layer] = current_layer
        n_layer = n_layer+1
    end
end

if n_layer == 0 then
    app.alert{
        title = "ERROR",
        text = "There is no Tilemap Layer"
    }
    return
end

if ColorMode.TILEMAP == nil then --CHECKS FOR TILEMAP
    app.alert{
        title = "ERROR",
        text = "This file does not make use of tilemaps"
    }
    return
end

local plt = sprt.palettes[1] -- DEFINES THE PALETTE

if sprt.height % 8 ~= 0 or sprt.width%8 ~= 0 then --CHECKS FOR IMAGE DIMENSIONS, GAMEBOY USES 8X8 TILES, FOR THE IMAGE MUST BE A MULTIPLE
    app.alert {
        title = "ERROR",
        text = "Canvas width or height is not multiple of 8.",
        buttons = "OK"
    }
    return
end

if sprt.colorMode ~= ColorMode.INDEXED then --CHECKS IF THE COLOR MODE IS SET TO INDEXED
    app.alert{
        title = "ERROR",
        text = {" Color Mode must be", "INDEXED", "and have only 4 colors"},
        buttons = "Oh, my bad"
    }
    return
elseif #plt ~= 4 then  -- IF IT IS INDEXED, CHECKS IF IT DOES HAVE 4 COLORS 
    app.alert{
        title = "ERROR",
        text = "Number of colors MUST BE 4",
        buttont  = "Oops"
    }
    return
end


--INITIAL CHECKS DONE--

--USER INPUT--

local dlg = Dialog {title = "GB TILE EXPORTER"}

dlg:label{
    id = "label-01",
    text = "Pick a location and a name to save the file."
}
dlg:newrow()

dlg:label{
    id = "label-02",
    text = "No aseprite file will be overwritten"
}
dlg:file{
    id = "filepath",
    label = "Save Location",
    save = true,
    filetypes = {""}
} 

dlg:entry{
    id="tilename",
    label = "Tileset Name",
    text = "tileset"
}

dlg:entry{
    id = "mapname",
    label = "Map Name",
    text = "tilemap"
}

dlg:combobox{
    id = "fileformat",
    label = "File Format",
    option = "C",
    options = {"C"} -- FOR FUTURE SUPPORT OF DIFFERENTE TYPES, LIKE ASM MAYBE
}
dlg:newrow()

dlg:check{
    id = "checkTileset",
    text = "Export Tileset",
    selected = true,
    -- bounds = Rectangle()
}
dlg:check{
    id = "checkTilemap",
    text = "Export Tilemap",
    selected = true
}
-- NEEDS FILE PATH TO EXPORT
-- NAME FOR TILESET
-- NAME FOR TILEMAP
-- CHECK BOX FOR TILESET(EXPORT TILESET)
-- CHECK BOX FOR TILEMAP(EXPORT TILEMAP)

dlg:button{
    id="confirm",
    text="OK"
}
dlg:button{
    id="cancel",
    text="Cancel"
}


dlg:show{wait=true}

--FUNCTIONS ARE DECLARED HERE--

local dlg_data = dlg.data

local function tile_to_hex(tile) -- THE FUNCTION (GET PIXEL) FOR THE TILE RETURNS THE INDEX OF THE COLOR USED, WHICH IS WHY IT'S MULTIPLIED BY 75
    
    -- ****HOW TO GAMEBOY WORKS WITH 2BITS PER PIXEL (2BPP)****--
    
    -- EACH PIXEL IS A SET OF TWO DIGITS (BITS) SO WE TAKE A ROW AS A FULL BYTE
    -- SEPARATES THE NUMBER(BINARY) INTO PAIRS OF DIGITS
    -- THE PAIRS ARE THEM SEPARATED INTO  "HIGH BITE" (LEFT) AND "LOW BITE" (RIGHT)
    -- THEM YOU JOIN THE HIGHS AND THE LOWS, AND END UP WITH TWO BYTES (8 DIGITS EACH)
    -- THEN YOU PUT THE LOW BYTES FIRST AND THE HIGHS SECOND
        -- THAT GIVES YOU 2 ROWS OF PIXELS OF THE TILE

    local hex = ""
    local range_x = tile.width-1
    local range_y = tile.height-1
     for y = 0, range_y do --LOOPS Y AXIS
        local lo_bit = 0;  --resets the low bit per each y value (for each row)
        local hi_bit = 0;  -- resets the high bit per each y value (for each row)
            for x = 0, range_x do -- LOOPS X AXIS
                local pixel = tile:getPixel(x,y)
                if (pixel & 1) ~= 0 then  -- 1 IN BINARY = 01 
                    lo_bit = lo_bit | (1 << range_x-x) -- THE OPERATOR (1<< n-0) would be invalid, so we add (lo_bit |) 
                end
                -- if (px & 1) ~= 0 then
                    -- lo = lo | (1 << 7-cx)
                -- end
                if (pixel & 2) ~= 0 then -- 2 IN BINARY == 10
                    hi_bit = hi_bit | (1 << range_x-x)
                end
                -- WAS USING AND INSTEAD OF & AND APARENTLY THAT WAS MESSING UP THE CODE, THANKS AGAIN TO boombuler FOR HIS CODE (LIFE SAVING)
            end
                -- print(hi_bit, lo_bit)
                hex = hex..(string.format("0x".."%02x, ".."0x".."%02x, ",lo_bit,hi_bit))
                
            end
            hex = hex.."\n"
        
    -- TODO : FIGURE TILES OUT
    -- I WAS COMPLETELY WRONG ABOUT HOW THE TILE CONVERSION WORKS

    -- SOMETHING TO THINK ABOUT IS ORGANIZING THE PALETTE BEFORE HAND FROM BRIGHTEST TO DARKEST, OTHERWISE THIS COULD GIVE UNDESIRED RESULTS
    -- local hex_string = ""
    --         local index = i+j*tile.width
    --         hex_string = hex_string .."0x" .. string.format("%02x",tile:getPixel(i,j)*0x55) ..", "
    --     hex_string = hex_string .. "\n"
        

    print(hex)
    
    return hex -- RETURNS A FORMATED STRING WITH HEX VALUES OF THE TILES;
    
end

local function export_tileset(tileset) --HANDLES SINGLE TILESET PASSED FROM EXPORT_TILESETS FUNCTION
    local t = {}
    local grid = tileset.grid
    local size = grid.tileSize

        for i = 0, #tileset-1 do
            local tile = tileset:getTile(i)
            local hex = tile_to_hex(tile)
            -- t[i] = tile_to_hex(tile)
            -- print(hex)
            table.insert(t,hex)
            
        end

    return t

end


local function export_tilesets(tilesets) --RECEIVES ALL THE TILESETS AND LOOPS, PASSING SINGLE A TILESET TO EXPORT_TILEST EACH TIME
    local t = {}
    for _,tileset in ipairs(tilesets) do
        table.insert(t,export_tileset(tileset))
        print(tileset)
    end
    return t
    --RETURNS A LIST OF LISTS
    --HIERARCHY GOES AS FOLLOWS
    --TABLE:TILESETS (COUNTAINS)-> TABLE:TILESET (COUNTAIS)-> TABLE:TILES (COUNTAIS)-> STRING OF VALUES 
end
--TODO : FIGURE OUT A WAY TO MAKE THIS HIERARCHY SIMPLER 


local function save_to_file(_tosave)
    --TODO: FIX IMPLEMENTATION OF THE SAVE TO FILE FUNTIOM TO INCLUDE DESIRED FOLDER
    File = io.open(filepath.."tileset.c","w")
    File:write(_tosave)
    File:close()
    Header = io.open(filepath.."tileset.h","w")
    Header:write("extern const unsigned char tileset[];")
    Header:close()
end


local function parse_input()
    dlg_data
end


--CODE EXECUTION--

if dlg_data.confirm then
    parse_input()
end
if dlg_data.cancel then
    return
end

local tab = export_tilesets(sprt.tilesets) -- CALLS THE 'MAIN' FUNCTION ON THE CODE
-- local pixel_list = {}                      -- IS A TABLE OF ALL THE PIXEL VALUES FOR EVERY PIXEL
local strg = "const unsigned char tileset[] = {\n"                            -- IS THE STRING TO BE USED WHEN EXPORTING THE TILEMAP

for i, tileset in ipairs(tab) do                    -- TILESET IN TILESETS
    for j, tiles in ipairs(tileset) do              -- TILES IN TILESET
                strg = strg .. tiles
                -- table.insert(pixel_list,tiles)

        end
    end
strg = strg .."};"
print(strg)

-- save_to_file(strg)