local M = {}

local json = require( "json" )

-- define vars
local scoresTable = {}
local gamedataTable = {}

-- set path to files (which will be created if they don't exist) in the persistent documents dir
local scoresFilePath = system.pathForFile( "scores.json", system.DocumentsDirectory )
local gamedataFilePath = system.pathForFile( "gamedata.json", system.DocumentsDirectory )

-- define the table containing the default game data
local gamedataTableDefault = {
    submarineSkin = 1,
    bubbleSkin = 1
}
-- set the table as initialized
gamedataTableDefault[1] = "initialized"


-- ----------------------------------------------------------------------------
-- functions
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
 
	-- remove all contents exceeding 10 elements
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
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
-- module utility functions
-- ----------------------------------------------------------------------------

function M.addNewScore( newScore )

    -- read scores from file
    loadScores()
    
    -- insert the new score into the table
    table.insert( scoresTable, newScore )

    -- sort the table entries from highest to lowest
    -- define function to determine if 2 elements need to be swapped
    local function compare( a, b )
        return a > b
    end
    -- sort table
    table.sort( scoresTable, compare )

    -- write scores to file
    saveScores()
end

function M.getScores()

    -- read scores from file
    loadScores()
    
    -- return the table reference
    return scoresTable
end

function M.setGamedata( table )

    -- set "gamedataTable" reference to the specified "table"
    -- NOTE: "table" should be the table returned by M.getGamedata() which will be the same object referenced by "gamedataTable",
    --          the purposes of requiring the table to be passed are:
    --                  1) avoids the misuse of this function, like calling it without first having loaded the gamedata
    --                  2) permits you to set a new table as gamedataTable ( in this case you have to initialize it as done in gamedataTableDefault[1] )
    gamedataTable = table

    -- write gamedata to file
    saveGamedata()
end

function M.getGamedata()

    -- read gamedata from file
    loadGamedata()
    
    -- return the table reference
    return gamedataTable
end


-- return module table
return M
