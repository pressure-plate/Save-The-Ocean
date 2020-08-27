local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )

local aboutText


-- to hide the current overlay
function hideScene()
    composer.hideOverlay( "fade", composer.getVariable( "windowFadingClosingTime" ) )
end


function scene:create( event )

    local sceneGroup = self.view

    local group = display.newGroup() -- display group for background
    sceneGroup:insert( group )

    local windowsOptions = {
        onExitCallback = hideScene,
        windowTitle = "About"
    }

    windowMod.init( group, windowsOptions )

    aboutText = display.newImage(group, "assets/menu/about1.png") -- set title
	aboutText.x = display.contentCenterX
    aboutText.y = display.contentCenterY + display.contentHeight/15
    aboutText:addEventListener( 
        "tap",
        function () system.openURL( 'https://github.com/pressure-plate/SaveTheOcean' ) end 
    )
end


function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  -- Reference to the parent scene object
 
    if ( phase == "will" ) then
        -- Call the "resumeGame()" function in the parent scene
        -- parent:resumeGame()
    end
end


scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )

return scene