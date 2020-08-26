local M = {}

local composer = require( "composer" )

local savedata = require( "scenes.libs.savedata" )


-- background assets dir
local bgDir = "assets/background/worlds/" -- dir to change between worlds

local group -- the background group

-- background vars

local backgroundWorld -- the id of the background loaded
local backgroundLayerNum = 6 -- num of the background layers to load from the assets folder, default 6

local bgLayerGroupTable

local backgroundScrollDirection
local backgroundmaxVel
local backgroundSpeed
local backgroundLastUpdate -- time since the last update


-- ----------------------------------------------------------------------------
-- functions Background Scroller
-- ----------------------------------------------------------------------------


local function backgroundScroller( self, event )

    -- update only if time as passed
    if ( os.time() - backgroundLastUpdate >= 1 ) then
        if ( math.abs(backgroundSpeed) >= backgroundmaxVel ) then
            backgroundScrollDirection = backgroundScrollDirection * -1
        end
        backgroundSpeed = backgroundSpeed + (0.01) * backgroundScrollDirection
        backgroundLastUpdate = os.time()
    end
    
    local speed = 1 -- default speed per frame

	-- set a different speed for each layer
	for i=1, backgroundLayerNum do
		if ( self == bgLayerGroupTable[i] ) then
            speed = (backgroundLayerNum-i+1) * backgroundSpeed
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

function M.updateBackground()
    -- clear all the old layers if they exist
    if (bgLayerGroupTable) then
        M.clear()
    end

    backgroundWorld = savedata.getGamedata( "backgroundWorld" )
    backgroundLayerNum = savedata.getGamedata( "backgroundLayerNum" )
    
    -- set display groups for background scrolling
	for i=1, backgroundLayerNum do
		bgLayerGroupTable[i] = display.newGroup() -- define new group
		group:insert( bgLayerGroupTable[i] ) -- insert in group
	end
    
    -- load all bgLayer groups
    for i=1, backgroundLayerNum do

        local leftImage, midImage, rightImage -- temp vars to fill the bgLayer groups

        -- set painting
        local bgLayerPaint = {
            type = "image",
            filename = bgDir .. backgroundWorld .. "/" .. i .. ".png"
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
    for i=1, backgroundLayerNum do
        bgLayerGroupTable[i].enterFrame = backgroundScroller
        Runtime:addEventListener( "enterFrame", bgLayerGroupTable[i] )
    end

    backgroundSpeed = 0.1 -- reset the background speed
end


-- init function
function M.init( viewGroup )

    group = viewGroup -- for the background

    bgLayerGroupTable = {}

    -- set base data to make the background scroll
    backgroundScrollDirection = 1
    backgroundmaxVel = 0.1
    backgroundSpeed = 0.1
    backgroundLastUpdate = os.time() -- set the start time for the background update
    
    -- load the actual background
    M.updateBackground()
end


-- clear function
function M.clear()

    -- clear Runtime listeners
    for i=1, backgroundLayerNum do
        Runtime:removeEventListener( "enterFrame", bgLayerGroupTable[i] )
    end
    bgLayerGroupTable = {}
end


-- return module table
return M
