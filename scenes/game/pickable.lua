local M = {}

local composer = require( "composer" )

local physics = require( "physics" )

-- define vars
M.pickableObjectsTable = nil
local spawnGroundObjectsTimer
local spawnFloatingObjectsTimer
local group

local lastSpawnGroundObjects
local lastSpawnFloatingObjects

-- assets dir
local pickDir = "assets/items/pickables/"


-- ----------------------------------------------------------------------------
-- functions
-- ----------------------------------------------------------------------------

local function spawnGroundObjects()

    local gameSpeed = composer.getVariable( "gameSpeed" )

    -- spawn cooldown
    local spawnCooldown = 10/gameSpeed -- cooldown seconds
    if ((os.time() - lastSpawnGroundObjects) < spawnCooldown) then
        return
    end
    lastSpawnGroundObjects = os.time()

    -- generate a random number of pickable items
    local randNum = math.random( 2, math.floor(gameSpeed)+1 ) 
    for i=1, randNum do

        -- select random asset
        local randAsset = math.random( 2 )
        local paint = {
            type = "image",
            filename = pickDir .. "barrel" .. randAsset .. ".png"
        }
        
        -- create object
        local newPickable = display.newRect( group, display.contentWidth + math.random(400, 1200), display.contentHeight, 512*0.15, 752*0.15 )
        newPickable.fill = paint
        newPickable.anchorY = 1
        newPickable.myName = "groundObject"
        physics.addBody( newPickable, "kinematic", { radius=50, isSensor=true } )

        -- rand rotation
        local randRot = math.random( 2 )
        if (randRot == 2) then
            newPickable.rotation = 90
            newPickable.y = newPickable.y - 40
        end

        -- add to table
        table.insert( composer.getVariable( "screenObjectsTable" ), newPickable )

        -- set speed
        newPickable:setLinearVelocity( -450*gameSpeed, 0 )
    end
end

local function spawnFloatingObjects()

    local gameSpeed = composer.getVariable( "gameSpeed" )

    -- spawn cooldown
    local spawnCooldown = 6/gameSpeed -- cooldown seconds
    if ((os.time() - lastSpawnFloatingObjects) < spawnCooldown) then
        return
    end
    lastSpawnFloatingObjects = os.time()

    -- generate a random number of pickable items
    local randNum = math.random( 2, math.floor(gameSpeed)+3 ) 
    for i=1, randNum do

        -- select random asset
        local randAsset = math.random( 2 )
        local paint = {
            type = "image",
            filename = pickDir .. "bubble" .. randAsset .. ".png"
        }
        
        -- create object
        local newPickable = display.newRect( group, display.contentWidth + math.random(400, 1500), math.random(100, display.contentHeight-100), 85, 85 )
        newPickable.fill = paint
        newPickable.anchorY = 1
        newPickable.myName = "floatingObject"
        physics.addBody( newPickable, "kinematic", { radius=50, isSensor=true } )

        -- rand spin
        local randRot = math.random( -10, 10 )
        newPickable:applyTorque( randRot )

        -- add to table
        table.insert( composer.getVariable( "screenObjectsTable" ), newPickable )

        -- set speed
        newPickable:setLinearVelocity( -450*gameSpeed, 0 )
    end
end


-- ----------------------------------------------------------------------------
-- module utility functions
-- ----------------------------------------------------------------------------

-- init function
function M.init( displayGroup )
    
    -- init vars
    M.pickableObjectsTable = {}
    group = displayGroup
    lastSpawnGroundObjects = os.time()
    lastSpawnFloatingObjects = os.time()

    -- set spawn timers
    spawnGroundObjectsTimer = timer.performWithDelay( 3000, spawnGroundObjects, 0 )
    spawnFloatingObjectsTimer = timer.performWithDelay( 2000, spawnFloatingObjects, 0 )

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
