local M = {}

local composer = require( "composer" )

local physics = require( "physics" )

-- background vars
M.bgWorld = 1 -- world selector
M.bgLayerNum = 6 -- num of the background layers to load from the assets folder
M.stopBackground = false -- stops the background movement
local bgLayerGroupTable

-- background assets dir
local bgDir -- this will be setted every time .init() function is called to allow world change


-- ----------------------------------------------------------------------------
-- functions
-- ----------------------------------------------------------------------------

local function backgroundScroller( self, event )

    -- check if background should stop
    if ( M.stopBackground ) then
        return
    end

	local speed = 1 -- default speed per frame

	-- set a different speed for each layer
	for i=1, M.bgLayerNum do
		if ( self == bgLayerGroupTable[i] ) then
            speed = i * composer.getVariable( "gameSpeed" )
		end
	end

	if ( self.x < -(display.contentWidth - (speed * 2)) ) then
		self.x = 0

	else
		self.x = self.x - speed
	end
end


-- ----------------------------------------------------------------------------
-- module utility functions
-- ----------------------------------------------------------------------------

-- init function
function M.init( bgGroup )
    
    -- init vars
    M.stopBackground = false
    bgLayerGroupTable = {}
    bgDir = "assets/background/worlds/" .. M.bgWorld .. "/"  -- refresh assets dir to change between worlds
    
    -- set display groups for background scrolling
	for i=1, M.bgLayerNum do
		bgLayerGroupTable[i] = display.newGroup() -- define new group
		bgGroup:insert( bgLayerGroupTable[i] ) -- insert in bgGroup
	end
    
    -- load all bgLayer groups
    for i=1, M.bgLayerNum do

        local leftImage, midImage, rightImage -- temp vars to fill the bgLayer groups

        -- set painting
        local bgLayerPaint = {
            type = "image",
            filename = bgDir .. i .. ".png"
        }

        -- set the 3 images inside the bgLayerGroupTable[i]
        leftImage = display.newRect( bgLayerGroupTable[i], display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight ) -- set rect
        leftImage.fill = bgLayerPaint -- fill
        leftImage.anchorX = 1 -- align

        midImage = display.newRect( bgLayerGroupTable[i], display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight ) -- set rect
        midImage.fill = bgLayerPaint -- fill
        midImage.anchorX = 0 -- align

        rightImage = display.newRect( bgLayerGroupTable[i], display.contentCenterX+display.contentWidth, display.contentCenterY, display.contentWidth, display.contentHeight ) -- set rect
        rightImage.fill = bgLayerPaint -- fill
        rightImage.anchorX = 0 -- align
    end

    -- set all the listeners for the background layers scrolling
    for i=1, M.bgLayerNum do
        bgLayerGroupTable[i].enterFrame = backgroundScroller
        Runtime:addEventListener( "enterFrame", bgLayerGroupTable[i] )
    end	
end

-- clear function
function M.clear()

    -- clear Runtime listeners
    for i=1, M.bgLayerNum do
        Runtime:removeEventListener( "enterFrame", bgLayerGroupTable[i] )
    end

    -- remove object references
    bgLayerGroupTable = nil
end


-- return module table
return M
