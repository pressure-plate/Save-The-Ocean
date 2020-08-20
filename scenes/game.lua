
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- set up physics
local physics = require( "physics" )
physics.start()

-- load submarine module
local subMod = require( "scenes.game.submarine" )

-- load background module
local bgMod = require( "scenes.game.background" )

-- load pickable module
local spawnMod = require( "scenes.game.spawner" )

-- initialize variables -------------------------------------------------------

local score = 0
local scoreText

local maxGameSpeed = 4

local gameSpeedUpdateTimer
local clearObjectsTimer

-- display groups
local bgGroup
local mainGroup
local obstacleGroup
local submarineGroup
local uiGroup


-- ----------------------------------------------------------------------------
-- game functions
-- ----------------------------------------------------------------------------

-- update game speed
local function gameSpeedUpdate()

	local gs = composer.getVariable( "gameSpeed" )

	-- limit game speed to 4
	if ( gs < maxGameSpeed ) then 

		local st = composer.getVariable( "startTime" )
		gs = 1 + ( (os.time() - st) / 100 )
		--gs = 2 -- TEST
		composer.setVariable( "gameSpeed", gs )
	end

	print( "gameSpeed: ", gs ) -- TEST
end

-- end game
local function endGame()

    -- set variable to be accessed from the composer
    --composer.setVariable( "finalScore", score )

    -- go to highscores scene
	--composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
	
	composer.gotoScene( "scenes.menu", { time=800, effect="crossFade" } )
end

-- collision handler
local function onCollision( event )
 
    -- detect "began" phase of collision
    if ( event.phase == "began" ) then
 
        -- rename for simplicity
        local obj1 = event.object1
        local obj2 = event.object2

        -- handle "submarine" and "groundObject" collision
        -- no way to determine who is who, so we write both conditions
        if ( ( obj1.myName == "submarine" and obj2.myName == "groundObject" ) or
             ( obj1.myName == "groundObject" and obj2.myName == "submarine" ) )
		then
			-- remove groundObject from display
			if ( obj1.myName == "groundObject" ) then
				display.remove( obj1 )

			else
				display.remove( obj2 )
			end

			-- remove "groundObject" reference from "screenObjectsTable"
			local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
            for i = #screenObjectsTable, 1, -1 do
                if ( screenObjectsTable[i] == obj1 or screenObjectsTable[i] == obj2 ) then
                    table.remove( screenObjectsTable, i )
                    break
                end
            end

            -- update score
            score = score + 100
			scoreText.text = "Score: " .. score
			 
		-- handle "submarine" and "floatingObject" collision
        -- no way to determine who is who, so we write both conditions
		elseif ( ( obj1.myName == "submarine" and obj2.myName == "floatingObject" ) or
             	 ( obj1.myName == "floatingObject" and obj2.myName == "submarine" ) )
		then
			-- remove floatingObject from display
			if ( obj1.myName == "floatingObject" ) then
				display.remove( obj1 )

			else
				display.remove( obj2 )
			end

            -- remove "floatingObject" reference from "screenObjectsTable"
			local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
            for i = #screenObjectsTable, 1, -1 do
                if ( screenObjectsTable[i] == obj1 or screenObjectsTable[i] == obj2 ) then
                    table.remove( screenObjectsTable, i )
                    break
                end
            end

            -- update score
            score = score + 50
			scoreText.text = "Score: " .. score
			
		-- handle "obstacle" and ("floatingObject" or "groundObject") collision
		-- no way to determine who is who, so we write all conditions
		-- this check is done to avoid losing score on objects that are impossible to pick
		elseif ( ( obj1.myName == "obstacle" and obj2.myName == "floatingObject" ) or
				 ( obj1.myName == "floatingObject" and obj2.myName == "obstacle" ) or
				 ( obj1.myName == "obstacle" and obj2.myName == "groundObject" ) or
				 ( obj1.myName == "groundObject" and obj2.myName == "obstacle" ) )
		then
			-- Remove "ground/floatingObject" from display
			if ( obj1.myName == "floatingObject" or obj1.myName == "groundObject" ) then
				display.remove( obj1 )

			else
				display.remove( obj2 )
			end

            -- remove "ground/floatingObject" reference from "screenObjectsTable"
			local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
            for i = #screenObjectsTable, 1, -1 do
				if ( (screenObjectsTable[i] == obj1 or screenObjectsTable[i] == obj2 ) and
				     ( screenObjectsTable[i].myName == "floatingObject" or screenObjectsTable[i].myName == "groundObject" ) )
				then
                    table.remove( screenObjectsTable, i )
                    break
                end
            end

		-- handle "submarine" and "obstacle" collision
		-- no way to determine who is who, so we write both conditions
        elseif ( ( obj1.myName == "submarine" and obj2.myName == "obstacle" ) or
                 ( obj1.myName == "obstacle" and obj2.myName == "submarine" ) )
        then
			
			-- stop screen objects movement
			bgMod.stopBackground = true
			physics.pause()
			transition.cancel( subMod.submarine )

			-- set fading black screen
			local blackScreen = display.newRect( uiGroup, display.contentCenterX, display.contentCenterY, 3000, 1080 )
			blackScreen.alpha = 0.6
			blackScreen:setFillColor( 0, 0, 0 ) -- black

			-- display game over
			local gameOverText = display.newText( uiGroup, "GAME OVER", display.contentCenterX, display.contentCenterY-200, "fonts/AlloyInk", 140 )
			gameOverText:setFillColor( 0.9, 0.5, 0.1 )

			-- display score
			local scoredText = display.newText( uiGroup, "SCORED: " .. score, display.contentCenterX, display.contentCenterY+100, "fonts/AlloyInk", 120 )
			scoredText:setFillColor( 0.9, 0.5, 0.1 )

			-- call endgame function after a short delay
			timer.performWithDelay( 4000, endGame )
        end
    end
