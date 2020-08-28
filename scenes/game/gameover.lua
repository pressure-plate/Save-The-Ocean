local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )
local buttonsMod = require( "scenes.libs.ui" )

local parent 
local group

local autoExitTimer

local buttonClickSound


local function playAgaing()
    audio.play( buttonClickSound )
    timer.cancel( autoExitTimer )
	composer.gotoScene( "scenes.game", { time=1400, effect="slideLeft" } )
end


-- call the parent function to exit the game
local function exitGame() parent.exitGame() end


function scene:show( event )
    parent = event.parent  -- Reference to the parent scene object
end


function scene:create( event )

    local sceneGroup = self.view

    group = display.newGroup() -- display group for background
    sceneGroup:insert( group )

    buttonClickSound = audio.loadStream( composer.getVariable( "audioDir" ) .. "sfx/click.mp3" )
    local font = composer.getVariable( "defaultFontParams" )

    -- display game over
	local gameOverText = display.newText( 
        group, 
        "GAME OVER", 
        display.contentCenterX, 
        display.contentCenterY-260, 
        font.path, 130 
    )
    gameOverText:setFillColor( font.colorR, font.colorG, font.colorB )
    
    -- display score
	local scoredText = display.newText( 
        group, 
        "SCORED: " .. event.params.score, 
        display.contentCenterX, 
        display.contentCenterY-130, 
        font.path, 
        100 
    )
	scoredText:setFillColor( font.colorR, font.colorG, font.colorB )

    local buttonsDescriptor = {
		descriptor = {
			{ "buttonRestart.png", playAgaing },
			{ "buttonMenu.png", exitGame }
		},
		propagation = 'down',
		position = 'center',
		scaleFactor = 0.6
	}
    buttonsMod.init( group, buttonsDescriptor )
    
    -- call exitGame function after a short delay
	autoExitTimer = timer.performWithDelay( 4000, exitGame )

end


function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  -- Reference to the parent scene object
    
    -- delete the auto exit timer

    if ( phase == "will" ) then
        
    end
end

function scene:destroy( event )

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )


return scene