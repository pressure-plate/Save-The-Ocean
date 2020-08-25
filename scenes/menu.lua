
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- initialize variables -------------------------------------------------------

local fadeOutGame = 1400-- time to switch in game Mode

-- load background module
local bgMod = require( "scenes.menu.background" )

-- load background module
local windowMod = require( "scenes.menu.window" )

-- assets directory
local bgDir = "assets/menu/" -- user interface assets dir
local uiDir = "assets/ui/" -- user interface assets dir

-- display groups
local bgGroup
local uiGroup

-- scale
local buttonScaleFactor = 0.6
local badgesScaleFactor = 0.3

-- buttons grid formatting, set on init
local buttonRowOffset -- the offet between each button on the same row

-- audio
local menuTrack
local buttonPlaySound

local menuTrackPlayer


-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	
	-- set up groups for display objects
	bgGroup = display.newGroup() -- display group for background
	sceneGroup:insert( bgGroup ) -- insert into the scene's view group

	uiGroup = display.newGroup() -- display group for UI
	sceneGroup:insert( uiGroup ) -- insert into the scene's view group

	-- load and set background
	bgMod.init( bgGroup )

	-- load and set settings window manager
	windowMod.init( uiGroup )

	-- load music
	menuTrack = audio.loadStream( "audio/Halo-SetFireInYourHeart.mp3")
	buttonPlaySound = audio.loadStream( "audio/sfx/play.mp3")

	-- set title on the menu
	local titleImmage = display.newImageRect(uiGroup, bgDir .. "menu2.png", display.contentWidth, display.contentHeight) -- set title
	titleImmage.x = display.contentCenterX
	titleImmage.y = display.contentCenterY
	
	-- set button to play the game
	local playButton = display.newImage(uiGroup, uiDir .. "buttonPlay3.png")
	playButton:scale(buttonScaleFactor, buttonScaleFactor)
	playButton.x = display.contentCenterX
	playButton.y = display.contentCenterY
	playButton:addEventListener( 
		"tap", 
		function () 
			audio.play( buttonPlaySound )
    		composer.gotoScene( "scenes.game", { time=fadeOutGame, effect="crossFade" } )
		end  
	) -- tap listener

	-- set offsets based on the dimensions of the button
	-- based on the play button that is on the center of the screen
	buttonRowOffset = playButton.height*buttonScaleFactor*1.1

	-- set button to display highscores
	local highScoresButton = display.newImage(uiGroup, uiDir .. "buttonScores.png")
	highScoresButton:scale(buttonScaleFactor, buttonScaleFactor)
	highScoresButton.x = display.contentCenterX
	highScoresButton.y = display.contentCenterY + buttonRowOffset * 1  -- increment the counter for each new button in the column
	highScoresButton:addEventListener( "tap", windowMod.openHighscoresMenu ) -- tap listener

	-- set button to open about windows
	local aboutButton = display.newImage(uiGroup, uiDir .. "buttonAbout.png")
	aboutButton:scale(buttonScaleFactor, buttonScaleFactor)
	aboutButton.x = display.contentCenterX
	aboutButton.y = display.contentCenterY + buttonRowOffset * 2  -- increment the counter for each new button in the column
	aboutButton:addEventListener( "tap", windowMod.openAboutMenu ) -- tap listener
	
	-- ----------------------------------------------------------------------------
	-- top right bagdes
	-- ----------------------------------------------------------------------------
	local buttonRowOffset = 200 -- the offet between each button on the same row

	-- open worlds window
	local worldsBadge = display.newImage(uiGroup, uiDir .. "badgeEdit.png") -- set mask
	worldsBadge:scale( badgesScaleFactor, badgesScaleFactor )
	worldsBadge.x = display.contentCenterX + display.contentWidth/2.3
	worldsBadge.y = display.contentCenterY - display.contentHeight/2.5
	worldsBadge:addEventListener( "tap", windowMod.openWorldsMenu ) -- tap listener

	-- open sumbmarines window
	local sumbmarinesBadge = display.newImage(uiGroup, uiDir .. "badgeSubmarine.png") -- set mask
	sumbmarinesBadge:scale( badgesScaleFactor, badgesScaleFactor )
	sumbmarinesBadge.x = display.contentCenterX + display.contentWidth/2.3 - buttonRowOffset * 1
	sumbmarinesBadge.y = display.contentCenterY - display.contentHeight/2.5
	sumbmarinesBadge:addEventListener( "tap", windowMod.openSubmarinesMenu ) -- tap listener

	-- open bubbles window
	local bubblesBadge = display.newImage(uiGroup, uiDir .. "badgeBubbles.png") -- set mask
	bubblesBadge:scale( badgesScaleFactor, badgesScaleFactor )
	bubblesBadge.x = display.contentCenterX + display.contentWidth/2.3 - buttonRowOffset * 2
	bubblesBadge.y = display.contentCenterY - display.contentHeight/2.5
	bubblesBadge:addEventListener( "tap", windowMod.openBubblesMenu ) -- tap listener


	-- show version
	local fontParams = composer.getVariable( "defaultFontParams" )

	local versionStamp = display.newText( 
        uiGroup, 
        'ver.: ' .. composer.getVariable( "version" ), 
        display.contentCenterX - display.contentWidth/2.5, 
        display.contentCenterY + display.contentHeight/2.3, 
        fontParams.path, 
        50 
	)
	versionStamp:setFillColor( fontParams.colorR, fontParams.colorG, fontParams.colorB )

	local gameProgrammingStamp = display.newText( 
        uiGroup, 
        'Laboratorio di Game Programing', 
        display.contentCenterX + display.contentWidth/4.1, 
        display.contentCenterY + display.contentHeight/2.3, 
        fontParams.path, 
        50 
	)
	gameProgrammingStamp:setFillColor( fontParams.colorR, fontParams.colorG, fontParams.colorB )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		menuTrackPlayer = audio.play( menuTrack, { channel=1, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		
		-- when the scene will be removed start to fade out the music
		-- audio.fadeOut( { channel=1, time=fadeOutGame } )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

		-- clear background
		bgMod.clear()

		-- stop the music after the fadeout 
		audio.stop( menuTrackPlayer )
		menuTrackPlayer = nil

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

	-- delete music tracks
	audio.dispose( menuTrack )
	audio.dispose( buttonPlaySound )
	
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
