local M = {}

local composer = require( "composer" )

-- initialize variables -------------------------------------------------------

-- assets directory
local uiDir = "assets/ui/" -- user interface assets dir

-- init vars
local group

local xPropagationOffset -- the offet between each item in the x axe
local yPropagationOffset -- the offet between each item in the y axe

local scaleFactor
local descriptor
local position
local propagation

local loadedButtons

-- get the x, y coords for the given propagation
local function computePropagation(count)
    local xPropagation = 0
    local yPropagation = 0

    if propagation == 'left' then
        xPropagation = xPropagationOffset * (count - 1) * -1
    
    elseif propagation == 'down' then
        yPropagation = yPropagationOffset * (count - 1)
    end
    
    return xPropagation, yPropagation
end

-- get the x, y coords for the given position
-- compute always with the entry point set on the center
local function computePosition()
    local xPosition = 0
    local yPosition = 0

    --[[
    the 'center' position is not neaded
    because the entry point is already the center

    if position == 'center' 
        xPosition = 0
        yPosition = 0
    ]]--

    if position == 'top-right' then
        xPosition = display.contentWidth/2.3
        yPosition = display.contentHeight/2.5 * -1 -- negative value
    end

    return xPosition, yPosition
end


-- private function to display the badges
local function load()

    -- if the descriptor is void Abort
    if not descriptor then 
        return
    end
    
    local xPosition, yPosition = computePosition()

    for count = 1, #descriptor do
		local d = descriptor[count]
		local dir = d[1]
        local callback = d[2]
        
        local xPropagation, yPropagation = computePropagation(count)

		local obj = display.newImage(group, uiDir .. dir) -- set mask
        obj:scale( scaleFactor, scaleFactor )
		obj.x = display.contentCenterX + xPosition + xPropagation
        obj.y = display.contentCenterY + yPosition + yPropagation
        print(obj.x, obj.y)
        obj:addEventListener( "tap", callback ) -- tap listener

        table.insert(loadedButtons, obj)
    end
end

-- remove badges from the view
-- if you want to hide the badge temporarely, this command will destroy them
-- to reload the badges use M.reload
function M.remove()
    for i=0, table.getn( descriptor ) do 
        display.remove( descriptor[i] )
    end
    descriptor = {}
end


-- reload badges if there are changes to apply
-- example a new badge
function M.reload()
    M.remove()
    load()
end


-- init function
function M.init( displayGroup, options )
    --[[
        an example of badgesDescriptor
        {
            {"badgeEdit.png", windowMod.openWorldsMenu},
            {"badgeSubmarine.png", windowMod.openSubmarinesMenu},
            {"badgeBubbles.png", windowMod.openBubblesMenu},
            {"badgeMute.png", muteMusicCallback}
        }

        you can edit the anytime changing the global var badgesDescriptor
        and use reload() to apply changes
    ]]--
    
    group = displayGroup
    
    xPropagationOffset = 180
    yPropagationOffset = 150
    scaleFactor = 0.3
    descriptor = {}
    position = 'top-right'
    propagation = 'left'

    -- xPropagationOffset the offet between each item in the x axe
    if options.xPropagationOffset then 
        xPropagationOffset = options.xPropagationOffset 
    end

    -- yPropagationOffset the offet between each item in the y axe
    if options.yPropagationOffset then 
        yPropagationOffset = options.yPropagationOffset 
    end

    -- scaleFactor
    if options.scaleFactor then 
        scaleFactor = options.scaleFactor 
    end

    -- descriptor
    if options.descriptor then 
        descriptor = options.descriptor 
    end

    -- position
    if options.position then 
        position = options.position 
    end

    -- propagation
    if options.propagation then 
        propagation = options.propagation 
    end

    loadedButtons = {}
    load()
end


return M
