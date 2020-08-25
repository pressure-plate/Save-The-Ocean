
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

-- load the saved data
local savedata = require( "scenes.libs.savedata" ) -- load the save data module

local buttonsMod = require( "scenes.libs.ui" )
local badgesMod = require( "scenes.libs.ui" )

-- assets directory
local bgDir = "assets/menu/" -- user interface assets dir

-- display groups
local bgGroup
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
	buttonClickSound = audio.loadStream( "audio/sfx/click.mp3" )

	-- set title on the menu
	local titleImmage = display.newImageRect(uiGroup, bgDir .. "menu2.png", display.contentWidth, display.contentHeight) -- set title
	titleImmage.x = display.contentCenterX
	titleImmage.y = display.contentCenterY
	

	-- ----------------------------------------------------------------------------
	-- cental buttons
	-- ----------------------------------------------------------------------------
	local function playCallback() 
		audio.play( buttonPlaySound )
		composer.gotoScene( "scenes.game", { time=fadeOutGame, effect="crossFade" } )
	end 

	local buttonsDescriptor = {
		descriptor = {
			{"buttonPlay3.png", playCallback},
			{"buttonScores.png", windowMod.openHighscoresMenu},
			{"buttonAbout.png", windowMod.openAboutMenu}
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
		audioMute = savedata.getGamedata( "audioMute" )
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
	
	local badgesDescriptor = {
		descriptor={
			{"badgeEdit.png", windowMod.openWorldsMenu},
			{"badgeSubmarine.png", windowMod.openSubmarinesMenu},
			{"badgeBubbles.png", windowMod.openBubblesMenu},
			{"badgeMute.png", muteMusicCallback}
		}
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
	audio.dispose( buttonClickSound )
	
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
