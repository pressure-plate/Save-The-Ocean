local M = {}

local composer = require( "composer" )

local physics = require( "physics" )

-- define vars
M.pickableObjectsTable = nil

local spawnGroundObjectsTimer
local spawnFloatingObjectsTimer
local spawnHandlerTimer

local group

local lastSpawnGroundObjects
local lastSpawnFloatingObjects
local lastSpawnObstacle

-- assets dir
local pickDir = "assets/items/pickables/" -- pickables dir
local obsDir = "assets/items/obstacles/" -- obstacles dir


-- ----------------------------------------------------------------------------
-- functions
-- ----------------------------------------------------------------------------

local function spawnGroundObjects()

    local gameSpeed = composer.getVariable( "gameSpeed" )

    -- spawn cooldown
    local spawnCooldown = 10/gameSpeed -- cooldown seconds
    if ( (os.time() - lastSpawnGroundObjects) < spawnCooldown ) then
        return
    end
    lastSpawnGroundObjects = os.time()

    -- generate a random number of pickable items
    local randNum = math.random( 2, math.floor(gameSpeed)+1 ) 
    for i=1, randNum do

        -- select random asset
        local randAsset = math.random( 5 )
        local paint = {
            type = "image",
            filename = pickDir .. "barrel/" .. randAsset .. ".png"
        }
        
        -- create object
        local scaleFact = 0.18
        local newPickable = display.newRect( group, display.contentWidth + math.random(400, 1200), display.contentHeight, 359*scaleFact, 512*scaleFact )
        newPickable.fill = paint
        newPickable.anchorY = 1
        newPickable.myName = "groundObject"
        physics.addBody( newPickable, "kinematic", { radius=50, isSensor=true } )

        -- rand rotation
        local randRot = math.random( 2 )
        if (randRot == 2) then
            newPickable.rotation = 90
            newPickable.y = newPickable.y - 30
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
    if ( (os.time() - lastSpawnFloatingObjects) < spawnCooldown ) then
        return
    end
    lastSpawnFloatingObjects = os.time()

    -- generate a random number of pickable items
    local randNum = math.random( 2, math.floor(gameSpeed)+3 ) 
    for i=1, randNum do

        -- select random asset
        local randAsset = math.random( 5 )
        local paint = {
            type = "image",
            filename = pickDir .. "bottle/" .. randAsset .. ".png"
        }
        
        -- create object
        local scaleFact = 0.18
        local newPickable = display.newRect( group, display.contentWidth + math.random(400, 1500), math.random(100, display.contentHeight-100), 233*scaleFact, 512*scaleFact )
        newPickable.fill = paint
        newPickable.myName = "floatingObject"
        physics.addBody( newPickable, { radius=50, isSensor=true } )
        newPickable.gravityScale = 0

        -- rand spin
        local randRot = math.random( -8, 8 )
        newPickable:applyTorque( randRot )

        -- add to table
        table.insert( composer.getVariable( "screenObjectsTable" ), newPickable )

        -- set speed
        newPickable:setLinearVelocity( -450*gameSpeed, 0 )
    end
end

local function spawnObstacle( assetPath, location, xPos, yPos, linearVelocity, scaleFact )

    -- outline asset image
    local assetOutline = graphics.newOutline( 2, assetPath )
    
    -- create object
    local newObstacle = display.newImage( group, assetPath, xPos, yPos )
    newObstacle.myName = "obstacle"
    newObstacle.xScale = scaleFact
    newObstacle.yScale = scaleFact

    -- adapt to location
    if ( location == "floor" ) then
        newObstacle.anchorY = 1

    elseif ( location == "ceiling" ) then
        newObstacle.rotation = 180
        newObstacle.anchorY = 1
    end
    
    -- set physics
    physics.addBody( newObstacle, "kinematic", { isSensor=true, outline=assetOutline } )

    -- add to table
    table.insert( composer.getVariable( "screenObjectsTable" ), newObstacle )

    -- set speed
    newObstacle:setLinearVelocity( linearVelocity, 0 ) 
end

local function spawnHandler()

    local gameSpeed = composer.getVariable( "gameSpeed" )

    -- handle cooldowns
    local obstacleSpawnCooldown = 2/gameSpeed -- cooldown seconds
    if ( (os.time() - lastSpawnObstacle) < obstacleSpawnCooldown ) then
        return
    end
    lastSpawnObstacle = os.time()

    -- set random obstlacle properties
    local assetPath = obsDir .. "stone/" .. 2 .. ".png"
    local linearVelocity = -450 * gameSpeed
    local xPos = display.contentCenterX
    local scaleFact = 1.2
    local location
    if ( math.random( 2 ) == 1 ) then
        location = "floor"
        spawnObstacle( assetPath, location, xPos, display.contentHeight+20, linearVelocity, scaleFact )
    else
        location = "ceiling"
        spawnObstacle( assetPath, location, xPos, -20, linearVelocity, scaleFact )
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
    lastSpawnObstacle = os.time()

    -- set spawn timers
    --spawnGroundObjectsTimer = timer.performWithDelay( 3000, spawnGroundObjects, 0 )
    --spawnFloatingObjectsTimer = timer.performWithDelay( 2000, spawnFloatingObjects, 0 )
    spawnHandlerTimer = timer.performWithDelay( 1000, spawnHandler, 0 )
end

-- clear function
function M.clear()

    -- remove Runtime listeners (do before removing references to the objects to be removed)

    -- remove object references
    M.pickableObjectsTable = {}

    -- remove timers
    --timer.cancel( spawnGroundObjectsTimer )
    --timer.cancel( spawnFloatingObjectsTimer )
    timer.cancel( spawnHandlerTimer )
end


-- return module table
return M
