local M = {}

local composer = require( "composer" )

local physics = require( "physics" )

-- define vars
M.pickableObjectsTable = nil
local spawnGroundObjectsTimer
local spawnFloatingObjectsTimer
local group

-- assets dir
local pickDir = "assets/items/pickables/"


-- ----------------------------------------------------------------------------
-- functions
-- ----------------------------------------------------------------------------

local function spawnGroundObjects()

    local gameSpeed = composer.getVariable( "gameSpeed" )

    -- generate a random number of pickable items
    local randNum = math.random( 2, math.floor(gameSpeed)+2 ) 
    for i=1, randNum do

        -- select random asset
        local randAsset = math.random( 2 )
        local paint = {
            type = "image",
            filename = pickDir .. "barrel" .. randAsset .. ".png"
        }
        
        -- create object
        local newPickable = display.newRect( group, display.contentWidth + i*math.random(400, 1000), display.contentHeight, 512*0.15, 752*0.15 )
        newPickable.fill = paint
        newPickable.anchorY = 1
        newPickable.myName = "groundObject"
        physics.addBody( newPickable, { radius=70, isSensor=true } )

        -- rand rotation
        local randRot = math.random( 2 )
        if (randRot == 2) then
            newPickable.rotation = 90
            newPickable.y = newPickable.y - 40
        end

        -- add to table
        table.insert( M.pickableObjectsTable, newPickable )

        -- set speed
        newPickable:setLinearVelocity( -450*gameSpeed, 0 )
    end
end

local function spawnFloatingObjects()

    local gameSpeed = composer.getVariable( "gameSpeed" )
end


-- ----------------------------------------------------------------------------
-- module utility functions
-- ----------------------------------------------------------------------------

-- init function
function M.init( displayGroup )
    
    -- init vars
    M.pickableObjectsTable = {}
    group = displayGroup

    -- set spawn timers
    spawnGroundObjectsTimer = timer.performWithDelay( 5000, spawnGroundObjects, 0 )
    spawnFloatingObjectsTimer = timer.performWithDelay( 5000, spawnFloatingObjects, 0 )

end

-- clear function
function M.clear()

    -- remove Runtime listeners (do before removing references to the objects to be removed)

    -- remove object references
    M.pickableObjectsTable = {}

    -- remove timers
    timer.cancel( spawnGroundObjectsTimer )
    timer.cancel( spawnFloatingObjectsTimer )
end


-- return module table
return M
