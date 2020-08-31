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


-- generate the scores to display in the table
local function buildScores()

    local scores = savedata.getScores()
    local items = {}

    -- load up to 8 scores this is the maximum that the window can properly show
    for count = 1, 8 do
    
        -- set the dir based on the count of the score
        -- load the proper scoreboard for the first 3 places
        -- after the 3rd palce load the std scoreboard
        local dir = count
        if count > 3 then dir = 'n' end

        -- rappresent the tem as a table
        -- eg {dir=./1.png, scaleFactor=1.1, label=2332}
        local item = { 
            dir=leaderboardDir  .. dir .. ".png", 
            scaleFactor=1.1,
            label=scores[count]
        }
        
        table.insert(items, item) -- append the score to the table

        -- if there are no more scores then break
        -- do this at the end so you can load at least one tab
        -- if there are no scores jet, the score tab will display just the first place with 0 points
        if scores[count+1] == 0 then break end
    end

    return items
end


function scene:create( event )

    local sceneGroup = self.view

    -- create a new display group
    local group = display.newGroup()
    sceneGroup:insert( group )

    local windowsOptions = {
        onExitCallback = hideScene,
        windowTitle = "Scores"
    }
    windowMod.init( group, windowsOptions ) -- display the window

    local tabulatorOptions = {
        items = buildScores(),
        colCount = 2,
        rowCount = 5,
        tableOriginX = display.contentCenterX - display.contentWidth/5.6,
        tableOriginY = display.contentCenterY - display.contentHeight/3.6,
        tableReplicaDistanceFactorY = 1.1,
    }
    -- create the table based on the global configuration
    -- load the items int the table
    tabulatorMod.init ( group, tabulatorOptions )
end


scene:addEventListener( "create", scene )

return scene
