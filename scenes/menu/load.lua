local M = {}

local composer = require( "composer" )

-- load submarine module
local subMod = require( "scenes.game.submarine" )

-- initialize variables -------------------------------------------------------

-- assets directory
local submarineDir = "assets/submarine/" -- user interface assets di

local submarinesCount = 6
local submarineScaleFactor = 0.8
local submarineWidth = 512/(display.contentWidth/(16*80))
local submarineHeight = 265/(display.contentHeight/(9*80))

local group
local submarines = {}

local originX = display.contentCenterX - display.contentWidth/4
local originY = display.contentCenterY - display.contentHeight/4

local colCount = 3
local rowCount = 2


local function selectItem( event )
    subMod.submarineSkin = event.target.submarineId
    print( "You touched the object ".. event.target.submarineId )
end


function M.destroySubmarines()
    for i=0, submarinesCount+1 do 
        display.remove( submarines[i] )
    end
    submarines = {}
end


function M.loadSubmarines()

    -- load submarines as grid
    local i = 1
    -- loop row
    for row = 1, rowCount do
        -- loop col
        for col = 0, colCount - 1 do
            -- generate submarine
            local submarine = display.newImage(group, submarineDir .. (i) .. ".png") -- set title
            submarine:scale( submarineScaleFactor, submarineScaleFactor )
            submarine.x = originX + submarine.width*submarineScaleFactor * col * 1.2
            submarine.y = originY + submarine.height*submarineScaleFactor * row * 1.2
            submarine.submarineId = i
            submarine:addEventListener( "tap", selectItem ) -- tap listener
            table.insert(submarines, submarine) -- save the submarine to remove it later

            i = i+1
            if i > submarinesCount then break end
        end
    end
end

-- init function
function M.init( displayGroup )
    -- init vars
    group = displayGroup
end

return M
