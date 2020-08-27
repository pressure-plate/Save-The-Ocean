local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )
local tabulatorMod = require( "scenes.libs.tabulator" )
local savedata = require( "scenes.libs.savedata" ) -- load the save data module

local submarineDir = "assets/submarine/"

local group


-- to hide the current overlay
function hideScene()
    composer.hideOverlay( "fade", composer.getVariable( "windowFadingClosingTime" ) )
end


-- set the background var once is selected
-- check also if is avaiable, and its price
local function onSubmarineSelection( event )
    
    -- select the item, if the operation goes well, do actions
    if tabulatorMod.highlightItem(event.target.itemId, true) then
        savedata.setGamedata( "submarineSkin", event.target.itemId )
    end

end


function scene:create( event )

    local sceneGroup = self.view

    group = display.newGroup() -- display group for background
    sceneGroup:insert( group )

    local windowsOptions = {
        onExitCallback = hideScene,
        windowTitle = "Submarines"
    }

    -- load the window in the background
    windowMod.init( group, windowsOptions )

    -- options
    local tabulatorOptions = {
        -- itemDir, scaleFactor, price
        items = {
            { dir=submarineDir .. "1.png", scaleFactor=0.8 },
            { dir=submarineDir .. "2.png", scaleFactor=0.8 },
            { dir=submarineDir .. "3.png", scaleFactor=0.8, label='22', alpha=0.5 },
            { dir=submarineDir .. "4.png", scaleFactor=0.8, label='24', alpha=0.5 },
            { dir=submarineDir .. "5.png", scaleFactor=0.8, label='24', alpha=0.5 },
            { dir=submarineDir .. "6.png", scaleFactor=0.8, label='24', alpha=0.5 },
        },
        colCount = 3,
        rowCount = 2,
        tableOriginX = display.contentCenterX - display.contentWidth/4,
        tableOriginY = display.contentCenterY - display.contentHeight/3.3,
        tableReplicaDistanceFactorX = 1.17,
        onTapCallback = onSubmarineSelection,
    }
    -- create the table based on the global configuration
    -- load the items int the table
    tabulatorMod.init ( group, tabulatorOptions )
    tabulatorMod.highlightItem(savedata.getGamedata( "submarineSkin" ), false) -- highlight without play sond (on load)
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