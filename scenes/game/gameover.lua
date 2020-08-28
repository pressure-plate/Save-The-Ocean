
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- init vars
local parentScene

local font = composer.getVariable( "defaultFontParams" )


-- assets dir
local uiDir = "assets/ui/" -- user interface assets dir


-- functions
local function gotoMenu()
	composer.hideOverlay()
	parentScene:gotoMenu()
end

local function gotoRefresh()
	composer.hideOverlay()
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

	-- display menu window
	local window = display.newImageRect( sceneGroup, uiDir .. "window2.png", 1024, 726 )
	window.x = display.contentCenterX
	window.y = display.contentCenterY
	local windowScaleFact = 1
	window.xScale = windowScaleFact
	window.yScale = windowScaleFact

	-- display home button
	local homeButton = display.newImageRect( sceneGroup, uiDir .. "badgeHome.png", 512, 512 )
	homeButton.x = display.contentCenterX - 270
	homeButton.y = display.contentCenterY + 320
	local homeButtonScaleFact = 0.40
	homeButton.xScale = homeButtonScaleFact
	homeButton.yScale = homeButtonScaleFact
	homeButton:addEventListener( "tap", gotoMenu )

	-- display refresh button
	local refreshButton = display.newImageRect( sceneGroup, uiDir .. "badgeBack.png", 512, 512 )
	refreshButton.x = display.contentCenterX + 270
	refreshButton.y = display.contentCenterY + 320
	local refreshButtonScaleFact = 0.40
	refreshButton.xScale = refreshButtonScaleFact
	refreshButton.yScale = refreshButtonScaleFact
	refreshButton:addEventListener( "tap", gotoRefresh )

	-- display game over text
	local gameOverText = display.newText( sceneGroup, "GAME OVER", display.contentCenterX, display.contentCenterY-270, font.path, 120 )
	gameOverText:setFillColor( font.colorR, font.colorG, font.colorB )

	-- display score
	local score = event.params.scoreParam
	local scoredText = display.newText( sceneGroup, "SCORED: " .. score, display.contentCenterX, display.contentCenterY-50, font.path, 100 )
	scoredText:setFillColor( font.colorR, font.colorG, font.colorB )

	-- display score
	local moneyGained = event.params.moneyGainedParam
	local scoredText = display.newText( sceneGroup, "GAINED: " .. moneyGained .. "$", display.contentCenterX, display.contentCenterY+100, font.path, 100 )
	scoredText:setFillColor( font.colorR, font.colorG, font.colorB )
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
