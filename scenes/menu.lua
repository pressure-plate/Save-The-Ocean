
local composer = require( "composer" )

local physics = require( "physics" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- initialize variables -------------------------------------------------------

local fadeOutGame = 1400-- time to switch in game Mode


-- Load all the neades modules
local bgMod = require( "scenes.menu.background" ) -- load background module
local titleMod = require( "scenes.menu.title" ) -- to display title and floating objects
local savedata = require( "scenes.libs.savedata" ) -- load the save data module
local buttonsMod = require( "scenes.libs.ui" )  -- ui lib to show buttons in the interface
local badgesMod = require( "scenes.libs.ui" )

-- display groups
local uiGroup

-- audio
local menuTrack
local buttonPlaySound
local buttonClickSound

local menuTrackPlayer


-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.start() -- start/restart the physics, because on gameover it will be stopped
	
	-- set up groups for display objects
	local bgGroup1 = display.newGroup() -- display group for background and for the title
	sceneGroup:insert( bgGroup1 ) -- insert into the scene's view group
	bgMod.init( bgGroup1 ) -- load and set background module

	-- load the title and the floating objects
	local bgGroup2 = display.newGroup()
	sceneGroup:insert( bgGroup2 )
	titleMod.init( bgGroup2 )

	uiGroup = display.newGroup() -- display group for UI
	sceneGroup:insert( uiGroup ) -- insert into the scene's view group

	-- load music
	menuTrack = audio.loadStream( composer.getVariable( "audioDir" ) .. "menu.mp3" )
	buttonPlaySound = audio.loadStream( composer.getVariable( "audioDir" ) .. "sfx/play.mp3" )
	buttonClickSound = audio.loadStream( composer.getVariable( "audioDir" ) .. "sfx/click.mp3" )


	-- ----------------------------------------------------------------------------
	-- cental buttons
	-- ----------------------------------------------------------------------------
	local function playCallback() 
		audio.play( buttonPlaySound )
		composer.gotoScene( "scenes.game", { time=fadeOutGame, effect="slideLeft" } )
	end 

	local function scoresCallback()
		composer.showOverlay( "scenes.menu.scores", { time=composer.getVariable( "windowFadingOpenTime" ), effect="fade" } )
	end

	local function aboutCallback()
		composer.showOverlay( "scenes.menu.about", { time=composer.getVariable( "windowFadingOpenTime" ), effect="fade" } )
	end

	local buttonsDescriptor = {
		descriptor = {
			{ "buttonPlay3.png", playCallback },
			{ "buttonScores.png", scoresCallback },
			{ "buttonAbout.png", aboutCallback }
		},
		propagation = 'down',
		position = 'center',
		scaleFactor = 0.6
	}
	buttonsMod.init(uiGroup, buttonsDescriptor)	
	

	-- ----------------------------------------------------------------------------
	-- top right bagdes
	-- ----------------------------------------------------------------------------
	local function muteMusicCallback()
		local audioMute = savedata.getGamedata( "audioMute" )
		if audioMute then
			audio.setVolume( 0.7, { channel=1 } )
			audio.play( buttonClickSound )
			savedata.setGamedata( "audioMute", false)
		else
			audio.play( buttonClickSound )
			audio.setVolume( 0, { channel=1 } )
			savedata.setGamedata( "audioMute", true)
		end 
	end

	local function worldsMenuCallback() 
		composer.showOverlay( "scenes.settings.worlds", { time=composer.getVariable( "windowFadingOpenTime" ), effect="fade" } )
	end

	local function submarinesMenuCallback() 
		composer.showOverlay( "scenes.settings.submarines", { time=composer.getVariable( "windowFadingOpenTime" ), effect="fade" } )
	end

	local function bubblesMenuCallback() 
		composer.showOverlay( "scenes.settings.bubbles", { time=composer.getVariable( "windowFadingOpenTime" ), effect="fade" } )
	end
	
	-- load the badges in the list
	-- with the packIcon declared the menu will pack under the packIcon as hamburger menu
	local badgesDescriptor = {
		packIcon = "badgeSettings.png",
		packRotation = 360,
		descriptor={
			{"badgeEdit.png", worldsMenuCallback },
			{"badgeSubmarine.png", submarinesMenuCallback },
			{"badgeBubbles.png", bubblesMenuCallback },
			{"badgeMute.png", muteMusicCallback}
		},
		-- yPropagationOffset = 180,
		-- propagation = 'down',

	}
	badgesMod.init(uiGroup, badgesDescriptor)


	-- ----------------------------------------------------------------------------
	-- bottom row text
	-- ----------------------------------------------------------------------------
	
	-- show version
	local fontParams = composer.getVariable( "defaultFontParams" )

	local versionStamp = display.newText( 
        uiGroup, 
        'v ' .. composer.getVariable( "version" ), 
        display.contentCenterX - display.contentWidth/2.5, 
        display.contentCenterY + display.contentHeight/2.3, 
        fontParams.path, 
        50 
	)
	versionStamp:setFillColor( fontParams.colorR, fontParams.colorG, fontParams.colorB )

	-- show label
	-- Game Programming Lab
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

		bgMod.clear() -- clear background

		-- stop the music to let the game music begin
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
	-- audio.dispose( menuTrack )
	-- audio.dispose( buttonPlaySound )
	-- audio.dispose( buttonClickSound )
	
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
