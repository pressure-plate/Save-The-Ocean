local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )
local tabulatorMod = require( "scenes.libs.tabulator" )
local savedata = require( "scenes.libs.savedata" ) -- load the save data module
local bgMenuMod = require( "scenes.menu.background" ) -- required to reload the home background
local audioMod = require( "scenes.libs.audio" ) -- load lib to do audio changes on the game

local itemsDir = "assets/background/"

itemsData = {
    {inernalId='TornadoOcean', dir='1.png', price=9000, default=true},
    {inernalId='GreenPisel', dir='2.png', price=8000},
    {inernalId='DeathLand', dir='3.png', price=8500},
    {inernalId='RomanTemple', dir='4.png', price=9000},
}

local parent 
local group


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
            
            -- set the submarine just buyed
            ownedData[itemsData[event.target.itemId].inernalId] = true 
            savedata.setGamedata( "backgroundsOwned", ownedData )
    
            -- display the object as owned
            event.target.alpha = 1
            tabulatorMod.removeItemTextOver( event.target.itemId )
    
            -- update the money value on the parent scene
            parent:updateMoneyView()
    
            -- play sound to coumicate succes with the transaction
            audio.play( audioMod.paySound );
    
        else
            -- play audio to communicate that the user don't have enough money to buy the item
            audio.play( audioMod.noMoneySound );
        end
    
    -- concatenate actions with else if, so the user have to click again to select the item
    -- select the item, if the operation goes well, do actions
    elseif tabulatorMod.highlightItem( event.target.itemId, true ) then
        savedata.setGamedata( "backgroundWorld", event.target.itemId )
    end

end


-- generate the items table to display the items
local function builditems()
    local itemsOwned = savedata.getGamedata( "backgroundsOwned" )
    local items = {}

    for count, el in pairs ( itemsData ) do
        
        -- set the base data of the item
        local item = { 
            dir=itemsDir .. el.dir, 
            scaleFactor=0.8,
        }
        
        -- if the user don't own the item set the price to buy it
        if not itemsOwned[el.inernalId] then

            -- check if the item is a default one
            -- the default value is used to set in the itemsOwned the default items on the first load of the game
            -- if it is a default item then save it in the user itemsOwned
            if el.default then
                -- update the user owned data with the default item
                itemsOwned[el.inernalId] = true
                savedata.setGamedata( "backgroundsOwned", itemsOwned )
            else
                item["label"] = el.price .. '$' -- set the price to show over the item
                item['alpha'] = 0.5 -- edit opacity to emphasize that the item is disabled
            end

        end

        table.insert( items, item ) -- append to the table the built item

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

    local windowsOptions = {
        onExitCallback = hideScene,
        windowTitle = "Worlds"
    }

    -- load the window in the background
    windowMod.init( group, windowsOptions )

    -- options
    local tabulatorOptions = {
        items = builditems(),
        colCount = 3,
        rowCount = 2,
        tableOriginX = display.contentCenterX - display.contentWidth/4,
        tableOriginY = display.contentCenterY - display.contentHeight/3.3,
        tableReplicaDistanceFactorX = 1.17,
        onTapCallback = onWorldStikerSelection,
    }
    -- create the table based on the global configuration
    -- load the items in the table to display them with the builted pproprieties
    tabulatorMod.init ( group, tabulatorOptions )
    tabulatorMod.highlightItem(savedata.getGamedata( "backgroundWorld" ), false) -- highlight without play sond (on load)
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

return scene
