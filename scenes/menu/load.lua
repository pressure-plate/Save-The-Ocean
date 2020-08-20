local M = {}

local composer = require( "composer" )

-- load submarine module
local subMod = require( "scenes.game.submarine" )

-- initialize variables -------------------------------------------------------

-- init vars
local group

-- assets directory
local submarineDir = "assets/submarine/" -- submarine assets


-- default table configuration
local colCount = 3
local rowCount = 2
local inTableItems = {}
local highlightSelected


local function highlightItem( x, y )
    display.remove( highlightSelected )

    highlightSelected = display.newImage(group, submarineDir .. "hightlight.png") -- set title
    highlightSelected:scale( 0.4, 0.4 )
    highlightSelected.x = x
    highlightSelected.y = y
end

-- called on screen tap on the item
local function onSubmarineSelection( event )
    subMod.submarineSkin = event.target.itemId
    highlightItem(event.target.x, event.target.y)
end

-- called on screen tap on the item
local function onBoubleSelection( event )
    subMod.bubbleSkin = event.target.itemId
    highlightItem(event.target.x, event.target.y)
end


function M.destroyTable()
    for i=0, table.getn(inTableItems) do 
        display.remove( inTableItems[i] )
    end
    inTableItems = {}
    display.remove( highlightSelected )
end

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


function M.loadSubmarines()

    local submarinesCount = 6
    local submarineScaleFactor = 0.8
    local originX = display.contentCenterX - display.contentWidth/4
    local originY = display.contentCenterY - display.contentHeight/4
    
    local function objectGenerationFunction(i, row, col)
        local submarine = display.newImage(group, submarineDir .. i .. ".png") -- set title
        submarine:scale( submarineScaleFactor, submarineScaleFactor )
        submarine.x = originX + submarine.width*submarineScaleFactor * col * 1.2
        submarine.y = originY + submarine.height*submarineScaleFactor * row * 1.2
        submarine.itemId = i
        submarine:addEventListener( "tap", onSubmarineSelection ) -- tap listener
        
        -- if the submarine is the current loaded then highlight it
        if subMod.submarineSkin == i then
            highlightItem(submarine.x, submarine.y)
        end
        return submarine
    end
    -- create te table based on the global configuration
    createTable(objectGenerationFunction, submarinesCount)
end


function M.loadBubbles()

    local bubblesCount = 3
    local bubblesScaleFactor = 2
    local originX = display.contentCenterX - display.contentWidth/4
    local originY = display.contentCenterY - display.contentHeight/4.9
    
    local function objectGenerationFunction(i, row, col)
        local boubble = display.newImage(group, submarineDir .. "bubble/" .. i .. ".png") -- set title
        boubble:scale( bubblesScaleFactor, bubblesScaleFactor )
        boubble.x = originX + boubble.width*bubblesScaleFactor * col * 2.8
        boubble.y = originY + boubble.height*bubblesScaleFactor * row * 1.2
        boubble.itemId = i
        boubble:addEventListener( "tap", onBoubleSelection ) -- tap listener
        
        -- if the bubble is the current loaded then highlight it
        if subMod.bubbleSkin == i then
            highlightItem(boubble.x, boubble.y)
        end
        return boubble
    end
    -- create te table based on the global configuration
    createTable(objectGenerationFunction, bubblesCount)
end


-- init function
function M.init( displayGroup )
    -- init vars
    group = displayGroup
end

return M
