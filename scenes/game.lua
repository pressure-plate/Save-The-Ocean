
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

-- load submarine module
local subMod = require( "scenes.game.submarine" )

-- load background module
local bgMod = require( "scenes.game.background" )

-- initialize variables -------------------------------------------------------
composer.setVariable(variableName,value)

local lives = 3
local score = 0
local died = false
 
local pickableObjectTable = {}
 
local gameLoopTimer
local livesText
local scoreText

local gameSpeedUpdateTimer

-- display groups
local bgGroup
local mainGroup
local uiGroup


-- ----------------------------------------------------------------------------
-- game functions
-- ----------------------------------------------------------------------------

-- update game speed
local function gameSpeedUpdate()

	local gs = composer.getVariable( "gameSpeed" )

	-- limit game speed to 7
	if ( gs < 7 ) then 

		local st = composer.getVariable( "startTime" )
		gs = 1 + ( (os.time() - st) / 100 )
		composer.setVariable( "gameSpeed", gs )
	end

	print( gs ) -- TEST
end

-- UI text updater
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine (we don't want the game to really start yet)


	-- set composer game vars
	composer.setVariable( "startTime", os.time() )
	composer.setVariable( "gameSpeed", 1 )


	-- Set up display groups
	-- NOTE: here we use the Group vars initialized earlier
    bgGroup = display.newGroup()  -- display group for background
    sceneGroup:insert( bgGroup )  -- insert into the scene's view group
 
    mainGroup = display.newGroup()  -- display group for the main game objects (like the submarine)
    sceneGroup:insert( mainGroup )  -- insert into the scene's view group
 
    uiGroup = display.newGroup()    -- display group for UI
	sceneGroup:insert( uiGroup )    -- insert into the scene's view group


	--set event listener to update game speed
	gameSpeedUpdateTimer = timer.performWithDelay(1000, gameSpeedUpdate, 0)

	-- load and set background
	bgMod.init( bgGroup )

	-- load and set submarine
	subMod.init( mainGroup )

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

		-- clear Runtime listeners

		-- clear timers
		timer.cancel( gameSpeedUpdateTimer )

		-- clear loaded modules
		bgMod.clear()
		subMod.clear()
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
