
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- initialize variables -------------------------------------------------------

-- load background module
local bgMod = require( "scenes.menu.background" )

-- load background module
local windowMod = require( "scenes.menu.window" )

-- assets directory
local bgDir = "assets/background/menu/" -- user interface assets dir
local uiDir = "assets/ui/" -- user interface assets dir

-- display groups
local bgGroup
local uiGroup

local gameSpeedUpdateTimer = 0.1
local backgroundScrollDirection = 1
local backgroundmaxVel = 0.1

-- scale
local ButtonScaleFactor = 0.6
local badgesScaleFactor = 0.3

-- buttons grid formatting, set on init
local buttonRowOffset -- the offet between each button on the same row


-- ----------------------------------------------------------------------------
-- menu functions
-- ----------------------------------------------------------------------------

local function gotoGame()
    composer.gotoScene( "scenes.game", { time=800, effect="crossFade" } )
end

local function gotoHighScores()
    --composer.gotoScene( "scenes.highscores", { time=200, effect="crossFade" } )
end

local function showWorldsSelector()
    -- set title on the menu
	windowMod.openWorldsMenu()
end

local function showSubmarineSelector()
	-- set title on the menu
	windowMod.openSubmarinesMenu()
end

local function showAboutSelector()
    -- set title on the menu
	windowMod.openAboutMenu()
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- update game speed
local function BackgroundSpeedUpdate()

	local gs = composer.getVariable( "backgroundSpeed" )

	if ( math.abs(gs) >= backgroundmaxVel ) then 
		backgroundScrollDirection = backgroundScrollDirection * -1
	end
	gs = gs + (0.01) * backgroundScrollDirection

	composer.setVariable( "backgroundSpeed", gs )
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
	composer.setVariable( "backgroundSpeed", 0.1 ) -- set initial game speed
	menuBackgroundSpeedUpdateTimer = timer.performWithDelay(400, BackgroundSpeedUpdate, 0)

	-- load and set background
	bgMod.init( bgGroup )

	-- load and set settings window manager
	windowMod.init( uiGroup )

	-- set title on the menu
	local titleImmage = display.newImageRect(uiGroup, bgDir .. "menu.png", display.contentWidth, display.contentHeight) -- set title
	titleImmage.x = display.contentCenterX
	titleImmage.y = display.contentCenterY
	
	-- set button to play game
	local playButton = display.newImage(uiGroup, uiDir .. "play.png")
	playButton:scale(ButtonScaleFactor, ButtonScaleFactor)
	playButton.x = display.contentCenterX
	playButton.y = display.contentCenterY
	playButton:addEventListener( "tap", gotoGame ) -- tap listener

	-- set offsets based on the dimensions of the button
	buttonRowOffset = playButton.height*ButtonScaleFactor*1.1

	-- set button to display highscores
	local highScoresButton = display.newImage(uiGroup, uiDir .. "scores.png")
	highScoresButton:scale(ButtonScaleFactor, ButtonScaleFactor)
	highScoresButton.x = display.contentCenterX
	highScoresButton.y = display.contentCenterY + buttonRowOffset * 1  -- increment the counter for each new button in the column
	highScoresButton:addEventListener( "tap", gotoHighScores ) -- tap listener

	-- open about windows
	local aboutButton = display.newImage(uiGroup, uiDir .. "about.png")
	aboutButton:scale(ButtonScaleFactor, ButtonScaleFactor)
	aboutButton.x = display.contentCenterX
	aboutButton.y = display.contentCenterY + buttonRowOffset * 2  -- increment the counter for each new button in the column
	aboutButton:addEventListener( "tap", showAboutSelector ) -- tap listener
	
	--------------------------------------------------
	-- top right bagdes -------------------------------

	local buttonRowOffset = 200 -- the offet between each button on the same ro3

	-- open worlds window
	local worldsBadge = display.newImage(uiGroup, uiDir .. "editBadge.png") -- set mask
	worldsBadge:scale( badgesScaleFactor, badgesScaleFactor )
	worldsBadge.x = display.contentCenterX + display.contentWidth/2.3
	worldsBadge.y = display.contentCenterY - display.contentHeight/2.5
	worldsBadge:addEventListener( "tap", showWorldsSelector ) -- tap listener

	-- open sumbmarines window
	local sumbmarinesBadge = display.newImage(uiGroup, uiDir .. "submarineBadge.png") -- set mask
	sumbmarinesBadge:scale( badgesScaleFactor, badgesScaleFactor )
	sumbmarinesBadge.x = display.contentCenterX + display.contentWidth/2.3 - buttonRowOffset
	sumbmarinesBadge.y = display.contentCenterY - display.contentHeight/2.5
	sumbmarinesBadge:addEventListener( "tap", showSubmarineSelector ) -- tap listener
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

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		
		-- clear timers
		timer.cancel( menuBackgroundSpeedUpdateTimer )
		-- clear background
		bgMod.clear()

		-- remove the scene from cache 
		-- NOTE: this function entirely removes the scene and all the objects and variables inside,
		--		in particular it takes care of display.remove() all display objects inside sceneGroup hierarchy
		--		but NOTE that it doesn't remove things like timers or listeners attached to the "Runtime" object (so we took care of them manually)
		composer.removeScene( "scenes.menu" )
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
