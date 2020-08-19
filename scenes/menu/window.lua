
local M = {}

local composer = require( "composer" )

-- load background module
local loadMod = require( "scenes.menu.load" )

-- initialize variables -------------------------------------------------------

-- assets directory
local uiDir = "assets/ui/" -- user interface assets di

local group
local isOpen = false
local onExitCallback -- function called to close all the objects in the window
local settingsWindow
local closeButton
local closeButtonScaleRateo = 3


local function closeWindow()
    display.remove( settingsWindow )
    display.remove( closeButton )
    isOpen = false
    onExitCallback()
end


local function openWindow()

    -- if a windows is already open, close it
    if isOpen == true then
        M.closeWindow()
    end

    -- set title on the menu
	settingsWindow = display.newImageRect(group, uiDir .. "window.png", display.contentWidth/1.2, display.contentHeight/1.2) -- set title
	settingsWindow.x = display.contentCenterX
    settingsWindow.y = display.contentCenterY
    
    -- set the close button
	closeButton = display.newImageRect(group, uiDir .. "closeBadge.png", 512/closeButtonScaleRateo, 512/closeButtonScaleRateo) -- set mask
	closeButton.x = display.contentCenterX - settingsWindow.x/1.5
	closeButton.y = display.contentCenterY - settingsWindow.y/1.6
    closeButton:addEventListener( "tap", closeWindow ) -- tap listener

    isOpen = true
end

-- load submarines function
function M.openSubmarinesMenu()
    onExitCallback = loadMod.destroySubmarines
    openWindow()
    loadMod.loadSubmarines()
end

function M.openAboutMenu()
    local text

    local function destroy()
        display.remove( text )
    end

    onExitCallback = destroy
    openWindow()
    text = display.newText( group, "Scemo chi Legge", display.contentCenterX-300, display.contentCenterY+100, "fonts/PermanentMarker.ttf", 100 )
end


function M.openWorldsMenu()
    openWindow()
end


-- init function
function M.init( displayGroup )

    -- init vars
    group = displayGroup

    -- init the loader
    loadMod.init(displayGroup)
end

return M
