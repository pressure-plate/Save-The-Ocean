local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )
local tabulatorMod = require( "scenes.libs.tabulator" )
local savedata = require( "scenes.libs.savedata" ) -- load the save data module
local bgMenuMod = require( "scenes.menu.background" ) -- required to reload the home background

local itemsDir = "assets/background/"

itemsData = {
    {inernalId='TornadoOcean', dir='1.png', price=9000, default=true},
    {inernalId='GreenPisel', dir='2.png', price=8000},
    {inernalId='DeathLand', dir='3.png', price=8500},
    {inernalId='RomanTemple', dir='4.png', price=9000},
}

local parent 
local group

local paySound
local noMoneySound


-- to hide the current overlay
-- and go back to the parent scene
local function hideScene()
    composer.hideOverlay( "fade", composer.getVariable( "windowFadingClosingTime" ) )
end


-- set the background var once is selected
-- check also if is avaiable, and its price
local function onWorldStikerSelection( event )

    if event.target.alpha ~= 1 then

        -- try to pay
        if savedata.pay( itemsData[event.target.itemId].price) then

            -- update the user owned data
            local ownedData = savedata.getGamedata( "backgroundsOwned" )
            ownedData[itemsData[event.target.itemId].inernalId] = true

            -- display the object as owned
            event.target.alpha = 1
            tabulatorMod.removeItemTextOver( event.target.itemId )

            -- update the money value
            parent:updateMoneyView()
            audio.play( paySound );
            return
        else
            audio.play( noMoneySound );
        end
    end
    
    -- select the item, if the operation goes well, do actions
    if tabulatorMod.highlightItem(event.target.itemId, true) then
        savedata.setGamedata( "backgroundWorld", event.target.itemId )
        bgMenuMod.updateBackground() -- call the reload for the background menu
    end

end


-- generate the items table to display the items
local function builditems()
    local itemsOwned = savedata.getGamedata( "backgroundsOwned")
    local items = {}

    for count, el in pairs ( itemsData ) do
        

        -- set the base data of the item
        local item = { 
            dir=itemsDir .. el.dir, 
            scaleFactor=0.8,
        }
        
        -- if the user dont own the item set the price to buy it
        if not itemsOwned[el.inernalId] then

            -- check if the item is set as default
            -- if is as defaut and is not owned then add the user owned set
            if not el.default then
                item["label"] = el.price .. '$'
                item['alpha'] = 0.5
            else
                -- update the user owned data
                local ownedData = savedata.getGamedata( "backgroundsOwned" )
                ownedData[el.inernalId] = true
            end

        end

        table.insert(items, item) -- append to the table

    end

    return items
end


function scene:show( event )
    parent = event.parent  -- Reference to the parent scene object
end


function scene:create( event )

    local sceneGroup = self.view

    group = display.newGroup() -- display group for background
    sceneGroup:insert( group )

    paySound = audio.loadStream( composer.getVariable( "audioDir" ) .. "sfx/pay.mp3" )
    noMoneySound = audio.loadStream( composer.getVariable( "audioDir" ) .. "sfx/noMoney.mp3" )

    local windowsOptions = {
        onExitCallback = hideScene,
        windowTitle = "Worlds"
    }

    -- load the window in the background
    windowMod.init( group, windowsOptions )

    -- options
    local tabulatorOptions = {
        -- itemDir, scaleFactor, price
        items = builditems(),
        colCount = 3,
        rowCount = 2,
        tableOriginX = display.contentCenterX - display.contentWidth/4,
        tableOriginY = display.contentCenterY - display.contentHeight/3.3,
        tableReplicaDistanceFactorX = 1.17,
        onTapCallback = onWorldStikerSelection,
    }
    -- create the table based on the global configuration
    -- load the items int the table
    tabulatorMod.init ( group, tabulatorOptions )
    tabulatorMod.highlightItem(savedata.getGamedata( "backgroundWorld" ), false) -- highlight without play sond (on load)
end


function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  -- Reference to the parent scene object
 
    if ( phase == "will" ) then
        -- update the mony view before leave the window
        parent:updateMoneyView()
    end
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene