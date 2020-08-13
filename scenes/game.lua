
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- set up physics
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- initialize variables -------------------------------------------------------

local lives = 3
local score = 0
local died = false
local gameSpeed = 1
 
local pickableObjectTable = {}
 
local submarine
local submarineIsRising = false
local submarineRisingSpeed = 400

local gameLoopTimer
local livesText
local scoreText

local bgLayerNum = 6 -- num of the background layers to load from the assets folder

-- display groups
local bgGroup
local mainGroup
local uiGroup

local bgLayerGroupTable = {}



-- define functions -----------------------------------------------------------

local function scaleDisplayObject( object )

	-- calculate scaling factor to fit
	local scaleFact = math.max( (display.contentWidth / object.width), (display.contentHeight / object.height) )

	-- print(scaleFact, display.contentWidth, object.width, display.contentHeight, object.height) -- TEST

	-- set scale
	object.xScale = scaleFact
	object.yScale = scaleFact
end

-- UI text updater
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

-- game loop
local function gameLoop()
 
    -- Create new objects
 
    -- Remove objects which have drifted off screen
    
end

local function backgroundScroller( self, event )

	local speed = 1 -- default speed per frame

	-- set a different speed for each layer
	for i=1, bgLayerNum do
		if ( self == bgLayerGroupTable[i] ) then
			speed = i
		end
	end

	if ( self.x < -(display.contentWidth - (speed * 2)) ) then
		self.x = 0

	else
		self.x = self.x - speed
	end
end
 
local function moveSubmarine( event )

	local transRot -- var to hold the rotation transition reference
	local rotDeg = 15 -- rotation degree
	local rotTime = 1000 -- rotation degree

	-- start of touch
	if ( event.phase == "began" ) then
		 -- Set touch focus on the submarine (this means that the submarine object will "own" the touch event throughout its duration)
		display.currentStage:setFocus( submarine )

		-- rotate submarine
		transition.cancel( transRot )
		transRot = transition.to( submarine, {rotation = -rotDeg, time = rotTime} )

		-- rise of submarine
		submarineIsRising = true
		submarine:setLinearVelocity( 0, -submarineRisingSpeed )
		
	elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
		-- Release touch focus on the ship
		display.currentStage:setFocus( nil )

		-- change rotation
		transition.cancel( transRot )
		transRot = transition.to( submarine, {rotation = rotDeg, time = rotTime} )
	
		-- fall of submarine
		submarineIsRising = false
		submarine:setLinearVelocity( 0, submarineRisingSpeed )	
	end
	
    return true  -- Prevents touch propagation to underlying objects
end

local function onEnterFrame( event ) 

	-- check bounds of submarine rotation -------------------------------------
	if (submarineIsRising == true and submarine.y < 70) then
		submarineIsRising = false
		submarine:setLinearVelocity( 0, 0 )
		transition.cancel( submarine )
		transition.to( submarine, {rotation = 0, time = 150} )
	end

	if (submarineIsRising == false and submarine.y > display.contentHeight-70) then
		submarineIsRising = true
		submarine:setLinearVelocity( 0, 0 )
		transition.cancel( submarine )
		transition.to( submarine, {rotation = 0, time = 150} )
	end


end

local function testScreen() -- TEST

	print( "display.contentWidth", display.contentWidth, "display.contentHeight", display.contentHeight )
	print( "display.pixelHeight", display.pixelHeight, "display.pixelWidth", display.pixelWidth ) -- this is relative to PORTRAIT ORIENTATION
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- TEST
	timer.performWithDelay( 5000, testScreen, 0 )

	physics.pause()  -- Temporarily pause the physics engine (we don't want the game to really start yet)

	-- function to do game checks on every frame:
	Runtime:addEventListener( "enterFrame", onEnterFrame )
 
	-- Set up display groups --------------------------------------------------
	-- NOTE: here we use the Group vars initialized earlier

    bgGroup = display.newGroup()  -- display group for background
    sceneGroup:insert( bgGroup )  -- insert into the scene's view group
 
    mainGroup = display.newGroup()  -- display group for the main game objects (like the submarine)
    sceneGroup:insert( mainGroup )  -- insert into the scene's view group
 
    uiGroup = display.newGroup()    -- display group for UI
	sceneGroup:insert( uiGroup )    -- insert into the scene's view group

	-- set display groups for background scrolling
	for i=1, bgLayerNum do
		bgLayerGroupTable[i] = display.newGroup() -- define new group
		bgGroup:insert( bgLayerGroupTable[i] ) -- insert in bgGroup
	end


	-- load and set background ------------------------------------------------

	local bgDir = "assets/game/background/layers/" -- bg assets dir

	-- load all bgLayer groups
	for i=1, bgLayerNum do

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
	for i=1, bgLayerNum do
		bgLayerGroupTable[i].enterFrame = backgroundScroller
		Runtime:addEventListener( "enterFrame", bgLayerGroupTable[i] )
	end


	-- load and set submarine -------------------------------------------------

	local submarineDir = "assets/game/submarine/" -- submarine assets dir
	local skinName = "submarine_default" -- skin asset name

	-- load submarine skin
	local submarinePaint = {
		type = "image",
		filename = submarineDir .. skinName .. ".png"
	}

	-- set submarine Rect size related to contentWidth
	local submarineRectSize = display.contentWidth * 0.12

	-- create submarine obj
	submarine = display.newRect( mainGroup, display.contentCenterX - (display.contentWidth*0.34), display.contentCenterY, submarineRectSize, submarineRectSize )
	submarine.fill = submarinePaint

	-- set physics
	physics.addBody( submarine, { radius=30, isSensor=true } )
	submarine.myName = "submarine"
	
	-- set event listener to move the submarine
	Runtime:addEventListener( "touch", moveSubmarine )



end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

		-- re-start physics engine ( previously stopped in create() )
		physics.start()
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