end

local function clearObjects()
 
	-- remove objects which have drifted off screen

	local screenObjectsTable = composer.getVariable( "screenObjectsTable" )
	
	for i = #screenObjectsTable, 1, -1 do
		
		local thisObject = screenObjectsTable[i]
		
        if ( thisObject.x < -400 ) then
            display.remove( thisObject )
            table.remove( screenObjectsTable, i )
        end
    end
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
	composer.setVariable( "startTime", os.time() ) -- save game start time
	composer.setVariable( "gameSpeed", 1 ) -- set initial game speed
	composer.setVariable( "screenObjectsTable", {} ) -- keep a table of screen objects to clear during game


	-- Set up display groups
	-- NOTE: here we use the Group vars initialized earlier
    bgGroup = display.newGroup()  -- display group for background
    sceneGroup:insert( bgGroup )  -- insert into the scene's view group
 
    mainGroup = display.newGroup()  -- display group for the game objects
	sceneGroup:insert( mainGroup )  -- insert into the scene's view group

	obstacleGroup = display.newGroup()  -- display group for the obstacles objects
	sceneGroup:insert( obstacleGroup )  -- insert into the scene's view group

	submarineGroup = display.newGroup()  -- display group for the submarine object
	sceneGroup:insert( submarineGroup )  -- insert into the scene's view group
 
    uiGroup = display.newGroup()    -- display group for UI
	sceneGroup:insert( uiGroup )    -- insert into the scene's view group


	-- set event listener to update game speed
	gameSpeedUpdateTimer = timer.performWithDelay(1000, gameSpeedUpdate, 0)

	-- load and set background
	bgMod.init( bgGroup )	

	-- load and set the objects spawner
	spawnMod.init( mainGroup )

	-- load and set submarine
	subMod.init( submarineGroup, mainGroup )

	-- global collision listener
	Runtime:addEventListener( "collision", onCollision )

	-- display score
	local font = composer.getVariable( "defaultFontParams" )
	scoreText = display.newText( uiGroup, "SCORE: " .. score, display.contentWidth-50, 40, font.path, 70 )
	scoreText.anchorX = 1 -- align
	scoreText:setFillColor( font.colorR, font.colorG, font.colorB )

	-- set timer to trigger the clear objects function at regular intervals
	clearObjectsTimer = timer.performWithDelay( 2000, clearObjects, 0 ) -- TODO reduce time

	-- display sea life bar
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
		Runtime:removeEventListener( "collision", onCollision )

		-- clear timers
		timer.cancel( gameSpeedUpdateTimer )
		timer.cancel( clearObjectsTimer )

		-- clear loaded modules
		bgMod.clear()
		subMod.clear()
		spawnMod.clear()

		-- remove the scene from cache 
		-- NOTE: this function entirely removes the scene and all the objects and variables inside,
		--			in particular it takes care of display.remove() all display objects inside sceneGroup hierarchy
		--			but NOTE that it doesn't remove things like timers or listeners attached to the "Runtime" object (so we took care of them manually)
		composer.removeScene( "scenes.game" )
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
