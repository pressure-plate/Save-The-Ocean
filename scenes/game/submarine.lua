local M = {}

local composer = require( "composer" )

local physics = require( "physics" )

-- submarine vars
M.submarine = nil
local submarineIsRising
local touchActive
local group
local bubbleGroup

-- submarine skin set
M.submarineSkin = "submarine_default"
M.bubbleSkin = "bubble1"

-- submarine assets dir
local submarineDir = "assets/submarine/"


-- ----------------------------------------------------------------------------
-- functions
-- ----------------------------------------------------------------------------

local function moveSubmarine( self, event )
	
	local rotDeg = 15 -- rotation degree
	local rotTimeUp = 800 -- rotation time up
	local rotTimeDown = 1100-- rotation time down

	-- start of touch
    if ( event.phase == "began" ) then 
		 -- Set touch focus on the submarine (this means that the submarine object will "own" the touch event throughout its duration)
		display.currentStage:setFocus( self )

		-- set touch as active
		touchActive = true

		-- rise of submarine
		submarineIsRising = true

		-- rotate submarine
		transition.cancel( self )
		transRot = transition.to( self, { rotation = -rotDeg, time = rotTimeUp } )
	
	elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
		-- Release touch focus on the ship
		display.currentStage:setFocus( nil )

		-- set touch as inactive
		touchActive = false

		-- fall of submarine
		submarineIsRising = false

		-- change rotation
		transition.cancel( self )
		transRot = transition.to( self, { rotation = rotDeg, time = rotTimeDown } )
	end
	
    return true  -- Prevents touch propagation to underlying objects
end

local function onEnterFrame( self, event )

	local rotTime = 150

	-- apply force to move the submarine
	if ( touchActive ) then
		self:applyForce( 0, -12, self.x, self.y )
	end
	
	-- check bounds of submarine rotation
	if (submarineIsRising == true and self.y < 75) then
		submarineIsRising = false
		transition.cancel( self )
		transition.to( self, { rotation = 0, time = rotTime } )
	
	elseif (submarineIsRising == false and self.y > display.contentHeight-75) then
		submarineIsRising = true
		transition.cancel( self )
		transition.to( self, { rotation = 0, time = rotTime } )
	end
end

local function spawnBubble()

	local gameSpeed = composer.getVariable( "gameSpeed" )

	-- load bubble skin
	local bubblePaint = {
		type = "image",
		filename = submarineDir .. M.bubbleSkin .. ".png"
	}

	-- create bubble
	newBubble = display.newRect( bubbleGroup, M.submarine.x-120, M.submarine.y+15, 85, 85 )
	newBubble.fill = bubblePaint
	physics.addBody( newBubble, "kinematic", {isSensor=true} )
	
	-- set random scale
	local randScale = math.random( 10, 50 ) / 100
	newBubble.xScale = randScale
	newBubble.yScale = randScale

	-- add to table
	table.insert( composer.getVariable( "screenObjectsTable" ), newBubble )

	-- set speed and random y direction --TODO
	local randY = math.random( -100, 100 )
	newBubble:setLinearVelocity( -350*gameSpeed, randY )	
end


-- ----------------------------------------------------------------------------
-- module utility functions
-- ----------------------------------------------------------------------------

-- init function
function M.init( submarineGroup, mainGroup )
    
    -- init vars
    M.submarine = nil
	submarineIsRising = false
	touchActive = false
	group = submarineGroup
	bubbleGroup = mainGroup

	-- load submarine skin
	local submarinePaint = {
		type = "image",
		filename = submarineDir .. M.submarineSkin .. ".png"
	}

	-- set submarine Rect size related to contentWidth
	local scaleFact = 0.45

	-- create submarine obj
	M.submarine = display.newRect( group, display.contentCenterX - (display.contentWidth*0.34), display.contentCenterY, 512*scaleFact, 234*scaleFact )
	M.submarine.fill = submarinePaint

	-- set physics
	physics.addBody( M.submarine, { radius=70, bounce=0 } )
	M.submarine.myName = "submarine"

	-- set gravity scale
	M.submarine.gravityScale = 2.7
	
    -- set event listener to move the submarine
    M.submarine.touch = moveSubmarine
    Runtime:addEventListener( "touch", M.submarine )
    
    -- set event listener onEnterFrame function
    M.submarine.enterFrame = onEnterFrame
	Runtime:addEventListener( "enterFrame", M.submarine )
	
	-- set bubble spawner
	bubbleSpawnTimer = timer.performWithDelay( 100, spawnBubble, 0 )

	-- create physical bodies as bounds for the submarine
	-- no need to access these vars elsewhere in the code so we keep them local here
	local floor = display.newRect( group, M.submarine.x, display.contentHeight, 300, 1 )
	floor.isVisible = false
	physics.addBody( floor, "static", { bounce=0 } )

	local ceiling = display.newRect( group, M.submarine.x, 0, 300, 1 )
	ceiling.isVisible = false
	physics.addBody( ceiling, "static", { bounce=0 } )

end

-- clear function
function M.clear()

    -- clear Runtime listeners
    Runtime:removeEventListener( "touch", M.submarine )
    Runtime:removeEventListener( "enterFrame", M.submarine )

    -- remove object references
	M.submarine = nil
	
	-- remove timers
	timer.remove( bubbleSpawnTimer )
end


-- return module table
return M
