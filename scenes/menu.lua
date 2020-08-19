
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- initialize variables -------------------------------------------------------

local bgLayerNum = 7 -- num of the background layers to load from the assets folder

-- load background module
local bgMod = require( "scenes.game.background" )

-- assets directory
local bgDir = "assets/background/menu/" -- user interface assets dir
local uiDir = "assets/ui/" -- user interface assets dir

-- display groups
local bgGroup
local uiGroup

local gameSpeedUpdateTimer = 0.1
local backgroundScrollDirection = 1
local backgroundmaxVel = 0.1

-- buttons scale
local buttosWidthScaleRateo = 0.125
local buttosHeightScaleRateo = 0.1

-- buttons grid formatting
local buttonColOffset = -75 -- the offet to alligh the buttons to the same col
local buttonRowOffset = 120 -- the offet between each button on the same row


-- ----------------------------------------------------------------------------
-- menu functions
-- ----------------------------------------------------------------------------

local function gotoGame()
    composer.gotoScene( "scenes.game", { time=800, effect="crossFade" } )
end

local function gotoHighScores()
    --composer.gotoScene( "scenes.highscores", { time=200, effect="crossFade" } )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- update game speed
local function BackgroundSpeedUpdate()

	local gs = composer.getVariable( "gameSpeed" )

	if ( math.abs(gs) >= backgroundmaxVel ) then 
		backgroundScrollDirection = backgroundScrollDirection * -1
	end
	gs = gs + (0.01) * backgroundScrollDirection

	composer.setVariable( "gameSpeed", gs )
end


-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	
	-- set up groups for display objects
	bgGroup = display.newGroup() -- display group for background
	sceneGroup:insert( bgGroup ) -- insert into the scene's view group

	uiGroup = display.newGroup() -- display group for UI
	sceneGroup:insert( uiGroup ) -- insert into the scene's view group

	-- set event listener to update game speed
	composer.setVariable( "gameSpeed", 0.1 ) -- set initial game speed
	menuBackgroundSpeedUpdateTimer = timer.performWithDelay(400, BackgroundSpeedUpdate, 0)

	-- load and set background
	bgMod.init( bgGroup )

	-- set title on the menu
	local titleImmage = display.newImageRect(uiGroup, bgDir .. "menu.png", display.contentWidth, display.contentHeight) -- set title
	titleImmage.x = display.contentCenterX
	titleImmage.y = display.contentCenterY
	
	-- set button to play game
	local playButton = display.newImageRect(uiGroup, uiDir .. "play.png", display.contentWidth*buttosWidthScaleRateo, display.contentHeight*buttosHeightScaleRateo) -- set mask
	playButton.x = display.contentCenterX + buttonColOffset
	playButton.y = display.contentCenterY + buttonRowOffset * 1
	playButton:addEventListener( "tap", gotoGame ) -- tap listener

	-- set button to display highscores
	local highScoresButton = display.newImageRect(uiGroup, uiDir .. "scores.png", display.contentWidth*buttosWidthScaleRateo, display.contentHeight*buttosHeightScaleRateo) -- set mask
	highScoresButton.x = display.contentCenterX + buttonColOffset
	highScoresButton.y = display.contentCenterY + buttonRowOffset * 2  -- increment the counter for each new button in the column
	highScoresButton:addEventListener( "tap", gotoHighScores ) -- tap listener
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

		-- Before the transition remove the updaters, cause thet will be recreated in the next scene
		-- clear timers
		timer.cancel( menuBackgroundSpeedUpdateTimer )
		-- clear background
		bgMod.clear()

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
