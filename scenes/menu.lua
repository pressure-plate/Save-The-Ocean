
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- initialize variables -------------------------------------------------------

local bgLayerNum = 7 -- num of the background layers to load from the assets folder

-- display groups
local bgGroup
local uiGroup

local bgLayerGroupTable = {}


-- ----------------------------------------------------------------------------
-- menu functions
-- ----------------------------------------------------------------------------

local function gotoGame()
    composer.gotoScene( "scenes.game", { time=800, effect="crossFade" } )
end

local function gotoHighScores()
    --composer.gotoScene( "scenes.highscores", { time=800, effect="crossFade" } )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- NOTE add all display objects to "sceneGroup"

	-- set up groups for display objects
	bgGroup = display.newGroup() -- display group for background
	sceneGroup:insert( bgGroup ) -- insert into the scene's view group

	uiGroup = display.newGroup() -- display group for UI
	sceneGroup:insert( uiGroup ) -- insert into the scene's view group

	-- set display groups for background
	for i=1, bgLayerNum do
		bgLayerGroupTable[i] = display.newGroup() -- define new group
		bgGroup:insert( bgLayerGroupTable[i] ) -- insert in bgGroup
	end

	-- load background ---------------------------------------------------
	local bgDir = "assets/background/menu/" -- bg assets dir

	-- load all bgLayer groups
	for i=1, bgLayerNum do

		local leftImage, midImage, rightImage -- temp vars to fill the bgLayer groups

		-- set painting
		local bgLayerPaint = {
			type = "image",
			filename = bgDir .. i .. ".png"
		}

		-- set the 3 images inside the bgLayerGroupTable[i]
		leftImage = display.newRect(bgLayerGroupTable[i], display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight) -- set rect
		leftImage.fill = bgLayerPaint -- fill
		leftImage.anchorX = 1 -- align

		midImage = display.newRect(bgLayerGroupTable[i], display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight) -- set rect
		midImage.fill = bgLayerPaint -- fill
		midImage.anchorX = 0 -- align

		rightImage = display.newRect(bgLayerGroupTable[i], display.contentCenterX+display.contentWidth, display.contentCenterY, display.contentWidth, display.contentHeight) -- set rect
		rightImage.fill = bgLayerPaint -- fill
		rightImage.anchorX = 0 -- align
	end

	-- manually refine layer positions for the menu
	bgLayerGroupTable[5].x = bgLayerGroupTable[5].x - 200
	bgLayerGroupTable[4].x = bgLayerGroupTable[4].x - 230

	-- set mask
	local maskImmage = display.newImageRect(uiGroup, "assets/background/home.png", display.contentWidth, display.contentHeight) -- set mask
	maskImmage.x = display.contentCenterX
	maskImmage.y = display.contentCenterY

	--[[
	-- set button to play game
	local playButton = display.newText( uiGroup, "Play", display.contentCenterX-75, display.contentCenterY-70, native.systemFontBold, 40 )
	playButton:setFillColor( 0.20, 0.63, 0.92 )
	playButton:addEventListener( "tap", gotoGame ) -- tap listener

	-- set button to display highscores
	local highScoresButton = display.newText( uiGroup, "High Scores", display.contentCenterX-75, display.contentCenterY, native.systemFontBold, 40 )
	highScoresButton:setFillColor( 0.20, 0.63, 0.92 )
	highScoresButton:addEventListener( "tap", gotoHighScores ) -- tap listener
	]]--
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
