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
	local minRaiseRotation = 5 -- rotation degree
	local rotDeg = 35 -- rotation degree
	local rotTime = 500 -- rotation time

	-- start of touch
    if ( event.phase == "began" ) then
        
		 -- Set touch focus on the submarine (this means that the submarine object will "own" the touch event throughout its duration)
		display.currentStage:setFocus( self )
		

		-- rise listener of submarine
		local function raiseListener( obj )
			submarineIsRising = true
			self:setLinearVelocity( 0, -submarineRisingSpeed )	
		end

		-- rotate submarine, and on complete call the raise listener
		transition.cancel( transRot )
		transRot = transition.to( self, {rotation = -minRaiseRotation, time = rotTime/2, onComplete = raiseListener} )
		
		-- complete the raise rotation to the max degree
		transRot = transition.to( self, {rotation = -rotDeg, time = rotTime} )

		
	elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
		-- Release touch focus on the ship
		display.currentStage:setFocus( nil )

		-- fall listener of submarine
		local function fallListener( obj )
			submarineIsRising = false
			self:setLinearVelocity( 0, submarineRisingSpeed )	
		end

		-- change rotation
		transition.cancel( transRot )
		transRot = transition.to( self, {rotation = minRaiseRotation, time = rotTime/2, onComplete = fallListener} )
	
		-- complete the fall rotation to the max degree	
		transRot = transition.to( self, {rotation = rotDeg, time = rotTime} )
	end
	
    return true  -- Prevents touch propagation to underlying objects
end

local function onEnterFrame( self, event ) 

	local rotTime = 500 -- rotation time

	-- check bounds of submarine rotation -------------------------------------
	if (submarineIsRising == true and self.y < 70) then
		submarineIsRising = false
		self:setLinearVelocity( 0, 0 )
		transition.cancel( self )
		transition.to( self, {rotation = 0, time = rotTime} )
	
	elseif (submarineIsRising == false and self.y > display.contentHeight-70) then
		submarineIsRising = true
		self:setLinearVelocity( 0, 0 )
		transition.cancel( self )
		transition.to( self, {rotation = 0, time = rotTime} )
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
    submarineRisingSpeed = 400

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
