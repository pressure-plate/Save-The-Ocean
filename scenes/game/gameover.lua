
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- load modules
local windowMod = require( "scenes.libs.window" )
local buttonsMod = require( "scenes.libs.ui" ) 

-- init vars
local parentScene

local font = composer.getVariable( "defaultFontParams" )


-- functions
local function gotoMenu()

	--[[
	NOTE: 
		composer.hideOverlay() can be called from the overlay scene, from the parent scene,
		or from some event handler like an Android "back" key handler.
		Attempting to go to another scene via composer.gotoScene() will automatically hide the overlay as well.

		So we call a function in the parentScene which will call a composer.gotoScene(), hiding the overlay as well
	--]]

	parentScene:gotoMenu()
end

local function gotoRefresh()

	--[[
	NOTE: 
		composer.hideOverlay() can be called from the overlay scene, from the parent scene,
		or from some event handler like an Android "back" key handler.
		Attempting to go to another scene via composer.gotoScene() will automatically hide the overlay as well.

		So we call a function in the parentScene which will call a composer.gotoScene(), hiding the overlay as well
	--]]

	parentScene:gotoRefresh()
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- set fading black screen
	local blackScreen = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, 3000, 1080 )
	blackScreen.alpha = 0.6
	blackScreen:setFillColor( 0, 0, 0 ) -- black

	-- display window
	local windowsOptions = {
		showCloseButton = false,
		fontTitleSize = 120,
		windowScaleFactor = 0.8,
        windowTitle = "Game Over"
    }
	windowMod.init( sceneGroup, windowsOptions ) -- load the window in the background
	
	-- display buttons
	local buttonsDescriptor = {
		descriptor = {
			{ "buttonMenu.png", gotoMenu },
			{ "buttonRestart.png", gotoRefresh },
		},
		offsetY = display.contentCenterX / 5,
		offsetX = - display.contentCenterX / 6,
		propagationOffsetX = 360,
		propagation = 'right',
		position = 'center',
		scaleFactor = 0.6
	}
	uiMod.init( sceneGroup, buttonsDescriptor )	

	-- display score
	local score = event.params.scoreParam
	local scoreText = display.newText( sceneGroup, "SCORED: " .. score, display.contentCenterX, display.contentCenterY-80, font.path, 100 )
	scoreText:setFillColor( font.colorR, font.colorG, font.colorB )

	-- display moneyGained
	local moneyGained = event.params.moneyGainedParam
	local moneyGainedText = display.newText( sceneGroup, "GAINED: " .. moneyGained .. "$", display.contentCenterX, display.contentCenterY+20, font.path, 100 )
	moneyGainedText:setFillColor( font.colorR, font.colorG, font.colorB )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		parentScene = event.parent

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
