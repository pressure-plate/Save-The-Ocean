local M = {}

local composer = require( "composer" )

local physics = require( "physics" )

local savedata = require( "scenes.libs.savedata" )

-- background vars
M.bgWorld = 1 -- world selector -- TODO DEPRECATED
M.bgLayerNum = 6 -- num of the background layers to load from the assets folder -- TODO DEPRECATED

local backgroundWorld
local backgroundLayerNum
local stopScrolling
local bgLayerGroupTable

-- background assets dir
local bgDir -- this will be setted every time .init() function is called to allow world change


-- ----------------------------------------------------------------------------
-- private functions
-- ----------------------------------------------------------------------------

local function backgroundScroller( self, event )

    -- check if background should stop
    if ( stopScrolling ) then
        return
    end

	local speed = 1 -- default speed per frame

	-- set a different speed for each layer
	for i=1, backgroundLayerNum do
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
-- public functions
-- ----------------------------------------------------------------------------

-- insert in scene:create()
function M.create( bgGroup )
    
    -- init vars
    backgroundWorld = savedata.getGamedata( "backgroundWorld" )
    backgroundLayerNum = savedata.getGamedata( "backgroundLayerNum" )
    stopScrolling = false
    bgLayerGroupTable = {}
    
    bgDir = "assets/background/worlds/" .. backgroundWorld .. "/"  -- refresh assets dir to change between worlds
    
    -- set display groups for background scrolling
	for i=1, backgroundLayerNum do
		bgLayerGroupTable[i] = display.newGroup() -- define new group
		bgGroup:insert( bgLayerGroupTable[i] ) -- insert in bgGroup
	end
    
    -- load all bgLayer groups
    for i=1, backgroundLayerNum do

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
    for i=1, backgroundLayerNum do
        bgLayerGroupTable[i].enterFrame = backgroundScroller
        Runtime:addEventListener( "enterFrame", bgLayerGroupTable[i] )
    end	
end

-- insert in scene:hide() in "did" phase
function M.hideDid()

    -- remove Runtime listeners
    for i=1, backgroundLayerNum do
        Runtime:removeEventListener( "enterFrame", bgLayerGroupTable[i] )
    end

    -- cancel timers

    -- cancel transitions

    -- dispose loaded audio

end

-- stop the background movement
function M.setStopScrolling( bool )    
    stopScrolling = bool
end


-- return module table
return M
