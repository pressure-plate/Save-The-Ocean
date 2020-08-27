local M = {}

local composer = require( "composer" )


-- initialize variables -------------------------------------------------------

-- init vars
local group

-- assets directory
local audioDir = "audio/" -- audio dir


-- default table configuration
local highlightItemDir
local tableOriginX
local tableOriginY
local tableReplicaDistanceFactorX
local tableReplicaDistanceFactorY
local colCount
local rowCount
local items 
local onTapCallback

local buttonHighlightSound

local inTableItems
local highlightSelected
local currentHighlightItemId = 0
local itemsPrices


-- ----------------------------------------------------------------------------
-- Functions
-- ----------------------------------------------------------------------------

-- function to visually check the selected item
-- this function is called by the event that handle the clicked object
function M.highlightItem( itemId, playSound )
    
    -- item id must be in range
    if (itemId < 1) or (itemId > #inTableItems) then return false end

    -- if the item is already selected return
    if currentHighlightItemId == itemId then return false end

    local item = inTableItems[itemId]

    -- if the item is locked abort
    -- the user have to unlock the item to use it
    if item.isLocked then return false end

    -- avoid to play the sound, if neaded
    if playSound then
        audio.play( buttonHighlightSound )
    end

    

    display.remove( highlightSelected )

    highlightSelected = display.newImage(group, highlightItemDir) -- set title
    highlightSelected:scale( 0.4, 0.4 )
    highlightSelected.x = item.x
    highlightSelected.y = item.y

    currentHighlightItemId = itemId

    return true
end


-- if the item is to unlock
-- set price and alpha on the item
local function setItemPrice( itemId, price )

    -- item id must be in range
    if (itemId < 1) or (itemId > #inTableItems) then return false end

    local item = inTableItems[itemId]
    item.alpha = 0.5

    local fontParams = composer.getVariable( "defaultFontParams" )

    local priceLabel = display.newText( 
        group, 
        price .. ' $', 
        item.x, 
        item.y, 
        fontParams.path, 
        100 
    )
    priceLabel:setFillColor( fontParams.colorR, fontParams.colorG, fontParams.colorB )

    table.insert(itemsPrices, priceLabel)
end


-- public function to destroy the loaded content
-- call to remove all the objects in the table from the screen
function M.destroyTable()
    for i=0, #inTableItems do 
        display.remove( inTableItems[i] )
    end
    inTableItems = {}

    display.remove( highlightSelected )

    for i=0, #itemsPrices do 
        display.remove( itemsPrices[i] )
    end
end


-- function that create a table as a grid
-- and it will populare the cells with the given objectGenerationFunction(i, row, col)
local function createTable()
    
    local i = 1
    local itemsCount = #items
    local isBreak = false

    -- loop row
    for row = 1, rowCount do
        -- loop col
        for col = 0, colCount - 1 do
            -- generate object
            local dir = items[i][1]
            local scaleFactor = items[i][2]
            local price = items[i][3]

            local isLocked = false
            if price ~= 0 then isLocked = true end

            local item = display.newImage(group, dir)
            item:scale( scaleFactor, scaleFactor )
            item.x = tableOriginX + item.width*scaleFactor * col * tableReplicaDistanceFactorX
            item.y = tableOriginY + item.height*scaleFactor * row * tableReplicaDistanceFactorY
            item.isLocked = isLocked
            item.itemId = i
            if onTapCallback then 
                item:addEventListener( "tap", onTapCallback ) -- tap listener
            end
            table.insert(inTableItems, item) -- save the submarine to remove it later
            
            -- set the price value on the locked stuff
            if isLocked then
                setItemPrice(i, price)
            end

            i = i+1
            if i > itemsCount then return end
        end
    end
end


-- ----------------------------------------------------------------------------
-- Init
-- ----------------------------------------------------------------------------

-- init function
function M.init( displayGroup, options )
    -- init vars
    group = displayGroup

    highlightItemDir = "assets/ui/badgeHighlight.png"
    tableOriginX = 512
    tableOriginY = 512
    tableReplicaDistanceFactorX = 1.2
    tableReplicaDistanceFactorY = 1.2
    colCount = 3
    rowCount = 2
    items = {}
    onTapCallback = null
    buttonHighlightSound = audio.loadStream( audioDir .. "sfx/select.mp3" )

    -- highlightItemDir
    if options.highlightItemDir then 
        highlightItemDir = options.highlightItemDir 
    end

    -- tableOriginX
    if options.tableOriginX then 
        tableOriginX = options.tableOriginX 
    end

    -- tableOriginY
    if options.tableOriginY then 
        tableOriginY = options.tableOriginY 
    end

    -- tableReplicaDistanceFactorX
    if options.tableReplicaDistanceFactorX then 
        tableReplicaDistanceFactorX = options.tableReplicaDistanceFactorX 
    end

    -- tableReplicaDistanceFactorX
    if options.tableReplicaDistanceFactorX then 
        tableReplicaDistanceFactorX = options.tableReplicaDistanceFactorX 
    end

    -- colCount
    if options.colCount then
        colCount = options.colCount
    end

    -- rowCount
    if options.rowCount then
        rowCount = options.rowCount
    end

    -- items
    if options.items then
        items = options.items
    end

    -- onTapCallback
    if options.onTapCallback then
        onTapCallback = options.onTapCallback
    end

    -- buttonHighlightSound
    if options.buttonHighlightSound then 
        buttonHighlightSound = options.buttonHighlightSound 
    end

    inTableItems = {}
    itemsPrices = {}
    createTable()
end


-- to manually clear mem and visual loaded from this module, without destroy the scene
function M.destroy()
    M.destroyTable()
    audio.dispose( buttonHighlightSound )
end


return M
