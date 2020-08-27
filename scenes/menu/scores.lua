local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )
local tabulatorMod = require( "scenes.libs.tabulator" )
local savedata = require( "scenes.libs.savedata" ) -- load the save data module

local leaderboardDir = "assets/ui/leaderboard/"


-- to hide the current overlay
local function hideScene()
    composer.hideOverlay( "fade", composer.getVariable( "windowFadingClosingTime" ) )
end


local function buildScores()
    local scores = savedata.getScores()
    local items = {}

    for count = 1, 6 do
        
        local score = scores[count]

        -- set the dir based on the number of the score
        local dir = count
        if count > 3 then dir = 'n' end

        local item = { 
            dir=leaderboardDir  .. dir .. ".png", 
            scaleFactor=1.2,
            label=score
        }
        
        table.insert(items, item) -- append to the table

        -- if there are no more scores then break
        -- do this at the end so you can load at least one tab
        if score == 0 then break end
    end

    return items
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

        items = buildScores(),
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