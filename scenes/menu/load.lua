local M = {}

local composer = require( "composer" )

local savedata = require( "scenes.libs.savedata" ) -- load the save data module

local bgMenuMod = require( "scenes.menu.background" ) -- required to reload the home background


-- initialize variables -------------------------------------------------------

-- init vars
local group

-- assets directory
local submarineDir = "assets/submarine/" -- submarine assets
local backgroundDir = "assets/background/" -- background assets


-- default table configuration
local colCount = 3
local rowCount = 2
local inTableItems = {}
local highlightSelected


-- ----------------------------------------------------------------------------
-- Functions
-- ----------------------------------------------------------------------------

-- function to visually check the selected item
-- this function is called by the event that handle the clicked object
local function highlightItem( x, y )
    display.remove( highlightSelected )

    highlightSelected = display.newImage(group, submarineDir .. "hightlight.png") -- set title
    highlightSelected:scale( 0.4, 0.4 )
    highlightSelected.x = x
    highlightSelected.y = y
end


-- called on screen tap on the item
local function onSubmarineSelection( event )
    savedata.setGamedata( "submarineSkin", event.target.itemId )
    highlightItem(event.target.x, event.target.y)
end


-- called on screen tap on the item
local function onBoubleSelection( event )
    savedata.setGamedata( "submarineBubbleSkin", event.target.itemId )
    highlightItem(event.target.x, event.target.y)
end


-- set the background var once is selected
local function onWorldStikerSelection( event )
    savedata.setGamedata( "backgroundWorld", event.target.itemId )
    bgMenuMod.updateBackground() -- call the reload for the background menu
    highlightItem(event.target.x, event.target.y)
end


--  public function to destroy the loaded content
function M.destroyTable()
    for i=0, table.getn(inTableItems) do 
        display.remove( inTableItems[i] )
    end
    inTableItems = {}
    display.remove( highlightSelected )
end


-- function that create a table as a grid
-- and it will populare the cells with the given objectGenerationFunction(i, row, col)
local function createTable(objectGenerationFunction, itemCount)
    
    local isBreak = false
    -- load items as grid
    local i = 1
    -- loop row
    for row = 1, rowCount do
        -- loop col
        for col = 0, colCount - 1 do
            -- generate object
            local item = objectGenerationFunction(i, row, col)
            table.insert(inTableItems, item) -- save the submarine to remove it later

            i = i+1
            if i > itemCount then isBreak=true break end
        end
        if isBreak == true then break end
    end
end


-- ----------------------------------------------------------------------------
-- Load Items Functions
-- ----------------------------------------------------------------------------

-- load the content in submarines menu
function M.loadSubmarines()

    local itemsCount = 6
    local scaleFactor = 0.8
    local originX = display.contentCenterX - display.contentWidth/4
    local originY = display.contentCenterY - display.contentHeight/4
    
    local function objectGenerationFunction(i, row, col)
        local item = display.newImage(group, submarineDir .. i .. ".png") -- set title
        item:scale( scaleFactor, scaleFactor )
        item.x = originX + item.width*scaleFactor * col * 1.2
        item.y = originY + item.height*scaleFactor * row * 1.2
        item.itemId = i
        item:addEventListener( "tap", onSubmarineSelection ) -- tap listener
        
        -- if the submarine is the current loaded then highlight it
        if savedata.getGamedata( "submarineSkin") == i then -- check the loaded item
            highlightItem(item.x, item.y)
        end
        return item
    end
    -- create te table based on the global configuration
    createTable(objectGenerationFunction, itemsCount)
end


-- load the content in bubbles menu
function M.loadBubbles()

    local itemsCount = 3
    local scaleFactor = 2
    local originX = display.contentCenterX - display.contentWidth/4
    local originY = display.contentCenterY - display.contentHeight/4.9
    
    local function objectGenerationFunction(i, row, col)
        local item = display.newImage(group, submarineDir .. "bubble/" .. i .. ".png")
        item:scale( scaleFactor, scaleFactor )
        item.x = originX + item.width*scaleFactor * col * 2.8
        item.y = originY + item.height*scaleFactor * row * 1.2
        item.itemId = i
        item:addEventListener( "tap", onBoubleSelection ) -- tap listener
        
        -- if the bubble is the current loaded then highlight it
        if savedata.getGamedata( "submarineBubbleSkin") == i then  -- check the loaded item
            highlightItem(item.x, item.y)
        end
        return item
    end
    -- create te table based on the global configuration
    createTable(objectGenerationFunction, itemsCount)
end


-- load the content in world menu
function M.loadWorlds()

    local itemsCount = 4
    local scaleFactor = 0.8
    local originX = display.contentCenterX - display.contentWidth/4
    local originY = display.contentCenterY - display.contentHeight/3.3
    
    local function objectGenerationFunction(i, row, col)
        local item = display.newImage(group, backgroundDir .. i .. ".png")
        item:scale( scaleFactor, scaleFactor )
        item.x = originX + item.width*scaleFactor * col * 1.17
        item.y = originY + item.height*scaleFactor * row * 1.2
        item.itemId = i
        item:addEventListener( "tap", onWorldStikerSelection ) -- tap listener
        
        -- if the works is the current loaded then highlight it
        if savedata.getGamedata( "backgroundWorld" ) == i then -- check the loaded item
            highlightItem(item.x, item.y)
        end
        return item
    end
    -- create te table based on the global configuration
    createTable(objectGenerationFunction, itemsCount)
end


-- ----------------------------------------------------------------------------
-- Init
-- ----------------------------------------------------------------------------

-- init function
function M.init( displayGroup )
    -- init vars
    group = displayGroup
end

return M
