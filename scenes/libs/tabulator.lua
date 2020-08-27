local M = {}

local composer = require( "composer" )


-- initialize variables -------------------------------------------------------

-- init vars
local group


-- default table configuration
-- settings loaded on the startup
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

-- in lib vars
local inTableItems
local highlightSelected
local currentHighlightItemId = 0
local itemsLables


-- ----------------------------------------------------------------------------
-- Functions
-- ----------------------------------------------------------------------------

-- function to visually check the selected item
-- this function is called by the event that handle the clicked object
function M.highlightItem( itemId, playSound )
    
    -- item id must be in range
    if (itemId < 1) or (itemId > #inTableItems) then return false end

    -- load the item from inTableItems by itemId
    local item = inTableItems[itemId]

    -- if the item is locked abort
    -- the user have to unlock the item to use it
    if item.alpha ~= 1 then return false end

    -- avoid to play the sound, if neaded
    -- if the item is already selected do not play sound but reload it anyway (necessary)
    if playSound and (currentHighlightItemId ~= itemId) then
        audio.play( buttonHighlightSound )
    end

    display.remove( highlightSelected )

    -- show the highligh mark
    highlightSelected = display.newImage(group, highlightItemDir) -- set title
    highlightSelected:scale( 0.4, 0.4 )
    highlightSelected.x = item.x
    highlightSelected.y = item.y

    -- update the currentHighlightItemId to not play the sound againg
    -- if the user tap again on a selected item
    currentHighlightItemId = itemId

    return true
end


-- if the item is locked (show price), or for the Scores
-- set Text Over on the item
local function setItemTextOver( itemId, textLaber )

    -- item id must be in range
    if (itemId < 1) or (itemId > #inTableItems) then return false end

    -- load the item from inTableItems by itemId
    local item = inTableItems[itemId]

    local fontParams = composer.getVariable( "defaultFontParams" )

    local label = display.newText( 
        group, 
        textLaber, 
        item.x, 
        item.y, 
        fontParams.path, 
        80 
    )
    label:setFillColor( fontParams.colorR, fontParams.colorG, fontParams.colorB )

    table.insert(itemsLables, label)
end


-- public function to destroy the loaded content
-- call to remove all the objects in the table from the screen
function M.destroyTable()
    for i=0, #inTableItems do 
        display.remove( inTableItems[i] )
    end
    inTableItems = {}

    display.remove( highlightSelected )

    for i=0, #itemsLables do 
        display.remove( itemsLables[i] )
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
            local dir = items[i].dir
            local scaleFactor = items[i].scaleFactor
            local alpha = items[i].alpha
            local label = items[i].label
            
            -- display the object in the right location on the screen
            -- based on table coords
            local item = display.newImage(group, dir)
            item:scale( scaleFactor, scaleFactor )
            item.x = tableOriginX + item.width*scaleFactor * col * tableReplicaDistanceFactorX
            item.y = tableOriginY + item.height*scaleFactor * row * tableReplicaDistanceFactorY
            
            -- set the aplpha to the item, the alpha in used also to deactivate the object
            if alpha then
                item.alpha = alpha
            end
            
            -- set the item id basend by the loading order
            -- this will match the positions in the inTableItems
            -- used in the onTapCallback to know wich item has been tapped
            item.itemId = i 
            
            -- load the callback if exist, execute when the user tap on this item
            if onTapCallback then 
                item:addEventListener( "tap", onTapCallback ) -- tap listener
            end
            
            -- store the loaded items to work on them later
            table.insert(inTableItems, item)
            
            -- set the label value over the item
            if label then
                setItemTextOver(i, label)
            end

            i = i+1
            if i > itemsCount then return end -- exit if there are no items left
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

    --[[
    Example of options:

    {
        items = {
            { dir=bubbleDir .. "1.png", scaleFactor=2 },
            { dir=bubbleDir .. "2.png", scaleFactor=2, label='14', alpha=0.5 },
            { dir=bubbleDir .. "3.png", scaleFactor=2, label='22', alpha=0.5 }
        },
        colCount = 3,
        rowCount = 2,
        tableOriginX = display.contentCenterX - display.contentWidth/4,
        tableOriginY = display.contentCenterY - display.contentHeight/4.9,
        tableReplicaDistanceFactorX = 2.8,
        onTapCallback = onBubbleSelection,
    }

    Available options:
    - highlightItemDir -- the dir asset to highligh the obj
    - tableOriginX -- X point where start the spawn
    - tableOriginY -- Y point where start the spawn
    - tableReplicaDistanceFactorX -- sale factor to separate each object on the X (col)
    - tableReplicaDistanceFactorY -- sale factor to separate each object on the Y (row)
    - colCount -- the number of col in the table
    - rowCount -- the number of row in the table
    - items -- the item list
    - onTapCallback -- function to call when a item is tapped
    - buttonHighlightSound -- the sound dir to play when a item is selected

    ]]--

    highlightItemDir = "assets/ui/badgeHighlight.png"
    tableOriginX = 512
    tableOriginY = 512
    tableReplicaDistanceFactorX = 1.2
    tableReplicaDistanceFactorY = 1.2
    colCount = 3
    rowCount = 2
    items = {}
    onTapCallback = null
    buttonHighlightSound = audio.loadStream( composer.getVariable( "audioDir" ) .. "sfx/select.mp3" )

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
    itemsLables = {}
    createTable()
end


-- to manually clear mem and visual loaded from this module, without destroy the scene
function M.destroy()
    M.destroyTable()
    audio.dispose( buttonHighlightSound )
end


return M
