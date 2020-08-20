
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
    if onExitCallback ~= null then
        onExitCallback()
    end
    return true
end


local function openWindow(exitCallback)

    -- if a windows is already open, close it
    if isOpen == true then
        closeWindow()
    end

    -- show the menu window
    settingsWindow = display.newImage(group, uiDir .. "window2.png") -- set title
    settingsWindow:scale(1.5,1.2)
	settingsWindow.x = display.contentCenterX
    settingsWindow.y = display.contentCenterY
    settingsWindow:addEventListener( "tap", function () return true end )
    
    -- set the close button
    closeButton = display.newImage(group, uiDir .. "closeBadge.png") -- set mask
    closeButton:scale(0.3, 0.3)
	closeButton.x = display.contentCenterX - settingsWindow.x/1.5
	closeButton.y = display.contentCenterY - settingsWindow.y/1.6
    closeButton:addEventListener( "tap", closeWindow ) -- tap listener

    isOpen = true
    onExitCallback = exitCallback -- set the exit call back
end

-- load submarines function
function M.openSubmarinesMenu()
    openWindow(loadMod.destroySubmarines)
    loadMod.loadSubmarines()
end

function M.openAboutMenu()
    local text

    local function destroy()
        display.remove( text )
    end
    openWindow(destroy)
    text = display.newText( group, "Scemo chi Legge", display.contentCenterX-300, display.contentCenterY+100, "fonts/PermanentMarker.ttf", 100 )
end


function M.openWorldsMenu()
    openWindow(null)
end


-- init function
function M.init( displayGroup )

    -- init vars
    group = displayGroup

    -- init the loader
    loadMod.init(displayGroup)
end

return M
