local M = {}

local composer = require( "composer" )

local physics = require( "physics" )
physics.start()

local savedata = require( "scenes.libs.savedata" )


-- background assets dir
local bgDir = "assets/background/worlds/" -- dir to change between worlds
local itemsDir = "assets/items/" -- dir to change between worlds

local group -- the background group

-- background vars

local backgroundWorld -- the id of the background loaded
local backgroundLayerNum = 6 -- num of the background layers to load from the assets folder, default 6

local bgLayerGroupTable

local backgroundScrollDirection
local backgroundmaxVel
local backgroundSpeed
local backgroundLastUpdate -- time since the last update

local screenObjects
local screenObjectsNum = 6

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


local function spawnFloatingObjects()
    
    -- relative dir, scale factor
    local items = {
        {"pickables/bottle/1.png", 0.3},
        {"pickables/barrel/4.png", 0.4},
        {"pickables/bag/2.png", 0.3},
        {"pickables/bag/3.png", 0.3},
        {"neutral/coin1.png", 1.2},
        {"neutral/pearl1.png", 1.2},
        {"neutral/seahorse1.png", 1.2},
    }

    local offset = 512
    local cx, cy = display.contentCenterX, display.contentCenterY
    local cw, ch = display.contentWidth, display.contentHeight
    
    local topBumper = display.newRect( group, cx , 0-offset, cw*2, 1 )
    physics.addBody( topBumper, "static", { density=3.0, bounce=0.0 } )

    local bottomBumper = display.newRect( group, cx, ch+offset, cw*2, 1 )
    physics.addBody( bottomBumper, "static", { density=3.0, bounce=0.0 } )

    local leftBumper = display.newRect( group, 0-offset, cy, 1, ch*2 )
    physics.addBody( leftBumper, "static", { density=3.0, bounce=0.0 } )

    local rightBumper = display.newRect( group, cw+offset, cy, 1, ch+2 ) 
    physics.addBody( rightBumper, "static", { density=3.0, bounce=0.0 } )


    for count, el in pairs ( items ) do

        local dir = el[1]
        local scaleFactor = el[2]

        -- create object
        local spawnPosY = math.random( 
            display.contentCenterY - display.contentHeight/2.2, 
            display.contentCenterY + display.contentHeight/2.2 
        )
        local spawnPosX = math.random( 
            display.contentCenterX - display.contentWidth/2.2,
            display.contentCenterX + display.contentWidth/2.2
        )

        local randRotation = math.random( -30, 30 )

        local item = display.newImage( group, itemsDir .. dir )
        item:scale( scaleFactor, scaleFactor )
        item.x = spawnPosX
        item.y = spawnPosY
        item.rotation = randRotation
        
        physics.addBody( item, { density=3.0, bounce=0.3, radius=50 } )
        item.gravityScale = 0

        local randSpeedX = math.random( -12, 12 )
        local randSpeedr = math.random( -12, 12 )
        item:setLinearVelocity( randSpeedX, randSpeedY )

        item:applyTorque( randRotation )

        table.insert( screenObjects, item )
    end
end


-- init function
function M.init( bgGroup )

    group = bgGroup
    bgLayerGroupTable = {}
    screenObjects = {}

    -- set base data to make the background scroll
    backgroundScrollDirection = 1
    backgroundmaxVel = 0.1
    backgroundSpeed = 0.1
    backgroundLastUpdate = os.time() -- set the start time for the background update
    
    -- load the actual background
    M.updateBackground()
    spawnFloatingObjects()
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
