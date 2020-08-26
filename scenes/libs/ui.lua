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

local packTime
local packRotation
local isPacked -- if the sub menu is packed, for the default toggle callback

local loadedButtons

-- get the x, y coords for the given propagation
local function computePropagation(count)
    local xPropagation = 0
    local yPropagation = 0

    -- avoid propagation calculation if the items are packed
    if isPacked then
        return xPropagation, yPropagation
    end

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

    for count = #descriptor, 1, -1 do
		local d = descriptor[count]
		local dir = d[1]
        local callback = d[2]
        
        local xPropagation, yPropagation = computePropagation(count)

		local obj = display.newImage(group, uiDir .. dir) -- set mask
        obj:scale( scaleFactor, scaleFactor )
		obj.x = display.contentCenterX + xPosition + xPropagation
        obj.y = display.contentCenterY + yPosition + yPropagation
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


-- hide all the badges
function M.pack()
    xPosition, yPosition = computePosition()

    for count = #descriptor, 1, -1 do
        transition.to(
            loadedButtons[#descriptor - count + 1], 
            { 
                time = packTime,
                rotation = -packRotation,
                x = display.contentCenterX + xPosition, 
                y = display.contentCenterY + yPosition
            }
        )
    end
end


-- show the hided badges
function M.unpack()
    xPosition, yPosition = computePosition()

    for count = #descriptor, 1, -1 do
        local xPropagation, yPropagation = computePropagation(count)
        transition.to(
            loadedButtons[#descriptor - count + 1], 
            { 
                time = packTime,
                rotation = packRotation,
                x = display.contentCenterX + xPosition + xPropagation, 
                y = display.contentCenterY + yPosition + yPropagation
            }
        )
    end
    return true
end


-- build in callback
-- this will be used as default if not overwritten in init options
local function togglePackCallback()
    if isPacked then
        isPacked = false
        M.unpack()
    else
        isPacked = true
        M.pack()
    end
    return true
end


-- init function
function M.init( displayGroup, options )
    
    group = displayGroup
    
    --[[
    an example of badgesDescriptor:
    {
        {"badgeEdit.png", windowMod.openWorldsMenu},
        {"badgeSubmarine.png", windowMod.openSubmarinesMenu},
        {"badgeBubbles.png", windowMod.openBubblesMenu},
        {"badgeMute.png", muteMusicCallback}
    }

    you can edit the anytime changing the global var badgesDescriptor
    and use reload() to apply changes
    
    the follw declatations can be overwritten in options

    - packIcon -- the png file of the pack button
    - packRotation -- rotate the item of deg x during pack/unpack
    - packCallback -- custom calback for the pack button
    - descriptor -- list of files
    - xPropagationOffset -- distance between 2 object on the x axe
    - yPropagationOffset -- distance between 2 object on the y axe
    - scaleFactor -- the scale of the obj
    - position -- the origin of the first item generated
    - propagation -- the direction of other items generation
    ]]--
    
    -- packIcon = ''
    packTime = 300
    packRotation = 0
    packCallback = togglePackCallback
    isPacked = false
    descriptor = {}
    xPropagationOffset = 180
    yPropagationOffset = 150
    scaleFactor = 0.3
    position = 'top-right' -- center, top-right, top-left, bottom-right, bottom-left
    propagation = 'left' -- left, right, up, down

    -- packTime
    if options.packTime then 
        packTime = options.packTime 
    end

    -- packRotation
    if options.packRotation then 
        packRotation = options.packRotation 
    end

    -- packCallback
    if options.packCallback then 
        packCallback = options.packCallback 
    end

    -- add the packIcon with is callback to the descriptor
    if options.packIcon then 
        table.insert(descriptor, {options.packIcon, packCallback})
        isPacked = true
    end

    -- descriptor
    if options.descriptor then 
        for count, el in pairs ( options.descriptor ) do
            table.insert( descriptor, el )
        end
    end

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
