local M = {}

local json = require( "json" )

-- define vars
local scoresTable = {}
local gamedataTable = {}

-- set path to files (which will be created if they don't exist) in the persistent documents dir
local scoresFilePath = system.pathForFile( "scores.json", system.DocumentsDirectory )
local gamedataFilePath = system.pathForFile( "gamedata.json", system.DocumentsDirectory )

-- DEFAULT game data
local gamedataTableDefault = {
    submarineSkin = 1,
    bubbleSkin = 1,
    backgroundWorld = 1,
    backgroundLayerNum = 6
}
-- set the table as initialized
gamedataTableDefault[1] = "initialized"


-- ----------------------------------------------------------------------------
-- private functions
-- ----------------------------------------------------------------------------

local function loadScores()
 
	-- open file in read mode
    local file = io.open( scoresFilePath, "r" )
 
	-- if file exists read all content, decode it, and store it in scoresTable
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end
 
	-- if the table is nil or has a length of 0 then fill all the missing positions
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end
end

local function saveScores()
 
	-- open file in write mode
    local file = io.open( scoresFilePath, "w" )
 
	-- check if file exists then encode scoresTable and store all its contents on file
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

local function loadGamedata()
 
	-- open file in read mode
    local file = io.open( gamedataFilePath, "r" )
 
	-- if file exists read all content, decode it, and store it in gamedataTable
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        gamedataTable = json.decode( contents )
    end
 
	-- if the table is nil or has a length of 0 then fill it with the default settings
    if ( gamedataTable == nil or #gamedataTable == 0 ) then
        gamedataTable = gamedataTableDefault
    end
end

local function saveGamedata()
 
	-- open file in write mode
    local file = io.open( gamedataFilePath, "w" )
 
	-- check if file exists then encode gamedataTable and store all its contents on file
    if file then
        file:write( json.encode( gamedataTable ) )
        io.close( file )
    end
end


-- ----------------------------------------------------------------------------
-- module initialization 
-- THIS IS EXECUTED ONLY ON THE FIRST require() OF THE MODULE,
--  unless we explicitly unload the module
-- ----------------------------------------------------------------------------

-- cache data to avoid reading it from file every time

-- read scores from file
loadScores()

-- read gamedata from file
loadGamedata()


-- ----------------------------------------------------------------------------
-- public functions
-- ----------------------------------------------------------------------------

function M.addNewScore( newScore )
    
    -- insert the new score into the table
    table.insert( scoresTable, newScore )

    -- sort the table entries from highest to lowest
    -- define function to determine if 2 elements need to be swapped
    local function compare( a, b )
        return a > b
    end
    -- sort table
    table.sort( scoresTable, compare )

    -- remove all contents exceeding 10 elements
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end

    -- write scores to file
    saveScores()
end

function M.getScores()
    
    -- return the table reference
    return scoresTable
end

function M.setGamedata( varName, newValue )

    --[[ 
    NOTE: 
    In Lua doing barTable[ "foo" ] = 1
        is the same as doing barTable.foo = 1
    --]]

    -- set variable 
    gamedataTable[ varName ] = newValue

    -- write gamedata to file
    saveGamedata()
end

function M.getGamedata( varName )
    
    --[[ 
    NOTE: 
    In Lua barTable[ "foo" ]
        is the same as barTable.foo
    --]]

    -- return the table reference
    return gamedataTable[ varName ]
end


-- return module table
return M
