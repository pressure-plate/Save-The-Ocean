local composer = require( "composer" )
local scene = composer.newScene()


-- initialize variables -------------------------------------------------------
local windowMod = require( "scenes.libs.window" )
local tabulatorMod = require( "scenes.libs.tabulator" )
local savedata = require( "scenes.libs.savedata" ) -- load the save data module
local bgMenuMod = require( "scenes.menu.background" ) -- required to reload the home background
local audioMod = require( "scenes.libs.audio" ) -- load lib to do audio changes on the game

local itemsDir = "assets/submarine/bubble/"

itemsData = {
    {inernalId='SoapBubble', dir='1.png', price=1, default=true},
    {inernalId='CleanBubble', dir='2.png', price=300},
    {inernalId='VioletBubble', dir='3.png', price=830},
}

local parent 
local group


-- to hide the current overlay
local function hideScene()
    composer.hideOverlay( "fade", composer.getVariable( "windowFadingClosingTime" ) )
end


-- set the background var once is selected
-- check also if is avaiable, and its price
local function onBubbleSelection( event )

    if event.target.alpha ~= 1 then

        -- try to pay
        if savedata.pay( itemsData[event.target.itemId].price) then

            -- update the user owned data
            local ownedData = savedata.getGamedata( "submarineBubblesOwned" )
            ownedData[itemsData[event.target.itemId].inernalId] = true

            -- display the object as owned
            event.target.alpha = 1
            tabulatorMod.removeItemTextOver( event.target.itemId )

            -- update the money value
            parent:updateMoneyView()
            audio.play( audioMod.paySound );
            return
        else
            audio.play( audioMod.noMoneySound );
        end
    end
    
    -- select the item, if the operation goes well, do actions
    if tabulatorMod.highlightItem(event.target.itemId, true) then
        savedata.setGamedata( "submarineBubbleSkin", event.target.itemId )
    end

end


-- generate the items table to display the items
local function builditems()
    local itemsOwned = savedata.getGamedata( "submarineBubblesOwned")
    local items = {}

    for count, el in pairs ( itemsData ) do
        

        -- set the base data of the item
        local item = { 
            dir=itemsDir .. el.dir, 
            scaleFactor=2,
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
                local ownedData = savedata.getGamedata( "submarineBubblesOwned" )
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

    local windowsOptions = {
        onExitCallback = hideScene,
        windowTitle = "Bubbles"
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
        tableOriginY = display.contentCenterY - display.contentHeight/4.9,
        tableReplicaDistanceFactorX = 2.8,
        onTapCallback = onBubbleSelection,
    }
    -- create the table based on the global configuration
    -- load the items int the table
    tabulatorMod.init ( group, tabulatorOptions )
    tabulatorMod.highlightItem(savedata.getGamedata( "submarineBubbleSkin" ), false) -- highlight without play sond (on load)
end


function scene:hide( event )
 
    if ( phase == "will" ) then
        -- update the mony view before leave the window
        parent:updateMoneyView()
    end

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene