local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )
local tabulatorMod = require( "scenes.libs.tabulator" )

local leaderboardDir = "assets/ui/leaderboard/"


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
        windowTitle = "Scores"
    }

    -- load the window in the background
    windowMod.init( group, windowsOptions )

    local tabulatorOptions = {

        items = {
            { dir=leaderboardDir .. "1.png", scaleFactor=1.2, label='300' },
            { dir=leaderboardDir .. "2.png", scaleFactor=1.2, label='289' },
            { dir=leaderboardDir .. "3.png", scaleFactor=1.2, label='230' },
            { dir=leaderboardDir .. "n.png", scaleFactor=1.2, label='300' },
            { dir=leaderboardDir .. "n.png", scaleFactor=1.2, label='300' },
            { dir=leaderboardDir .. "n.png", scaleFactor=1.2, label='300' },
        },
        colCount = 2,
        rowCount = 5,
        tableOriginX = display.contentCenterX - display.contentWidth/5.2,
        tableOriginY = display.contentCenterY - display.contentHeight/4,
        onTapCallback = function () return true end,
    }
    -- create the table based on the global configuration
    -- load the items int the table
    tabulatorMod.init ( group, tabulatorOptions )
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