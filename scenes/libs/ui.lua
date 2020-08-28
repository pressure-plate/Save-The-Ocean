local M = {}

local composer = require( "composer" )

-- initialize variables -------------------------------------------------------

-- assets directory
local uiDir = "assets/ui/" -- user interface assets dir

-- init vars
local group

local packIcon
local packIconOpen
local packCallback

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
    
    elseif propagation == 'right' then
        xPropagation = xPropagationOffset * (count - 1)

    elseif propagation == 'up' then
        yPropagation = yPropagationOffset * (count - 1) * -1
    
    elseif propagation == 'down' then
        yPropagation = yPropagationOffset * (count - 1)
    end

    return xPropagation, yPropagation
end

-- get the x, y coords for the given position
-- compute always with the entry point set on the center
local function computePosition()
    local xPosition = display.contentWidth/2.3
    local yPosition = display.contentHeight/2.5

    if position == "center" then
        return 0, 0

    elseif position == "top-left" then
        return xPosition * -1, yPosition * -1

    elseif position == "top-right" then
        return xPosition, yPosition * -1

    elseif position == "bottom-left" then
        return xPosition * -1, yPosition
    
    else 
        return xPosition, yPosition -- "bottom-right"
    end

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


-- return the origin position of the UI
-- to align other stuff to the buttons 
function M.getPosition()
    local xPosition, yPosition = computePosition()
    return display.contentCenterX + xPosition, display.contentCenterY + yPosition
end

-- remove badges from the view
-- if you want to hide the badge temporarely, this command will destroy them
-- to reload the badges use M.reload
function M.clear()
    for i=1, #loadedButtons do 
        display.remove( loadedButtons[i] )
    end
    loadedButtons = {}
end


-- reload badges if there are changes to apply
-- example a new badge
function M.reload()
    M.clear()
    load()
end


-- hide all the badges
local function pack()

    xPosition, yPosition = computePosition()

    for count = #descriptor, 1, -1 do
        transition.to(
            loadedButtons[#descriptor - count + 1], 
            { 
                time = packTime,
                rotation = -packRotation,
                x = display.contentCenterX + xPosition, 
                y = display.contentCenterY + yPosition,
                onComplete = function ()
                    -- if there is set a icon change on pack/unpack do the switch
                    if packIconOpen then
                        M.clear()
                        descriptor[1] = {packIcon, packCallback}
                        load()
                    end
                end
            }
        )
    end
end


-- show the hided badges
local function unpack()

    xPosition, yPosition = computePosition()

    for count = #descriptor, 1, -1 do
        local xPropagation, yPropagation = computePropagation(count)
        transition.to(
            loadedButtons[#descriptor - count + 1], 
            { 
                time = packTime,
                rotation = packRotation,
                x = display.contentCenterX + xPosition + xPropagation, 
                y = display.contentCenterY + yPosition + yPropagation,
                onComplete = function ()
                    -- if there is set a icon change on pack/unpack do the switch
                    if packIconOpen then
                        M.clear()
                        descriptor[1] = {packIconOpen, packCallback}
                        load()
                    end
                end
            }
        )
    end
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
    - packIconOpen -- the png file to show when the pack is open
    - packRotation -- rotate the item of deg x during pack/unpack
    - packCallback -- custom calback for the pack button
    - descriptor -- list of files
    - xPropagationOffset -- distance between 2 object on the x axe
    - yPropagationOffset -- distance between 2 object on the y axe
    - scaleFactor -- the scale of the obj
    - position -- the origin of the first item generated
    - propagation -- the direction of other items generation
    ]]--
    
    packIcon = null
    packIconOpen = null
    packTime = 300
    packRotation = 0
    isPacked = false
    descriptor = {}
    xPropagationOffset = 180
    yPropagationOffset = 150
    scaleFactor = 0.3
    position = 'top-right' -- center, top-right, top-left, bottom-right, bottom-left
    propagation = 'left' -- left, right, up, down


    -- build packCallback
    -- this will be used only as onpen/close if no aditional callback is provided
    local additionalPackCallback = function () end
    if options.packCallback then
        additionalPackCallback = options.packCallback
    end
    
    -- packCallback function build
    packCallback = function()

        -- create the event to pass to the additionalPackCallback
        -- to let outside know what action will be executed
        local event = {
            isPack = false,
            isUnpack = false
        }

        if isPacked then
            isPacked = false
            unpack()
            event["isUnpack"] = true
            additionalPackCallback ( event )
        else
            isPacked = true
            pack()
            event["isPack"] = true
            additionalPackCallback ( event )
        end
        return true
    end

    -- packTime
    if options.packTime then 
        packTime = options.packTime 
    end

    -- packRotation
    if options.packRotation then 
        packRotation = options.packRotation 
    end
    
    -- add the packIcon with is callback to the descriptor
    if options.packIcon then 

        if type(options.packIcon) == "string" then
            packIcon = options.packIcon

        else -- it is a table { icon1, icon2 }
            packIcon = options.packIcon[1]
            packIconOpen = options.packIcon[2]
        end

        -- insert the icon as first element
        table.insert(descriptor, {packIcon, packCallback })
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
