local M = {}

local physics = require( "physics" )

-- submarine vars
M.submarine = nil
local submarineIsRising
local submarineRisingSpeed

-- submarine skin set
M.submarineSkin = "submarine_default"

-- submarine assets dir
local submarineDir = "assets/submarine/"


-- ----------------------------------------------------------------------------
-- functions
-- ----------------------------------------------------------------------------

local function moveSubmarine( self, event )

	local transRot -- var to hold the rotation transition reference
	local rotDeg = 15 -- rotation degree
	local rotTime = 1000 -- rotation time

	-- start of touch
    if ( event.phase == "began" ) then
        
		 -- Set touch focus on the submarine (this means that the submarine object will "own" the touch event throughout its duration)
		display.currentStage:setFocus( self )

		-- rotate submarine
		transition.cancel( transRot )
		transRot = transition.to( self, {rotation = -rotDeg, time = rotTime} )

		-- rise of submarine
		submarineIsRising = true
		self:setLinearVelocity( 0, -submarineRisingSpeed )
		
	elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
		-- Release touch focus on the ship
		display.currentStage:setFocus( nil )

		-- change rotation
		transition.cancel( transRot )
		transRot = transition.to( self, {rotation = rotDeg, time = rotTime} )
	
		-- fall of submarine
		submarineIsRising = false
		self:setLinearVelocity( 0, submarineRisingSpeed )	
	end
	
    return true  -- Prevents touch propagation to underlying objects
end

local function onEnterFrame( self, event ) 

	-- check bounds of submarine rotation -------------------------------------
	if (submarineIsRising == true and self.y < 70) then
		submarineIsRising = false
		self:setLinearVelocity( 0, 0 )
		transition.cancel( self )
		transition.to( self, {rotation = 0, time = 150} )
	
	elseif (submarineIsRising == false and self.y > display.contentHeight-70) then
		submarineIsRising = true
		self:setLinearVelocity( 0, 0 )
		transition.cancel( self )
		transition.to( self, {rotation = 0, time = 150} )
	end
end


-- ----------------------------------------------------------------------------
-- module utility functions
-- ----------------------------------------------------------------------------

-- init function
function M.init( group )
    
    -- init vars
    M.submarine = nil
    submarineIsRising = false
    submarineRisingSpeed = 600

	-- load submarine skin
	local submarinePaint = {
		type = "image",
		filename = submarineDir .. M.submarineSkin .. ".png"
	}

	-- set submarine Rect size related to contentWidth
	local submarineRectSize = display.contentWidth * 0.12

	-- create submarine obj
	M.submarine = display.newRect( group, display.contentCenterX - (display.contentWidth*0.34), display.contentCenterY, submarineRectSize, submarineRectSize )
	M.submarine.fill = submarinePaint

	-- set physics
	physics.addBody( M.submarine, { radius=30, isSensor=true } )
	M.submarine.myName = "submarine"
	
    -- set event listener to move the submarine
    M.submarine.touch = moveSubmarine
    Runtime:addEventListener( "touch", M.submarine )
    
    -- set event listener onEnterFrame function
    M.submarine.enterFrame = onEnterFrame
    Runtime:addEventListener( "enterFrame", M.submarine )
end

-- clear function
function M.clear()

    -- clear Runtime listeners
    Runtime:removeEventListener( "touch", M.submarine )
    Runtime:removeEventListener( "enterFrame", M.submarine )

    -- remove object references
    M.submarine = nil
end


-- return module table
return M
